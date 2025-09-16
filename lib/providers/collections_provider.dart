// lib/providers/collections_provider.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/collection_base.dart';
import '../models/location.dart';
import '../services/enhanced_api_service.dart';
import '../services/auth_service.dart';
import '../factories/place_factory.dart';
import '../models/place.dart';
import '../providers/visits_provider.dart';
/// Database Collection adapter that implements CollectionBase interface
class DatabaseCollectionAdapter extends CollectionBase {
  DatabaseCollectionAdapter({
    required super.id,
    required super.name,
    required super.description,
    required super.iconEmoji,
    required super.color,
    required super.locations,
    required super.createdAt,
    required this.isSystemGenerated,
    required this.colorHex,
    required int totalCount,
    required int visitedCount,
  }) : _totalCount = totalCount, _visitedCount = visitedCount;

  final bool isSystemGenerated;
  final String? colorHex;
  final int _totalCount;
  final int _visitedCount;

  @override
  int get totalCount => _totalCount;

  @override
  int get visitedCount => _visitedCount;

  @override
  String get collectionType => 'database';

  @override
  Map<String, dynamic> get specificProperties => {
    'source': 'database',
    'isSystemGenerated': isSystemGenerated,
    'colorHex': colorHex,
  };

  factory DatabaseCollectionAdapter.fromJson(Map<String, dynamic> json) {
    return DatabaseCollectionAdapter(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      iconEmoji: json['iconEmoji'] ?? '📍',
      color: _parseColor(json['colorHex']),
      locations: [], // Locations loaded on-demand via getCollectionPlaces()
      createdAt: DateTime.parse(json['createdAt']),
      isSystemGenerated: json['isSystemGenerated'] ?? false,
      colorHex: json['colorHex'],
      totalCount: json['totalCount'] ?? 0,
      visitedCount: json['visitedCount'] ?? 0,
    );
  }

  static Color _parseColor(String? colorHex) {
    if (colorHex == null) return Colors.blue;
    try {
      return Color(int.parse(colorHex.substring(1, 7), radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.blue;
    }
  }
}

class CollectionsProvider with ChangeNotifier {
  List<CollectionBase> _collections = [];
  bool _isLoading = false;
  String? _error;
  VisitsProvider? _visitsProvider;
  
  List<CollectionBase> get collections => List.unmodifiable(_collections);
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Set visits provider for syncing visit data
  void setVisitsProvider(VisitsProvider visitsProvider) {
    _visitsProvider = visitsProvider;
  }
  
  CollectionsProvider() {
    _initializeCollections();
  }
  
  Future<void> _initializeCollections() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Ensure authentication first
      await _ensureAuthenticated();
      
      // Fetch real collections from the API
      final collectionsData = await EnhancedApiService.getCollections();
      
      _collections = collectionsData.map((json) => DatabaseCollectionAdapter.fromJson(json)).toList();
      
      _isLoading = false;
      notifyListeners();
      
      print('Loaded ${_collections.length} collections from database');
      
    } catch (e) {
      print('Error loading collections: $e');
      _error = e.toString();
      _isLoading = false;
      
      // Fallback to empty list if API fails
      _collections = [];
      notifyListeners();
    }
  }
  
  /// Refresh collections from API
  Future<void> refresh() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Ensure authentication first
      await _ensureAuthenticated();

      // Force refresh from API, bypass cache
      final collectionsData = await EnhancedApiService.getCollections(forceRefresh: true);

      _collections = collectionsData.map((json) => DatabaseCollectionAdapter.fromJson(json)).toList();

      _isLoading = false;
      notifyListeners();

      print('Refreshed ${_collections.length} collections from API');

    } catch (e) {
      print('Error refreshing collections: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Alias for refresh() method - refresh all collections from API
  Future<void> refreshAllCollections() async {
    await refresh();
  }
  
  /// Ensure user is authenticated for API calls
  Future<void> _ensureAuthenticated() async {
    final authService = MockAuthService();
    final isSignedIn = await authService.isSignedIn();
    
    if (!isSignedIn) {
      print('User not authenticated, attempting auto-login...');
      try {
        await authService.signInWithEmail('user@web.com', '123456');
        print('Auto-login successful');
      } catch (e) {
        print('Auto-login failed: $e');
      }
    }
  }
  
  /// Get collection by ID
  CollectionBase? getCollectionById(String id) {
    try {
      return _collections.firstWhere((collection) => collection.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Add location to a collection
  void addLocationToCollection(String collectionId, Location location) {
    final collection = getCollectionById(collectionId);
    if (collection != null) {
      collection.locations.add(location);
      notifyListeners();
    }
  }
  
  /// Remove location from a collection
  void removeLocationFromCollection(String collectionId, String locationId) {
    final collection = getCollectionById(collectionId);
    if (collection != null) {
      collection.locations.removeWhere((loc) => loc.id == locationId);
      notifyListeners();
    }
  }
  
  
  /// Load places for a specific collection
  Future<List<Place>> getCollectionPlaces(String collectionId) async {
    try {
      print('🔍 Loading places for collection: $collectionId');
      
      // Use the new collections API endpoint to get places for this collection
      final places = await EnhancedApiService.getCollectionPlaces(collectionId);
      
      print('📍 Loaded ${places.length} places from API for collection $collectionId');
      for (var place in places) {
        print('   - ${place.name} (${place.type})');
      }
      
      // Sync places with local visit data if visits provider is available
      if (_visitsProvider != null) {
        final syncedPlaces = _syncPlacesWithVisitData(places);
        print('✅ Synced places with visit data: ${syncedPlaces.length} places');
        return syncedPlaces;
      }
      
      print('✅ Returning ${places.length} places without visit sync');
      return places;
    } catch (e) {
      print('❌ Error loading collection places: $e');
      return [];
    }
  }
  
  /// Sync places with local visit data to ensure accurate collection status
  List<Place> _syncPlacesWithVisitData(List<Place> places) {
    return places.map((place) {
      final hasVisited = _visitsProvider!.hasVisited(place.id);
      final visitCount = _visitsProvider!.getVisitCount(place.id);
      final lastVisit = _visitsProvider!.getLastVisitDate(place.id);
      final averageRating = _visitsProvider!.getAverageRating(place.id);
      
      // Update collection status with local visit data
      final updatedCollectionStatus = PlaceCollectionStatus(
        isVisited: hasVisited,
        lastVisit: lastVisit,
        userRating: averageRating,
        visitCount: visitCount,
      );
      
      // Return updated place with synced collection status
      return place.copyWith(collectionStatus: updatedCollectionStatus);
    }).toList();
  }
  
}