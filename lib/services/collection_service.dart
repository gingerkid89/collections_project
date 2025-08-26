import '../models/collection_base.dart';
import '../models/place.dart';
import '../models/location.dart';
import 'api_simulation.dart';

class CollectionService {
  static final CollectionService _instance = CollectionService._internal();
  factory CollectionService() => _instance;
  CollectionService._internal();

  final ApiSimulation _apiService = ApiSimulation();

  /// Find all collections that contain a specific place/location
  Future<List<CollectionBase>> getCollectionsContainingPlace(Place place) async {
    try {
      final collections = <CollectionBase>[];
      
      // Get McDonald's collection and check if place is in it
      final mcDonaldsCollection = await _apiService.getMcDonaldsCollection();
      final mcDonaldsLocations = await _apiService.getMcDonaldsLocations();
      
      // Check if the place matches any McDonald's location
      final isInMcDonalds = _isPlaceInLocations(place, mcDonaldsLocations);
      if (isInMcDonalds) {
        collections.add(mcDonaldsCollection);
      }

      // Get Museums collection and check if place is in it
      try {
        final museumsCollection = await _apiService.getMuseumsCollection();
        final museumLocations = await _apiService.getMuseumLocations();
        
        final isInMuseums = _isPlaceInLocations(place, museumLocations);
        if (isInMuseums) {
          collections.add(museumsCollection);
        }
      } catch (e) {
        // Museums collection might not exist, continue
      }

      return collections;
    } catch (e) {
      print('Error getting collections for place: $e');
      return [];
    }
  }

  /// Check if a place matches any location in the list
  bool _isPlaceInLocations(Place place, List<Location> locations) {
    // Try to match by name first (most reliable)
    for (final location in locations) {
      if (location.name.toLowerCase() == place.name.toLowerCase()) {
        return true;
      }
    }
    
    // Try to match by ID if available
    for (final location in locations) {
      if (location.id == place.id) {
        return true;
      }
    }
    
    // For restaurants, try to match by partial name (McDonald's variants)
    if (place.type.toLowerCase() == 'restaurant') {
      final placeName = place.name.toLowerCase();
      for (final location in locations) {
        final locationName = location.name.toLowerCase();
        
        // Check if both contain "mcdonald" or similar variations
        if ((placeName.contains('mcdonald') && locationName.contains('mcdonald')) ||
            (placeName.contains('mc donald') && locationName.contains('mc donald'))) {
          // Additional check for location similarity (same area/street)
          if (_areLocationsSimilar(placeName, locationName)) {
            return true;
          }
        }
      }
    }
    
    return false;
  }

  /// Check if two location names refer to similar places
  bool _areLocationsSimilar(String name1, String name2) {
    // Remove common prefixes/suffixes
    final clean1 = name1
        .replaceAll(RegExp(r'mcdonald[s]*\s*'), '')
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .trim();
    final clean2 = name2
        .replaceAll(RegExp(r'mcdonald[s]*\s*'), '')
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .trim();
    
    if (clean1.isEmpty || clean2.isEmpty) return false;
    
    // Check if one name contains key words from the other
    final words1 = clean1.split(' ');
    final words2 = clean2.split(' ');
    
    for (final word1 in words1) {
      if (word1.length > 3) { // Only check meaningful words
        for (final word2 in words2) {
          if (word2.length > 3 && 
              (word1.contains(word2) || word2.contains(word1))) {
            return true;
          }
        }
      }
    }
    
    return false;
  }

  /// Get a collection by ID (utility method)
  Future<CollectionBase?> getCollectionById(String collectionId) async {
    try {
      // Check McDonald's collection
      final mcDonaldsCollection = await _apiService.getMcDonaldsCollection();
      if (mcDonaldsCollection.id == collectionId) {
        return mcDonaldsCollection;
      }

      // Check Museums collection
      try {
        final museumsCollection = await _apiService.getMuseumsCollection();
        if (museumsCollection.id == collectionId) {
          return museumsCollection;
        }
      } catch (e) {
        // Museums collection might not exist
      }

      return null;
    } catch (e) {
      print('Error getting collection by ID: $e');
      return null;
    }
  }
}