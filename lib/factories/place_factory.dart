// lib/factories/place_factory.dart

import '../models/place.dart';
import '../models/restaurant.dart';
import '../models/museum.dart';

class PlaceFactory {
  static Place fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;

    switch (type.toLowerCase()) {
      case 'restaurant':
        return Restaurant.fromJson(json);
      case 'museum':
        return Museum.fromJson(json);
      default:
        throw UnsupportedError('Place type "$type" not supported');
    }
  }

  // Helper method to parse list of places from JSON
  static List<Place> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => fromJson(json as Map<String, dynamic>)).toList();
  }

  static List<String> get supportedTypes => [
    'restaurant',
    'museum',
    // 'park',
  ];
}