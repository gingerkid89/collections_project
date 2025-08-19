// lib/models/collection_factory.dart
import 'collection_base.dart';
import 'restaurant_collection.dart';
import 'museum_collection.dart';

/// Factory für verschiedene Collection-Typen
class CollectionFactory {
  static CollectionBase fromJson(Map<String, dynamic> json) {
    switch (json['collectionType']) {
      case 'restaurant':
        return RestaurantCollection.fromJson(json);
      case 'museum':
        return MuseumCollection.fromJson(json);
      default:
        throw Exception('Unknown collection type: ${json['collectionType']}');
    }
  }

  static RestaurantCollection createMcDonalds() {
    return RestaurantCollection(
      id: 'mcdonalds_001',
      name: "McDonald's Filialen",
      iconEmoji: '🍟',
      description: 'Sammle alle McDonald\'s Restaurants in deiner Region',
      createdAt: DateTime.now(),
      chainName: "McDonald's",
      brandColor: '#FFC72C',
      website: 'mcdonalds.de',
      menuCategories: ['Burger', 'Pommes', 'McCafé', 'Salate', 'Desserts'],
      locations: [], // Werden später hinzugefügt
    );
  }

  static RestaurantCollection createStarbucks() {
    return RestaurantCollection(
      id: 'starbucks_001',
      name: 'Starbucks Cafés',
      iconEmoji: '☕',
      description: 'Entdecke alle Starbucks Locations',
      createdAt: DateTime.now(),
      chainName: 'Starbucks',
      brandColor: '#00704A',
      website: 'starbucks.de',
      menuCategories: ['Kaffee', 'Frappuccino', 'Tee', 'Snacks'],
      locations: [],
    );
  }

  static MuseumCollection createMuseums() {
    return MuseumCollection(
      id: 'museums_001',
      name: 'Museen',
      iconEmoji: '🏛️',
      description: 'Besuche Museen und Ausstellungen',
      createdAt: DateTime.now(),
      category: 'mixed',
      ticketInfo: 'Preise variieren je nach Museum',
      locations: [],
    );
  }
}