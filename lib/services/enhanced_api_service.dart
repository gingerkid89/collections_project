// lib/services/enhanced_api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/place.dart';
import '../models/restaurant.dart';
import '../models/museum.dart';
import '../models/visit.dart';
import '../models/menu_item.dart';
import '../utils/unicode_fixes.dart';
import '../config/app_config.dart';
import 'auth_service.dart';
import 'cache_service.dart';
import 'connectivity_service.dart';

class EnhancedApiService {
  // API Configuration from Environment
  static String get baseUrl => AppConfig.apiBaseUrl;
  static Duration get _timeout => AppConfig.apiTimeout;

  // User ID (matches production database)
  static const String testUserId = 'c1a7b30d-b623-4885-ae0d-b395cdda4b49';

  // Service instances
  static final AuthService _authService = MockAuthService();
  static final CacheService _cache = CacheService.instance;
  static final ConnectivityService _connectivity = ConnectivityService.instance;

  // Cache keys
  static const String _allPlacesCacheKey = 'all_places';
  static const String _restaurantsCacheKey = 'restaurants';
  static const String _museumsCacheKey = 'museums';

  // Get headers with optional authorization
  static Future<Map<String, String>> _getHeaders({bool requireAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final token = await _authService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Enhanced HTTP Helper Methods with Caching
  static Future<Map<String, dynamic>> _get(
    String endpoint, {
    bool requireAuth = false,
    String? cacheKey,
    bool forceRefresh = false,
    Duration? cacheExpiry,
  }) async {
    try {
      // Check cache first if not forcing refresh
      if (!forceRefresh && cacheKey != null) {
        final cachedData = await _cache.getCachedData(cacheKey);
        if (cachedData != null) {
          if (AppConfig.enableDetailedLogging) {
            print('📖 Returning cached data for: $endpoint');
          }
          return cachedData;
        }
      }

      // Check connectivity
      if (_connectivity.isOffline) {
        // Try to return cached data even if expired in offline mode
        if (cacheKey != null) {
          final cachedData = await _cache.getCachedData(cacheKey);
          if (cachedData != null) {
            if (AppConfig.enableDetailedLogging) {
              print('🔌 Offline: Returning cached data for: $endpoint');
            }
            return cachedData;
          }
        }
        throw ApiException('No internet connection and no cached data available');
      }

      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      ).timeout(_timeout);

      final responseData = _handleResponse(response);

      // Cache the response if cache key is provided
      if (cacheKey != null && responseData['success'] == true) {
        await _cache.cacheData(cacheKey, responseData, expiry: cacheExpiry);
        if (AppConfig.enableDetailedLogging) {
          print('💾 Cached response for: $endpoint');
        }
      }

      return responseData;
    } catch (e) {
      // If request fails but we have cached data, return it
      if (cacheKey != null) {
        final cachedData = await _cache.getCachedData(cacheKey);
        if (cachedData != null) {
          if (AppConfig.enableDetailedLogging) {
            print('⚠️ Request failed, returning cached data for: $endpoint');
          }
          return cachedData;
        }
      }
      throw ApiException('GET $endpoint failed: $e');
    }
  }

  static Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, dynamic> data, {
    bool requireAuth = false,
  }) async {
    try {
      // Check connectivity for write operations
      if (_connectivity.isOffline) {
        throw ApiException('Cannot perform write operations while offline');
      }

      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      ).timeout(_timeout);

      final responseData = _handleResponse(response);

      // Invalidate related caches after successful write
      if (responseData['success'] == true) {
        await _invalidateRelatedCaches(endpoint);
      }

      return responseData;
    } catch (e) {
      throw ApiException('POST $endpoint failed: $e');
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw ApiException(
        data['message'] ?? 'API request failed',
        statusCode: response.statusCode,
      );
    }
  }

  // Invalidate caches related to an endpoint
  static Future<void> _invalidateRelatedCaches(String endpoint) async {
    if (endpoint.contains('/places')) {
      await _cache.cacheData(_allPlacesCacheKey, {}, expiry: Duration.zero);
      await _cache.cacheData(_restaurantsCacheKey, {}, expiry: Duration.zero);
      await _cache.cacheData(_museumsCacheKey, {}, expiry: Duration.zero);
    }
    if (endpoint.contains('/collections')) {
      // Invalidate collections cache (implement when collections caching is added)
    }
    if (endpoint.contains('/visits')) {
      await _cache.cacheData('visits_$testUserId', {}, expiry: Duration.zero);
    }
  }

  // Enhanced Places Endpoints with Caching
  static Future<List<Place>> getPlaces({
    String? type,
    String? search,
    int? limit,
    bool forceRefresh = false,
  }) async {
    final queryParams = <String, String>{};
    if (type != null) queryParams['type'] = type;
    if (search != null) queryParams['search'] = search;
    if (limit != null) queryParams['limit'] = limit.toString();

    final queryString = queryParams.isNotEmpty
      ? '?${queryParams.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}'
      : '';

    // Determine cache key based on parameters
    String cacheKey = _allPlacesCacheKey;
    if (type == 'restaurant') cacheKey = _restaurantsCacheKey;
    if (type == 'museum') cacheKey = _museumsCacheKey;
    if (search != null) cacheKey = '${cacheKey}_search_${search}';

    final result = await _get(
      '/places$queryString',
      cacheKey: cacheKey,
      forceRefresh: forceRefresh,
      cacheExpiry: const Duration(hours: 2),
    );

    final placesData = result['data'] as List<dynamic>;

    final places = placesData.map<Place>((json) {
      final placeJson = json as Map<String, dynamic>;
      switch (placeJson['type']) {
        case 'restaurant':
          return RestaurantApi.fromApiJson(placeJson);
        case 'museum':
          return MuseumApi.fromApiJson(placeJson);
        default:
          throw ApiException('Unknown place type: ${placeJson['type']}');
      }
    }).toList();

    // Cache individual places as well
    for (final place in places) {
      await _cache.cacheData('place_${place.id}', place.toJson(), expiry: const Duration(hours: 4));
    }

    return places;
  }

  static Future<List<Place>> getRestaurants({bool forceRefresh = false}) async {
    return getPlaces(type: 'restaurant', forceRefresh: forceRefresh);
  }

  static Future<List<Place>> getMuseums({bool forceRefresh = false}) async {
    return getPlaces(type: 'museum', forceRefresh: forceRefresh);
  }

  static Future<Place> getPlace(String placeId, {bool forceRefresh = false}) async {
    final result = await _get(
      '/places/$placeId',
      cacheKey: 'place_$placeId',
      forceRefresh: forceRefresh,
      cacheExpiry: const Duration(hours: 4),
    );

    final placeJson = result['data'] as Map<String, dynamic>;

    switch (placeJson['type']) {
      case 'restaurant':
        return RestaurantApi.fromApiJson(placeJson);
      case 'museum':
        return MuseumApi.fromApiJson(placeJson);
      default:
        throw ApiException('Unknown place type: ${placeJson['type']}');
    }
  }

  static Future<List<MenuItem>> getRestaurantMenu(
    String restaurantId, {
    bool forceRefresh = false,
  }) async {
    final result = await _get(
      '/places/$restaurantId/menu',
      cacheKey: 'menu_$restaurantId',
      forceRefresh: forceRefresh,
      cacheExpiry: const Duration(hours: 6),
    );

    final menuData = result['data']['menuItems'] as List<dynamic>;
    return menuData.map<MenuItem>((json) => MenuItem.fromJson(json)).toList();
  }

  // Enhanced User Endpoints with Caching
  static Future<List<Place>> getUserPlaces({
    String? type,
    bool? visited,
    bool forceRefresh = false,
  }) async {
    final queryParams = <String, String>{};
    if (type != null) queryParams['type'] = type;
    if (visited != null) queryParams['visited'] = visited.toString();

    final queryString = queryParams.isNotEmpty
      ? '?${queryParams.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}'
      : '';

    final cacheKey = 'user_places_${testUserId}_${type ?? 'all'}_${visited ?? 'all'}';

    final result = await _get(
      '/user/$testUserId/places$queryString',
      requireAuth: true,
      cacheKey: cacheKey,
      forceRefresh: forceRefresh,
      cacheExpiry: const Duration(minutes: 30),
    );

    final placesData = result['data'] as List<dynamic>;

    return placesData.map<Place>((json) {
      final placeJson = json as Map<String, dynamic>;
      switch (placeJson['type']) {
        case 'restaurant':
          return RestaurantApi.fromApiJson(placeJson);
        case 'museum':
          return MuseumApi.fromApiJson(placeJson);
        default:
          throw ApiException('Unknown place type: ${placeJson['type']}');
      }
    }).toList();
  }

  static Future<List<Place>> getUserFavorites({bool forceRefresh = false}) async {
    final result = await _get(
      '/user/$testUserId/favorites',
      requireAuth: true,
      cacheKey: 'user_favorites_$testUserId',
      forceRefresh: forceRefresh,
      cacheExpiry: const Duration(minutes: 30),
    );

    final placesData = result['data'] as List<dynamic>;

    return placesData.map<Place>((json) {
      final placeJson = json as Map<String, dynamic>;
      switch (placeJson['type']) {
        case 'restaurant':
          return RestaurantApi.fromApiJson(placeJson);
        case 'museum':
          return MuseumApi.fromApiJson(placeJson);
        default:
          throw ApiException('Unknown place type: ${placeJson['type']}');
      }
    }).toList();
  }

  static Future<Map<String, dynamic>> getUserStats({bool forceRefresh = false}) async {
    final result = await _get(
      '/user/$testUserId/stats',
      requireAuth: true,
      cacheKey: 'user_stats_$testUserId',
      forceRefresh: forceRefresh,
      cacheExpiry: const Duration(minutes: 15),
    );

    return result['data'] as Map<String, dynamic>;
  }

  // Enhanced Visits Endpoints with Caching
  static Future<List<Visit>> getVisits({
    String? placeId,
    String? placeType,
    bool forceRefresh = false,
  }) async {
    final queryParams = <String, String>{'userId': testUserId};
    if (placeId != null) queryParams['placeId'] = placeId;
    if (placeType != null) queryParams['placeType'] = placeType;

    final queryString = queryParams.entries
      .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
      .join('&');

    final cacheKey = 'visits_${testUserId}_${placeId ?? 'all'}_${placeType ?? 'all'}';

    final result = await _get(
      '/visits?$queryString',
      cacheKey: cacheKey,
      forceRefresh: forceRefresh,
      cacheExpiry: const Duration(minutes: 15),
    );

    final visitsData = result['data'] as List<dynamic>;
    return visitsData.map<Visit>((json) => VisitApi.fromApiJson(json)).toList();
  }

  static Future<Visit> getVisit(String visitId, {bool forceRefresh = false}) async {
    final result = await _get(
      '/visits/$visitId',
      cacheKey: 'visit_$visitId',
      forceRefresh: forceRefresh,
      cacheExpiry: const Duration(minutes: 30),
    );

    return VisitApi.fromApiJson(result['data']);
  }

  static Future<Visit> createVisit(Visit visit) async {
    final visitData = visit.toApiJson();
    final result = await _post('/visits', visitData);

    // Invalidate visits cache
    await _invalidateRelatedCaches('/visits');

    return VisitApi.fromApiJson(result['data']);
  }

  // Enhanced Collections Endpoints with Caching
  static Future<List<Map<String, dynamic>>> getCollections({bool forceRefresh = false}) async {
    final result = await _get(
      '/collections?user_id=$testUserId',
      cacheKey: 'collections_$testUserId',
      forceRefresh: forceRefresh,
      cacheExpiry: const Duration(hours: 1),
    );

    return List<Map<String, dynamic>>.from(result['data']);
  }

  static Future<Map<String, dynamic>> getCollection(
    String collectionId, {
    bool forceRefresh = false,
  }) async {
    final result = await _get(
      '/collections/$collectionId?user_id=$testUserId',
      cacheKey: 'collection_$collectionId',
      forceRefresh: forceRefresh,
      cacheExpiry: const Duration(hours: 2),
    );

    return result['data'] as Map<String, dynamic>;
  }

  static Future<List<Place>> getCollectionPlaces(
    String collectionId, {
    bool forceRefresh = false,
  }) async {
    if (AppConfig.enableDetailedLogging) {
      print('🌐 API: Requesting collection places for $collectionId (forceRefresh: $forceRefresh)');
    }

    final endpoint = '/collections/$collectionId/places?user_id=$testUserId';
    final cacheKey = 'collection_places_$collectionId';

    if (AppConfig.enableDetailedLogging) {
      print('🌐 API: GET $baseUrl$endpoint');
    }

    final result = await _get(
      endpoint,
      cacheKey: cacheKey,
      forceRefresh: forceRefresh,
      cacheExpiry: const Duration(hours: 1),
    );

    if (AppConfig.enableDetailedLogging) {
      print('🌐 API: Raw response keys: ${result.keys.toList()}');
    }

    final placesData = result['data'] as List<dynamic>;
    if (AppConfig.enableDetailedLogging) {
      print('🌐 API: Found ${placesData.length} places in response data');
    }

    final places = placesData.map<Place>((json) {
      final placeJson = json as Map<String, dynamic>;
      if (AppConfig.enableDetailedLogging) {
        print('🌐 API: Processing place: ${placeJson['name']} (${placeJson['type']})');
      }

      switch (placeJson['type']) {
        case 'restaurant':
          return RestaurantApi.fromApiJson(placeJson);
        case 'museum':
          return MuseumApi.fromApiJson(placeJson);
        default:
          throw ApiException('Unknown place type: ${placeJson['type']}');
      }
    }).toList();

    if (AppConfig.enableDetailedLogging) {
      print('🌐 API: Successfully converted ${places.length} places');
    }

    return places;
  }

  // Enhanced Exhibitions Endpoints with Caching
  static Future<List<Map<String, dynamic>>> getExhibitions({
    String? museumId,
    String? type,
    String? category,
    bool forceRefresh = false,
  }) async {
    final queryParams = <String, String>{};
    if (museumId != null) queryParams['museumId'] = museumId;
    if (type != null) queryParams['type'] = type;
    if (category != null) queryParams['category'] = category;

    final queryString = queryParams.isNotEmpty
      ? '?${queryParams.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}'
      : '';

    final cacheKey = 'exhibitions_${museumId ?? 'all'}_${type ?? 'all'}_${category ?? 'all'}';

    final result = await _get(
      '/exhibitions$queryString',
      cacheKey: cacheKey,
      forceRefresh: forceRefresh,
      cacheExpiry: const Duration(hours: 4),
    );

    return List<Map<String, dynamic>>.from(result['data']);
  }

  static Future<Map<String, dynamic>> getExhibition(
    String exhibitionId, {
    bool forceRefresh = false,
  }) async {
    final result = await _get(
      '/exhibitions/$exhibitionId',
      cacheKey: 'exhibition_$exhibitionId',
      forceRefresh: forceRefresh,
      cacheExpiry: const Duration(hours: 6),
    );

    return result['data'] as Map<String, dynamic>;
  }

  static Future<List<Map<String, dynamic>>> getMuseumExhibitions(
    String museumId, {
    bool forceRefresh = false,
  }) async {
    final result = await _get(
      '/exhibitions/museum/$museumId',
      cacheKey: 'museum_exhibitions_$museumId',
      forceRefresh: forceRefresh,
      cacheExpiry: const Duration(hours: 4),
    );

    final exhibitions = result['data']['exhibitions'] as List<dynamic>;
    return List<Map<String, dynamic>>.from(exhibitions);
  }

  // Utility Methods
  static Future<Map<String, dynamic>> healthCheck({bool forceRefresh = false}) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl.replaceAll('/api/v1', '')}/api/health'),
      ).timeout(_timeout);

      return jsonDecode(response.body);
    } catch (e) {
      throw ApiException('Health check failed: $e');
    }
  }

  static Future<List<Place>> searchPlaces(String query, {bool forceRefresh = false}) async {
    return getPlaces(search: query, forceRefresh: forceRefresh);
  }

  // Write Operations (No caching, but invalidate caches)
  static Future<Place> createPlace(Map<String, dynamic> placeData) async {
    final result = await _post('/places', placeData);
    final placeJson = result['data'] as Map<String, dynamic>;

    switch (placeJson['type']) {
      case 'restaurant':
        return RestaurantApi.fromApiJson(placeJson);
      case 'museum':
        return MuseumApi.fromApiJson(placeJson);
      default:
        throw ApiException('Unknown place type: ${placeJson['type']}');
    }
  }

  // Create Restaurant specifically
  static Future<Restaurant> createRestaurant({
    required String name,
    required String address,
    required String cuisine,
    required String priceCategory,
    String? phone,
    String? website,
    String? email,
    Map<String, String>? openingHours,
    List<String>? highlights,
    double? latitude,
    double? longitude,
    String? imageUrl,
    bool hasReservation = false,
    bool hasDelivery = false,
    bool hasTakeout = false,
    List<Map<String, dynamic>>? menuItems,
  }) async {
    final placeData = {
      'name': name,
      'type': 'restaurant',
      'emoji': '🍽️',
      'address': address,
      'phone': phone,
      'website': website,
      'email': email,
      'openingHours': openingHours ?? {},
      'highlights': highlights ?? [],
      'priceRange': priceCategory,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'specialData': {
        'cuisine': cuisine,
        'hasReservation': hasReservation,
        'hasDelivery': hasDelivery,
        'hasTakeout': hasTakeout,
      },
      'menuItems': menuItems ?? [],
    };

    final place = await createPlace(placeData);
    return place as Restaurant;
  }

  // Create Museum specifically
  static Future<Museum> createMuseum({
    required String name,
    required String address,
    required String category,
    String? ticketPrice,
    List<String>? currentExhibitions,
    List<String>? permanentCollections,
    String? phone,
    String? website,
    String? email,
    Map<String, String>? openingHours,
    List<String>? highlights,
    double? latitude,
    double? longitude,
    String? imageUrl,
    bool hasAudioGuide = false,
    bool hasGiftShop = false,
    bool isWheelchairAccessible = false,
  }) async {
    final placeData = {
      'name': name,
      'type': 'museum',
      'emoji': '🏛️',
      'address': address,
      'phone': phone,
      'website': website,
      'email': email,
      'openingHours': openingHours ?? {},
      'highlights': highlights ?? [],
      'priceRange': ticketPrice,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'specialData': {
        'category': category,
        'currentExhibitions': currentExhibitions ?? [],
        'permanentCollections': permanentCollections ?? [],
        'ticketPrice': ticketPrice ?? 'Free',
        'hasAudioGuide': hasAudioGuide,
        'hasGiftShop': hasGiftShop,
        'isWheelchairAccessible': isWheelchairAccessible,
      },
    };

    final place = await createPlace(placeData);
    return place as Museum;
  }

  // Cache Management Methods
  static Future<void> clearAllCaches() async {
    await _cache.clearAllCaches();
  }

  static Future<void> clearExpiredCaches() async {
    await _cache.clearExpiredCaches();
  }

  static Future<Map<String, dynamic>> getCacheStats() async {
    return await _cache.getCacheStats();
  }

  static Future<void> preloadData() async {
    if (_connectivity.isOnline) {
      try {
        // Preload essential data
        await getPlaces();
        await getCollections();

        if (AppConfig.enableDetailedLogging) {
          print('📦 Essential data preloaded');
        }
      } catch (e) {
        if (AppConfig.enableDetailedLogging) {
          print('⚠️ Failed to preload data: $e');
        }
      }
    }
  }
}

