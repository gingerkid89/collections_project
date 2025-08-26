
// lib/models/museum_collection.dart
import 'package:flutter/material.dart';
import 'collection_base.dart';
import 'location.dart';

/// Spezifische Implementierung für Museen
class MuseumCollection extends CollectionBase {
  final String category; // 'art', 'history', 'science', etc.
  final List<String> exhibitions;
  final String ticketInfo;

  MuseumCollection({
    required super.id,
    required super.name,
    required super.iconEmoji,
    required super.description,
    required super.createdAt,
    required super.locations,
    required super.color,
    required this.category,
    this.exhibitions = const [],
    this.ticketInfo = '',
  });

  @override
  String get collectionType => 'museum';

  @override
  Map<String, dynamic> get specificProperties => {
    'category': category,
    'exhibitions': exhibitions,
    'ticketInfo': ticketInfo,
  };

  factory MuseumCollection.fromJson(Map<String, dynamic> json) {
    return MuseumCollection(
      id: json['id'],
      name: json['name'],
      iconEmoji: json['iconEmoji'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      color: Color(json['color'] ?? 0xFF6366F1),
      category: json['specificProperties']['category'],
      exhibitions: List<String>.from(json['specificProperties']['exhibitions'] ?? []),
      ticketInfo: json['specificProperties']['ticketInfo'] ?? '',
      locations: (json['locations'] as List).map((l) => Location.fromJson(l)).toList(),
    );
  }
}