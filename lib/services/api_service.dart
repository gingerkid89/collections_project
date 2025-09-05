// lib/services/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/place.dart';
import '../models/restaurant.dart';
import '../models/museum.dart';
import '../models/visit.dart';
import '../models/menu_item.dart';
import 'auth_service.dart';

class ApiService {
  // API Configuration
  static String get baseUrl {
    return 'https://collections-api-production.up.railway.app/api/v1';
  }

  static const Duration _timeout = Duration(seconds: 30); // Railway typically has fast response times
  
  // User ID (matches production database)
  static const String testUserId = 'c1a7b30d-b623-4885-ae0d-b395cdda4b49';
  
  // Auth service instance
  static final AuthService _authService = MockAuthService();

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

  // HTTP Helper Methods
  static Future<Map<String, dynamic>> _get(String endpoint, {bool requireAuth = false}) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      ).timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('GET $endpoint failed: $e');
    }
  }

  static Future<Map<String, dynamic>> _post(String endpoint, Map<String, dynamic> data, {bool requireAuth = false}) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      ).timeout(_timeout);

      return _handleResponse(response);
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

  // Places Endpoints
  static Future<List<Place>> getPlaces({String? type, String? search, int? limit}) async {
    final queryParams = <String, String>{};
    if (type != null) queryParams['type'] = type;
    if (search != null) queryParams['search'] = search;
    if (limit != null) queryParams['limit'] = limit.toString();

    final queryString = queryParams.isNotEmpty 
      ? '?${queryParams.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}'
      : '';

    final result = await _get('/places$queryString');
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

  static Future<List<Place>> getRestaurants() async {
    return getPlaces(type: 'restaurant');
  }

  static Future<List<Place>> getMuseums() async {
    return getPlaces(type: 'museum');
  }

  static Future<Place> getPlace(String placeId) async {
    final result = await _get('/places/$placeId');
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

  static Future<List<MenuItem>> getRestaurantMenu(String restaurantId) async {
    final result = await _get('/places/$restaurantId/menu');
    final menuData = result['data']['menuItems'] as List<dynamic>;

    return menuData.map<MenuItem>((json) => MenuItem.fromJson(json)).toList();
  }

  // User Endpoints (require authentication)
  static Future<List<Place>> getUserPlaces({String? type, bool? visited}) async {
    final queryParams = <String, String>{};
    if (type != null) queryParams['type'] = type;
    if (visited != null) queryParams['visited'] = visited.toString();

    final queryString = queryParams.isNotEmpty 
      ? '?${queryParams.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}'
      : '';

    final result = await _get('/user/$testUserId/places$queryString', requireAuth: true);
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

  static Future<List<Place>> getUserFavorites() async {
    final result = await _get('/user/$testUserId/favorites', requireAuth: true);
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

  static Future<Map<String, dynamic>> getUserStats() async {
    final result = await _get('/user/$testUserId/stats', requireAuth: true);
    return result['data'] as Map<String, dynamic>;
  }

  // Visits Endpoints
  static Future<List<Visit>> getVisits({String? placeId, String? placeType}) async {
    final queryParams = <String, String>{'userId': testUserId};
    if (placeId != null) queryParams['placeId'] = placeId;
    if (placeType != null) queryParams['placeType'] = placeType;

    final queryString = queryParams.entries
      .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
      .join('&');

    final result = await _get('/visits?$queryString');
    final visitsData = result['data'] as List<dynamic>;

    return visitsData.map<Visit>((json) => VisitApi.fromApiJson(json)).toList();
  }

  static Future<Visit> getVisit(String visitId) async {
    final result = await _get('/visits/$visitId');
    return VisitApi.fromApiJson(result['data']);
  }

  static Future<Visit> createVisit(Visit visit) async {
    final visitData = visit.toApiJson();
    final result = await _post('/visits', visitData);
    return VisitApi.fromApiJson(result['data']);
  }

  // Exhibitions Endpoints
  static Future<List<Map<String, dynamic>>> getExhibitions({
    String? museumId, 
    String? type, 
    String? category
  }) async {
    final queryParams = <String, String>{};
    if (museumId != null) queryParams['museumId'] = museumId;
    if (type != null) queryParams['type'] = type;
    if (category != null) queryParams['category'] = category;

    final queryString = queryParams.isNotEmpty 
      ? '?${queryParams.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}'
      : '';

    final result = await _get('/exhibitions$queryString');
    return List<Map<String, dynamic>>.from(result['data']);
  }

  static Future<Map<String, dynamic>> getExhibition(String exhibitionId) async {
    final result = await _get('/exhibitions/$exhibitionId');
    return result['data'] as Map<String, dynamic>;
  }

  static Future<List<Map<String, dynamic>>> getMuseumExhibitions(String museumId) async {
    final result = await _get('/exhibitions/museum/$museumId');
    final exhibitions = result['data']['exhibitions'] as List<dynamic>;
    return List<Map<String, dynamic>>.from(exhibitions);
  }

  // Health Check
  static Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl.replaceAll('/api/v1', '')}/api/health'),
      ).timeout(_timeout);
      
      return jsonDecode(response.body);
    } catch (e) {
      throw ApiException('Health check failed: $e');
    }
  }

  // Search
  static Future<List<Place>> searchPlaces(String query) async {
    return getPlaces(search: query);
  }

  // Create Place
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
}

// Custom Exception Class
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

// Extension to add API JSON methods to models
extension RestaurantApi on Restaurant {
  static Restaurant fromApiJson(Map<String, dynamic> json) {
    // Convert API response to Restaurant model
    final specialData = json['specialData'] as Map<String, dynamic>? ?? {};
    final stats = json['stats'] as Map<String, dynamic>? ?? {};
    final collectionStatus = json['collectionStatus'] as Map<String, dynamic>? ?? {};
    
    return Restaurant(
      id: json['id'],
      name: json['name'],
      cuisine: specialData['cuisine'] ?? '',
      priceCategory: json['priceRange'] ?? '€',
      menu: [], // Menu items loaded separately
      imageUrl: json['imageUrl'],
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
        priceRange: json['priceRange'],
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
      name: json['name'],
      category: specialData['category'] ?? '',
      currentExhibitions: List<String>.from(specialData['currentExhibitions'] ?? []),
      permanentCollections: List<String>.from(specialData['permanentCollections'] ?? []),
      ticketPrice: specialData['ticketPrice'] ?? '',
      imageUrl: json['imageUrl'],
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
        priceRange: json['priceRange'],
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