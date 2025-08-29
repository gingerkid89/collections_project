// lib/providers/collections_provider.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/collection_base.dart';
import '../models/location.dart';
import '../services/api_service.dart';
import '../factories/place_factory.dart';
import '../models/place.dart';
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
  
  List<CollectionBase> get collections => List.unmodifiable(_collections);
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  CollectionsProvider() {
    _initializeCollections();
  }
  
  Future<void> _initializeCollections() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Fetch collections directly from database API
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/collections'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final collectionsJson = data['data'] as List;
          
          _collections = collectionsJson.map((collectionData) => 
            DatabaseCollectionAdapter.fromJson(collectionData)
          ).toList();
          
          _isLoading = false;
          notifyListeners();
        } else {
          throw Exception('API returned error: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load collections: HTTP ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _collections = []; // Fallback to empty list
      notifyListeners();
    }
  }
  
  /// Refresh collections from API
  Future<void> refresh() async {
    await _initializeCollections();
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
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/collections/$collectionId/places'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final placesJson = data['data'] as List;
          return PlaceFactory.fromJsonList(placesJson);
        } else {
          throw Exception('API returned error: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load collection places: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading collection places: $e');
      return [];
    }
  }
}