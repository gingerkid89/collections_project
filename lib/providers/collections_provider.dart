// lib/providers/collections_provider.dart

import 'package:flutter/material.dart';
import '../models/collection_base.dart';
import '../models/collection_factory.dart';
import '../models/location.dart';

class CollectionsProvider with ChangeNotifier {
  List<CollectionBase> _collections = [];
  
  List<CollectionBase> get collections => List.unmodifiable(_collections);
  
  CollectionsProvider() {
    _initializeCollections();
  }
  
  void _initializeCollections() {
    final mcdonalds = CollectionFactory.createMcDonalds();
    final starbucks = CollectionFactory.createStarbucks();
    final museums = CollectionFactory.createMuseums();
    final italianRestaurants = CollectionFactory.createItalianRestaurants();
    final artMuseums = CollectionFactory.createArtMuseums();
    final scienceMuseums = CollectionFactory.createScienceMuseums();

    // Add dummy data to collections
    mcdonalds.locations.addAll([
      Location(
        id: 'mc_1',
        name: "McDonald's Hauptbahnhof",
        address: 'Trankgasse 11, 50667 Köln',
        latitude: 50.9429,
        longitude: 6.9584,
        imageUrls: ['https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=300&h=300&fit=crop'],
        features: ['Drive-Through', 'McCafé', '24h Service'],
        averageRating: 4.2,
        isVisited: true,
      ),
      Location(
        id: 'mc_2',
        name: "McDonald's Schildergasse",
        address: 'Schildergasse 65, 50667 Köln',
        latitude: 50.9364,
        longitude: 6.9528,
        imageUrls: ['https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=300&h=300&fit=crop'],
        features: ['McCafé', 'WiFi'],
        averageRating: 4.0,
        isVisited: true,
      ),
      Location(
        id: 'mc_3',
        name: "McDonald's Neumarkt",
        address: 'Neumarkt 1c, 50667 Köln',
        latitude: 50.9333,
        longitude: 6.9472,
        imageUrls: ['https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=300&h=300&fit=crop'],
        features: ['Playground', 'WiFi'],
        averageRating: 4.1,
      ),
    ]);

    starbucks.locations.addAll([
      Location(
        id: 'sb_1',
        name: 'Starbucks Schildergasse',
        address: 'Schildergasse 85-87, 50667 Köln',
        latitude: 50.9375,
        longitude: 6.9533,
        imageUrls: ['https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=300&h=300&fit=crop'],
        features: ['WiFi', 'Outdoor Seating', 'Mobile Order'],
        averageRating: 4.3,
        isVisited: true,
      ),
      Location(
        id: 'sb_2',
        name: 'Starbucks Hohe Straße',
        address: 'Hohe Str. 52, 50667 Köln',
        latitude: 50.9391,
        longitude: 6.9578,
        imageUrls: ['https://images.unsplash.com/photo-1506372023823-671ca4d13895?w=300&h=300&fit=crop'],
        features: ['WiFi', 'Drive-Through'],
        averageRating: 4.1,
      ),
      Location(
        id: 'sb_3',
        name: 'Starbucks Ehrenstraße',
        address: 'Ehrenstr. 89, 50672 Köln',
        latitude: 50.9323,
        longitude: 6.9311,
        imageUrls: ['https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=300&h=300&fit=crop'],
        features: ['WiFi', 'Student Discount'],
        averageRating: 4.0,
        isVisited: true,
      ),
    ]);

    museums.locations.addAll([
      Location(
        id: 'cologne_cathedral',
        name: 'Cologne Cathedral',
        address: 'Domkloster 4, 50667 Köln',
        latitude: 50.9413,
        longitude: 6.9583,
        imageUrls: ['https://images.unsplash.com/photo-1539650116574-75c0c6d04e6a?w=300&h=300&fit=crop'],
        features: ['Gothic Architecture', 'UNESCO World Heritage', 'Tower Climb'],
        averageRating: 4.8,
        isVisited: true,
      ),
      Location(
        id: 'romano_germanic_museum',
        name: 'Romano-Germanic Museum',
        address: 'Roncalliplatz 4, 50667 Köln',
        latitude: 50.9404,
        longitude: 6.9589,
        imageUrls: ['https://images.unsplash.com/photo-1594736797933-d0710ba87a0f?w=300&h=300&fit=crop'],
        features: ['Roman Artifacts', 'Archaeological Exhibits', 'Ancient History'],
        averageRating: 4.4,
      ),
    ]);

    italianRestaurants.locations.addAll([
      Location(
        id: 'italian_1',
        name: 'La Società',
        address: 'Kyffhäuserstr. 44, 50674 Köln',
        latitude: 50.9245,
        longitude: 6.9311,
        imageUrls: ['https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=300&h=300&fit=crop'],
        features: ['Authentic Italian', 'Wine Selection', 'Romantic Atmosphere'],
        averageRating: 4.6,
        isVisited: true,
      ),
      Location(
        id: 'italian_2',
        name: 'Piazza Beppe',
        address: 'Aachener Str. 1, 50674 Köln',
        latitude: 50.9284,
        longitude: 6.9156,
        imageUrls: ['https://images.unsplash.com/photo-1571997478779-2adcbbe9ab2f?w=300&h=300&fit=crop'],
        features: ['Pizza', 'Pasta', 'Outdoor Terrace'],
        averageRating: 4.4,
      ),
      Location(
        id: 'italian_3',
        name: 'Osteria 181',
        address: 'Bonner Str. 181, 50677 Köln',
        latitude: 50.9178,
        longitude: 6.9611,
        imageUrls: ['https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=300&h=300&fit=crop'],
        features: ['Fresh Pasta', 'Local Ingredients', 'Cozy Interior'],
        averageRating: 4.7,
        isVisited: true,
      ),
    ]);

    artMuseums.locations.addAll([
      Location(
        id: 'wallraf_richartz',
        name: 'Wallraf-Richartz Museum',
        address: 'Obenmarspforten 40, 50667 Köln',
        latitude: 50.9378,
        longitude: 6.9556,
        imageUrls: ['https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=300&h=300&fit=crop'],
        features: ['Medieval Art', 'Impressionist Paintings', 'European Masters'],
        averageRating: 4.5,
        isVisited: true,
      ),
      Location(
        id: 'museum_ludwig',
        name: 'Museum Ludwig',
        address: 'Heinrich-Böll-Platz, 50667 Köln',
        latitude: 50.9406,
        longitude: 6.9608,
        imageUrls: ['https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=300&h=300&fit=crop'],
        features: ['Modern Art', 'Pop Art', 'Photography'],
        averageRating: 4.4,
      ),
      Location(
        id: 'kolumba_museum',
        name: 'Kolumba Art Museum',
        address: 'Kolumbastr. 4, 50667 Köln',
        latitude: 50.9389,
        longitude: 6.9533,
        imageUrls: ['https://images.unsplash.com/photo-1566127678451-79356c4f3bd3?w=300&h=300&fit=crop'],
        features: ['Contemporary Art', 'Archaeological Finds', 'Unique Architecture'],
        averageRating: 4.6,
        isVisited: true,
      ),
    ]);

    scienceMuseums.locations.addAll([
      Location(
        id: 'science_museum_1',
        name: 'Odysseum Köln',
        address: 'Corintostr. 1, 51103 Köln',
        latitude: 50.8901,
        longitude: 7.0156,
        imageUrls: ['https://images.unsplash.com/photo-1581833971358-2c8b550f87b3?w=300&h=300&fit=crop'],
        features: ['Interactive', 'Planetarium', 'Family Friendly'],
        averageRating: 4.5,
        isVisited: true,
      ),
      Location(
        id: 'science_museum_2',
        name: 'Deutsches Sport & Olympia Museum',
        address: 'Im Zollhafen 1, 50678 Köln',
        latitude: 50.9267,
        longitude: 6.9656,
        imageUrls: ['https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=300&h=300&fit=crop'],
        features: ['Sports History', 'Olympics', 'Interactive'],
        averageRating: 4.3,
      ),
      Location(
        id: 'science_museum_3',
        name: 'Imhoff Chocolate Museum',
        address: 'Am Schokoladenmuseum 1A, 50678 Köln',
        latitude: 50.9312,
        longitude: 6.9689,
        imageUrls: ['https://images.unsplash.com/photo-1481391319762-47dff72954d9?w=300&h=300&fit=crop'],
        features: ['Chocolate Making', 'Tastings', 'Gift Shop'],
        averageRating: 4.6,
      ),
    ]);

    _collections = [
      mcdonalds,
      starbucks,
      museums,
      italianRestaurants,
      artMuseums,
      scienceMuseums,
    ];
  }
  
  CollectionBase? getCollectionById(String id) {
    try {
      return _collections.firstWhere((collection) => collection.id == id);
    } catch (e) {
      return null;
    }
  }
  
  void addLocationToCollection(String collectionId, Location location) {
    final collection = getCollectionById(collectionId);
    if (collection != null) {
      collection.locations.add(location);
      notifyListeners();
    }
  }
  
  void removeLocationFromCollection(String collectionId, String locationId) {
    final collection = getCollectionById(collectionId);
    if (collection != null) {
      collection.locations.removeWhere((loc) => loc.id == locationId);
      notifyListeners();
    }
  }
  
  List<CollectionBase> getRestaurantCompatibleCollections() {
    return _collections.where((collection) => 
      collection.name.toLowerCase().contains('restaurant') || 
      collection.name.toLowerCase().contains('mcdonald') ||
      collection.name.toLowerCase().contains('starbucks') ||
      collection.name.toLowerCase().contains('italian')
    ).toList();
  }
  
  List<CollectionBase> getMuseumCompatibleCollections() {
    return _collections.where((collection) => 
      collection.name.toLowerCase().contains('museum') || 
      collection.name.toLowerCase().contains('art') ||
      collection.name.toLowerCase().contains('science')
    ).toList();
  }
}