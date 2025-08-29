// lib/models/place.dart

import 'visit.dart';

// ================================
// PLACE INTERFACE
// ================================

abstract class Place {
  String get id;
  String get name;
  String get type; // "Restaurant", "Museum", "Park"
  String get emoji;
  String? get imageUrl;
  double? get latitude;
  double? get longitude;
  PlaceCollectionStatus get collectionStatus;
  List<Visit> get visits;
  PlaceInfo get info;

  // Spezifische Daten je Place-Typ
  Map<String, dynamic> get specialData;

  // Gemeinsame Methoden
  Map<String, dynamic> toJson();
  Place copyWith({
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
  });
}

// ================================
// PLACE FACTORY (moved to lib/factories/place_factory.dart)
// ================================

// ================================
// COLLECTABLE ITEM INTERFACE
// ================================

abstract class CollectableItem {
  String get id;
  String get name;
  String get category;
  bool get isCollectedByUser;
  bool get isOnWishlist;
  double? get userRating;

  Map<String, dynamic> toJson();
  CollectableItem copyWith({
    bool? isCollectedByUser,
    bool? isOnWishlist,
    double? userRating,
  });
}

// ================================
// PLACE COLLECTION STATUS
// ================================

class PlaceCollectionStatus {
  final bool isVisited;
  final DateTime? lastVisit;
  final double? userRating;
  final int visitCount;

  const PlaceCollectionStatus({
    required this.isVisited,
    this.lastVisit,
    this.userRating,
    required this.visitCount,
  });

  factory PlaceCollectionStatus.fromJson(Map<String, dynamic> json) {
    return PlaceCollectionStatus(
      isVisited: json['isVisited'] ?? false,
      lastVisit: json['lastVisit'] != null ? DateTime.parse(json['lastVisit']) : null,
      userRating: json['userRating']?.toDouble(),
      visitCount: json['visitCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isVisited': isVisited,
      'lastVisit': lastVisit?.toIso8601String(),
      'userRating': userRating,
      'visitCount': visitCount,
    };
  }

  PlaceCollectionStatus copyWith({
    bool? isVisited,
    DateTime? lastVisit,
    double? userRating,
    int? visitCount,
  }) {
    return PlaceCollectionStatus(
      isVisited: isVisited ?? this.isVisited,
      lastVisit: lastVisit ?? this.lastVisit,
      userRating: userRating ?? this.userRating,
      visitCount: visitCount ?? this.visitCount,
    );
  }

  // Factory für neuen Ort (noch nicht besucht)
  factory PlaceCollectionStatus.notVisited() {
    return const PlaceCollectionStatus(
      isVisited: false,
      visitCount: 0,
    );
  }

  // Factory für besuchten Ort
  factory PlaceCollectionStatus.visited({
    required DateTime lastVisit,
    double? userRating,
    required int visitCount,
  }) {
    return PlaceCollectionStatus(
      isVisited: true,
      lastVisit: lastVisit,
      userRating: userRating,
      visitCount: visitCount,
    );
  }
}

// ================================
// PLACE INFO
// ================================

class PlaceInfo {
  final String address;
  final String? phone;
  final String? website;
  final String? email;
  final Map<String, String> openingHours; // "monday": "09:00-18:00"
  final List<String> highlights;
  final String? priceRange;

  const PlaceInfo({
    required this.address,
    this.phone,
    this.website,
    this.email,
    this.openingHours = const {},
    this.highlights = const [],
    this.priceRange,
  });

  factory PlaceInfo.fromJson(Map<String, dynamic> json) {
    return PlaceInfo(
      address: json['address'] ?? '',
      phone: json['phone'],
      website: json['website'],
      email: json['email'],
      openingHours: Map<String, String>.from(json['openingHours'] ?? {}),
      highlights: List<String>.from(json['highlights'] ?? []),
      priceRange: json['priceRange'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'phone': phone,
      'website': website,
      'email': email,
      'openingHours': openingHours,
      'highlights': highlights,
      'priceRange': priceRange,
    };
  }

  PlaceInfo copyWith({
    String? address,
    String? phone,
    String? website,
    String? email,
    Map<String, String>? openingHours,
    List<String>? highlights,
    String? priceRange,
  }) {
    return PlaceInfo(
      address: address ?? this.address,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      email: email ?? this.email,
      openingHours: openingHours ?? this.openingHours,
      highlights: highlights ?? this.highlights,
      priceRange: priceRange ?? this.priceRange,
    );
  }
}