// Keep the existing ApiException and extension classes
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

// Extension to add API JSON methods to models (reuse existing ones)
extension RestaurantApi on Restaurant {
  static Restaurant fromApiJson(Map<String, dynamic> json) {
    // Convert API response to Restaurant model
    final specialData = json['specialData'] as Map<String, dynamic>? ?? {};
    final stats = json['stats'] as Map<String, dynamic>? ?? {};
    final collectionStatus = json['collectionStatus'] as Map<String, dynamic>? ?? {};

    return Restaurant(
      id: json['id'],
      name: UnicodeFixes.cleanText(json['name']) ?? 'Unknown Restaurant',
      cuisine: UnicodeFixes.cleanText(specialData['cuisine']) ?? '',
      priceCategory: UnicodeFixes.fixPriceRange(json['priceRange']),
      menu: [], // Menu items loaded separately
      imageUrl: json['imageUrl'],
      emoji: UnicodeFixes.getPlaceTypeEmoji('restaurant', json['emoji']),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      collectionStatus: PlaceCollectionStatus(
        isVisited: collectionStatus['isVisited'] ?? false,
        lastVisit: collectionStatus['lastVisit'] != null
          ? DateTime.parse(collectionStatus['lastVisit']) : null,
        userRating: collectionStatus['userRating']?.toDouble(),
        visitCount: collectionStatus['visitCount'] ?? 0,
      ),
      visits: [], // Visits loaded separately
      info: PlaceInfo(
        address: json['address'] ?? '',
        phone: json['phone'],
        website: json['website'],
        email: json['email'],
        openingHours: Map<String, String>.from(json['openingHours'] ?? {}),
        highlights: List<String>.from(json['highlights'] ?? []),
        priceRange: UnicodeFixes.fixPriceRange(json['priceRange']),
      ),
      hasReservation: specialData['hasReservation'] ?? false,
      hasDelivery: specialData['hasDelivery'] ?? false,
      hasTakeout: specialData['hasTakeout'] ?? false,
    );
  }
}

