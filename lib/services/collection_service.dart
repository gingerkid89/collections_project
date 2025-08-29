import '../models/collection_base.dart';
import '../factories/place_factory.dart';
import '../providers/collections_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';
import '../models/place.dart';

class CollectionService {
  static final CollectionService _instance = CollectionService._internal();
  factory CollectionService() => _instance;
  CollectionService._internal();

  /// Find all collections that contain a specific place/location
  Future<List<CollectionBase>> getCollectionsContainingPlace(Place place) async {
    try {
      final collectionsProvider = CollectionsProvider();
      await collectionsProvider.refresh(); // Ensure collections are loaded
      
      final allCollections = collectionsProvider.collections;
      final matchingCollections = <CollectionBase>[];
      
      // Check each collection to see if it contains this place
      for (final collection in allCollections) {
        final places = await collectionsProvider.getCollectionPlaces(collection.id);
        final containsPlace = places.any((p) => p.id == place.id);
        if (containsPlace) {
          matchingCollections.add(collection);
        }
      }

      return matchingCollections;
    } catch (e) {
      print('Error getting collections for place: $e');
      return [];
    }
  }

  /// Get a collection by ID (utility method)
  Future<CollectionBase?> getCollectionById(String collectionId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/collections/$collectionId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return DatabaseCollectionAdapter.fromJson(data['data']);
        }
      }

      return null;
    } catch (e) {
      print('Error getting collection by ID: $e');
      return null;
    }
  }
  
  /// Get places for a specific collection by ID
  Future<List<Place>> getCollectionPlaces(String collectionId) async {
    try {
      final collectionsProvider = CollectionsProvider();
      return await collectionsProvider.getCollectionPlaces(collectionId);
    } catch (e) {
      print('Error getting collection places: $e');
      return [];
    }
  }
}