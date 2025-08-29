// lib/models/restaurant.dart

import 'place.dart';
import 'visit.dart';
import 'menu_item.dart';

class Restaurant implements Place {
  @override
  final String id;
  @override
  final String name;
  @override
  final String type;
  @override
  final String emoji;
  @override
  final String? imageUrl;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final PlaceCollectionStatus collectionStatus;
  @override
  final List<Visit> visits;
  @override
  final PlaceInfo info;

  final String cuisine;
  final String priceCategory; // €, €€, €€€
  final List<MenuItem> menu;
  final bool hasReservation;
  final bool hasDelivery;
  final bool hasTakeout;

  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.priceCategory,
    required this.menu,
    required this.collectionStatus,
    required this.visits,
    required this.info,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.hasReservation = false,
    this.hasDelivery = false,
    this.hasTakeout = false,
  }) : type = 'restaurant', emoji = '🍽️';

  @override
  Map<String, dynamic> get specialData => {
    'cuisine': cuisine,
    'priceCategory': priceCategory,
    'menu': menu.map((item) => item.toJson()).toList(),
    'hasReservation': hasReservation,
    'hasDelivery': hasDelivery,
    'hasTakeout': hasTakeout,
  };

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'emoji': emoji,
      'imageUrl': imageUrl,
      'collectionStatus': collectionStatus.toJson(),
      'visits': visits.map((visit) => visit.toJson()).toList(),
      'info': info.toJson(),
      'specialData': specialData,
    };
  }

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    final specialData = json['specialData'] as Map<String, dynamic>;
    return Restaurant(
      id: json['id'],
      name: json['name'],
      cuisine: specialData['cuisine'] ?? '',
      priceCategory: specialData['priceCategory'] ?? '€',
      menu: (specialData['menu'] as List<dynamic>?)
          ?.map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      imageUrl: json['imageUrl'],
      collectionStatus: PlaceCollectionStatus.fromJson(json['collectionStatus']),
      visits: (json['visits'] as List<dynamic>?)
          ?.map((visit) => Visit.fromJson(visit as Map<String, dynamic>))
          .toList() ?? [],
      info: PlaceInfo.fromJson(json['info']),
      hasReservation: specialData['hasReservation'] ?? false,
      hasDelivery: specialData['hasDelivery'] ?? false,
      hasTakeout: specialData['hasTakeout'] ?? false,
    );
  }

  @override
  Restaurant copyWith({
    String? id,
    String? name,
    String? type,
    String? emoji,
    String? imageUrl,
    double? latitude,
    double? longitude,
    PlaceCollectionStatus? collectionStatus,
    List<Visit>? visits,
    PlaceInfo? info,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      cuisine: cuisine,
      priceCategory: priceCategory,
      menu: menu,
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      collectionStatus: collectionStatus ?? this.collectionStatus,
      visits: visits ?? this.visits,
      info: info ?? this.info,
      hasReservation: hasReservation,
      hasDelivery: hasDelivery,
      hasTakeout: hasTakeout,
    );
  }
}