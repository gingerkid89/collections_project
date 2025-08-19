// lib/models/collection_base.dart
import 'location.dart';

/// Abstraktes Interface für alle Collection-Typen
abstract class CollectionBase {
  final String id;
  final String name;
  final String iconEmoji;
  final String description;
  final DateTime createdAt;
  final List<Location> locations;

  CollectionBase({
    required this.id,
    required this.name,
    required this.iconEmoji,
    required this.description,
    required this.createdAt,
    required this.locations,
  });

  /// Abstrakte Methoden die jede Collection implementieren muss
  String get collectionType;
  Map<String, dynamic> get specificProperties;

  /// Standard-Implementierungen die alle Collections haben
  int get visitedCount => locations.where((l) => l.isVisited).length;
  int get totalCount => locations.length;
  double get progressPercentage => totalCount > 0 ? (visitedCount / totalCount) * 100 : 0;

  /// Serialisierung
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'iconEmoji': iconEmoji,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'collectionType': collectionType,
    'specificProperties': specificProperties,
    'locations': locations.map((l) => l.toJson()).toList(),
  };
}