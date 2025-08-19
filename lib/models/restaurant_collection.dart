// lib/models/restaurant_collection.dart
import 'collection_base.dart';
import 'location.dart';

/// Spezifische Implementierung für Restaurant-Ketten
class RestaurantCollection extends CollectionBase {
  final String chainName;
  final String brandColor;
  final String website;
  final List<String> menuCategories;

  RestaurantCollection({
    required super.id,
    required super.name,
    required super.iconEmoji,
    required super.description,
    required super.createdAt,
    required super.locations,
    required this.chainName,
    required this.brandColor,
    required this.website,
    this.menuCategories = const [],
  });

  @override
  String get collectionType => 'restaurant';

  @override
  Map<String, dynamic> get specificProperties => {
    'chainName': chainName,
    'brandColor': brandColor,
    'website': website,
    'menuCategories': menuCategories,
  };

  factory RestaurantCollection.fromJson(Map<String, dynamic> json) {
    return RestaurantCollection(
      id: json['id'],
      name: json['name'],
      iconEmoji: json['iconEmoji'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      chainName: json['specificProperties']['chainName'],
      brandColor: json['specificProperties']['brandColor'],
      website: json['specificProperties']['website'],
      menuCategories: List<String>.from(json['specificProperties']['menuCategories'] ?? []),
      locations: (json['locations'] as List).map((l) => Location.fromJson(l)).toList(),
    );
  }
}