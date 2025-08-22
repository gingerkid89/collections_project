// lib/screens/place_detail_factory.dart

import 'package:flutter/material.dart';
import '../models/place.dart';
import '../models/restaurant.dart';
import '../models/museum.dart';
import 'place_detail_implementations/restaurant_detail_view.dart';
// import 'place_detail_implementations/museum_detail_view.dart';

class PlaceDetailFactory {
  static Widget createDetailView(Place place) {
    switch (place.type.toLowerCase()) {
      case 'restaurant':
        return RestaurantDetailView(restaurant: place as Restaurant);
      case 'museum':
        // return MuseumDetailView(museum: place as Museum);
        return _createPlaceholderView(place);
      default:
        throw UnsupportedError('Place type "${place.type}" not supported');
    }
  }

  static Widget _createPlaceholderView(Place place) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place.name),
        backgroundColor: place.type == 'restaurant' ? Colors.green : Colors.purple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              place.emoji,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              place.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Detail view for ${place.type}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              'Full detail view coming soon!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  static List<String> get supportedPlaceTypes => [
    'restaurant',
    'museum',
  ];

  static bool isSupported(String placeType) {
    return supportedPlaceTypes.contains(placeType.toLowerCase());
  }
}