extension MuseumApi on Museum {
  static Museum fromApiJson(Map<String, dynamic> json) {
    // Convert API response to Museum model
    final specialData = json['specialData'] as Map<String, dynamic>? ?? {};
    final collectionStatus = json['collectionStatus'] as Map<String, dynamic>? ?? {};

    return Museum(
      id: json['id'],
      name: UnicodeFixes.cleanText(json['name']) ?? 'Unknown Museum',
      category: UnicodeFixes.cleanText(specialData['category']) ?? '',
      currentExhibitions: List<String>.from(specialData['currentExhibitions'] ?? []),
      permanentCollections: List<String>.from(specialData['permanentCollections'] ?? []),
      ticketPrice: specialData['ticketPrice'] ?? '',
      imageUrl: json['imageUrl'],
      emoji: UnicodeFixes.getPlaceTypeEmoji('museum', json['emoji']),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      collectionStatus: PlaceCollectionStatus(
        isVisited: collectionStatus['isVisited'] ?? false,
        lastVisit: collectionStatus['lastVisit'] != null
          ? DateTime.parse(collectionStatus['lastVisit']) : null,
        userRating: collectionStatus['userRating']?.toDouble(),
        visitCount: collectionStatus['visitCount'] ?? 0,
      ),
      visits: [], // Visits loaded separately
      info: PlaceInfo(
        address: json['address'] ?? '',
        phone: json['phone'],
        website: json['website'],
        email: json['email'],
        openingHours: Map<String, String>.from(json['openingHours'] ?? {}),
        highlights: List<String>.from(json['highlights'] ?? []),
        priceRange: UnicodeFixes.fixPriceRange(json['priceRange']),
      ),
      hasAudioGuide: specialData['hasAudioGuide'] ?? false,
      hasGiftShop: specialData['hasGiftShop'] ?? false,
      isWheelchairAccessible: specialData['isWheelchairAccessible'] ?? false,
    );
  }
}

extension VisitApi on Visit {
  static Visit fromApiJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'],
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      placeId: json['placeId'],
      placeType: json['placeType'],
      overallRating: json['overallRating']?.toDouble(),
      notes: json['notes'],
      duration: json['durationMinutes'] != null
        ? Duration(minutes: json['durationMinutes']) : null,
      totalCost: json['totalCost']?.toDouble(),
      activities: [], // Activities loaded if needed
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      photoUrls: List<String>.from(json['photoUrls'] ?? []),
      isPublic: json['isPublic'] ?? true,
    );
  }

  Map<String, dynamic> toApiJson() {
    return {
      'userId': userId,
      'placeId': placeId,
      'date': date.toIso8601String(),
      'placeType': placeType,
      'overallRating': overallRating,
      'notes': notes,
      'durationMinutes': duration?.inMinutes,
      'totalCost': totalCost,
      'metadata': metadata,
      'photoUrls': photoUrls,
      'isPublic': isPublic,
      'activities': activities.map((a) => a.toJson()).toList(),
    };
  }
}