// test/models/collection_models_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:collection_app/models/collection_factory.dart';
import 'package:collection_app/models/collection_base.dart';
import 'package:collection_app/models/restaurant_collection.dart';
import 'package:collection_app/models/museum_collection.dart';
import 'package:collection_app/models/location.dart';

void main() {
  group('CollectionFactory Tests', () {
    test('should create McDonald\'s collection with correct properties', () {
      // Act
      final mcdonalds = CollectionFactory.createMcDonalds();

      // Assert
      expect(mcdonalds.name, "McDonald's Filialen");
      expect(mcdonalds.iconEmoji, '🍟');
      expect(mcdonalds.collectionType, 'restaurant');
      expect(mcdonalds.chainName, "McDonald's");
      expect(mcdonalds.brandColor, '#FFC72C');
      expect(mcdonalds.website, 'mcdonalds.de');
      expect(mcdonalds.menuCategories, contains('Burger'));
      expect(mcdonalds.menuCategories, contains('Pommes'));
      expect(mcdonalds.locations, isEmpty);
    });

    test('should create Starbucks collection with correct properties', () {
      // Act
      final starbucks = CollectionFactory.createStarbucks();

      // Assert
      expect(starbucks.name, 'Starbucks Cafés');
      expect(starbucks.iconEmoji, '☕');
      expect(starbucks.collectionType, 'restaurant');
      expect(starbucks.chainName, 'Starbucks');
      expect(starbucks.brandColor, '#00704A');
      expect(starbucks.menuCategories, contains('Kaffee'));
    });

    test('should create Museums collection with correct properties', () {
      // Act
      final museums = CollectionFactory.createMuseums();

      // Assert
      expect(museums.name, 'Museen');
      expect(museums.iconEmoji, '🏛️');
      expect(museums.collectionType, 'museum');
      expect(museums.category, 'mixed');
      expect(museums.ticketInfo, 'Preise variieren je nach Museum');
    });
  });

  group('Collection Progress Tests', () {
    test('should calculate progress correctly with no locations', () {
      // Arrange
      final collection = CollectionFactory.createMcDonalds();

      // Assert
      expect(collection.visitedCount, 0);
      expect(collection.totalCount, 0);
      expect(collection.progressPercentage, 0);
    });

    test('should calculate progress correctly with some visited locations', () {
      // Arrange
      final collection = CollectionFactory.createMcDonalds();
      final locations = [
        _createTestLocation('1', 'Location 1', isVisited: true),
        _createTestLocation('2', 'Location 2', isVisited: false),
        _createTestLocation('3', 'Location 3', isVisited: true),
      ];

      // Füge Locations zur Collection hinzu (wir müssen das Model erweitern)
      final collectionWithLocations = RestaurantCollection(
        id: collection.id,
        name: collection.name,
        iconEmoji: collection.iconEmoji,
        description: collection.description,
        createdAt: collection.createdAt,
        chainName: collection.chainName,
        brandColor: collection.brandColor,
        website: collection.website,
        menuCategories: collection.menuCategories,
        locations: locations,
      );

      // Assert
      expect(collectionWithLocations.visitedCount, 2);
      expect(collectionWithLocations.totalCount, 3);
      expect(collectionWithLocations.progressPercentage, closeTo(66.67, 0.01));
    });
  });

  group('Collection JSON Serialization Tests', () {
    test('should serialize and deserialize McDonald\'s collection correctly', () {
      // Arrange
      final originalCollection = CollectionFactory.createMcDonalds();
      final location = _createTestLocation('loc1', 'Test Location');
      final collectionWithLocation = RestaurantCollection(
        id: originalCollection.id,
        name: originalCollection.name,
        iconEmoji: originalCollection.iconEmoji,
        description: originalCollection.description,
        createdAt: originalCollection.createdAt,
        chainName: originalCollection.chainName,
        brandColor: originalCollection.brandColor,
        website: originalCollection.website,
        menuCategories: originalCollection.menuCategories,
        locations: [location],
      );

      // Act
      final json = collectionWithLocation.toJson();
      final deserializedCollection = CollectionFactory.fromJson(json);

      // Assert
      expect(deserializedCollection.name, originalCollection.name);
      expect(deserializedCollection.collectionType, 'restaurant');
      expect((deserializedCollection as RestaurantCollection).chainName, originalCollection.chainName);
      expect(deserializedCollection.locations.length, 1);
      expect(deserializedCollection.locations.first.name, 'Test Location');
    });

    test('should serialize and deserialize Museum collection correctly', () {
      // Arrange
      final originalCollection = CollectionFactory.createMuseums();

      // Act
      final json = originalCollection.toJson();
      final deserializedCollection = CollectionFactory.fromJson(json);

      // Assert
      expect(deserializedCollection.name, originalCollection.name);
      expect(deserializedCollection.collectionType, 'museum');
      expect((deserializedCollection as MuseumCollection).category, originalCollection.category);
    });

    test('should throw exception for unknown collection type', () {
      // Arrange
      final invalidJson = {
        'collectionType': 'unknown_type',
        'id': 'test',
      };

      // Act & Assert
      expect(() => CollectionFactory.fromJson(invalidJson), throwsException);
    });
  });

  group('Location Tests', () {
    test('should create location with correct properties', () {
      // Act
      final location = _createTestLocation('1', 'Test McDonald\'s');

      // Assert
      expect(location.id, '1');
      expect(location.name, 'Test McDonald\'s');
      expect(location.address, 'Test Street 1, 12345 Test City');
      expect(location.isVisited, false);
      expect(location.visitDate, isNull);
    });

    test('should mark location as visited correctly', () {
      // Arrange
      final location = _createTestLocation('1', 'Test Location');

      // Act
      location.markAsVisited(rating: 5, notes: 'Great place!');

      // Assert
      expect(location.isVisited, true);
      expect(location.visitDate, isNotNull);
      expect(location.userRating, 5);
      expect(location.userNotes, 'Great place!');
    });

    test('should mark location as not visited correctly', () {
      // Arrange
      final location = _createTestLocation('1', 'Test Location');
      location.markAsVisited(rating: 4);

      // Act
      location.markAsNotVisited();

      // Assert
      expect(location.isVisited, false);
      expect(location.visitDate, isNull);
      expect(location.userRating, isNull);
      expect(location.userNotes, isNull);
    });

    test('should calculate distance correctly', () {
      // Arrange
      final location = Location(
        id: '1',
        name: 'Test Location',
        address: 'Test Address',
        latitude: 50.9375, // Köln
        longitude: 6.9603,
      );

      // Act
      final distance = location.distanceToUser(51.0, 7.0); // Nähe Köln

      // Assert
      expect(distance, greaterThan(0));
      expect(distance, lessThan(20)); // Sollte weniger als 20km sein
    });

    test('should format distance correctly', () {
      // Arrange
      final location = Location(
        id: '1',
        name: 'Test Location',
        address: 'Test Address',
        latitude: 50.9375,
        longitude: 6.9603,
      );

      // Act
      final formattedDistance = location.formatDistance(50.9375, 6.9603); // Gleiche Position

      // Assert
      expect(formattedDistance, contains('m')); // Sollte in Metern sein da sehr nah
    });

    test('should get short address correctly', () {
      // Arrange
      final location = _createTestLocation('1', 'Test Location');

      // Act
      final shortAddress = location.shortAddress;

      // Assert
      expect(shortAddress, 'Test Street 1');
    });

    test('should serialize and deserialize location correctly', () {
      // Arrange
      final originalLocation = _createTestLocation('1', 'Test Location');
      originalLocation.markAsVisited(rating: 4, notes: 'Nice place');

      // Act
      final json = originalLocation.toJson();
      final deserializedLocation = Location.fromJson(json);

      // Assert
      expect(deserializedLocation.id, originalLocation.id);
      expect(deserializedLocation.name, originalLocation.name);
      expect(deserializedLocation.isVisited, true);
      expect(deserializedLocation.userRating, 4);
      expect(deserializedLocation.userNotes, 'Nice place');
    });
  });
}

// Helper function für Test-Locations
Location _createTestLocation(String id, String name, {bool isVisited = false}) {
  final location = Location(
    id: id,
    name: name,
    address: 'Test Street 1, 12345 Test City',
    latitude: 50.9375,
    longitude: 6.9603,
    imageUrls: ['https://example.com/image.jpg'],
    features: ['WiFi', 'Drive-Through'],
    phone: '+49 123 456789',
    website: 'example.com',
    openingHours: '08:00-22:00',
    averageRating: 4.2,
    reviewCount: 150,
  );

  if (isVisited) {
    location.markAsVisited(rating: 4);
  }

  return location;
}