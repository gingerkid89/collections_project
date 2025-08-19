// lib/models/location.dart
import 'dart:math' show atan2, sqrt, pi;

class Location {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final List<String> imageUrls;
  final List<String> features;
  final String? phone;
  final String? website;
  final String? openingHours;
  final double? averageRating;
  final int? reviewCount;

  // Besuchsstatus
  bool isVisited;
  DateTime? visitDate;
  int? userRating; // 1-5 Sterne
  List<String> userPhotos;
  String? userNotes;

  Location({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.imageUrls = const [],
    this.features = const [],
    this.phone,
    this.website,
    this.openingHours,
    this.averageRating,
    this.reviewCount,
    this.isVisited = false,
    this.visitDate,
    this.userRating,
    this.userPhotos = const [],
    this.userNotes,
  });

  // Hilfsmethoden
  String get shortAddress {
    // "Trankgasse 11, 50667 Köln" -> "Trankgasse 11"
    return address.split(',').first.trim();
  }

  String get displayRating {
    if (averageRating != null) {
      return averageRating!.toStringAsFixed(1);
    }
    return 'Keine Bewertung';
  }

  // Besuch markieren
  void markAsVisited({
    int? rating,
    List<String>? photos,
    String? notes,
  }) {
    isVisited = true;
    visitDate = DateTime.now();
    if (rating != null) userRating = rating;
    if (photos != null) userPhotos = photos;
    if (notes != null) userNotes = notes;
  }

  // Besuch rückgängig machen
  void markAsNotVisited() {
    isVisited = false;
    visitDate = null;
    userRating = null;
    userPhotos = [];
    userNotes = null;
  }

  // Entfernung berechnen (vereinfacht)
  double distanceToUser(double userLat, double userLng) {
    // Vereinfachte Entfernungsberechnung
    // In echter App würde man geolocator package verwenden
    const double earthRadius = 6371; // km

    double dLat = _degreesToRadians(latitude - userLat);
    double dLng = _degreesToRadians(longitude - userLng);

    double a =
        (dLat / 2) * (dLat / 2) +
            _degreesToRadians(userLat) * _degreesToRadians(latitude) *
                (dLng / 2) * (dLng / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  String formatDistance(double userLat, double userLng) {
    double distance = distanceToUser(userLat, userLng);
    if (distance < 1) {
      return '${(distance * 1000).round()}m';
    } else {
      return '${distance.toStringAsFixed(1)}km';
    }
  }

  // JSON Serialisierung
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'imageUrls': imageUrls,
    'features': features,
    'phone': phone,
    'website': website,
    'openingHours': openingHours,
    'averageRating': averageRating,
    'reviewCount': reviewCount,
    'isVisited': isVisited,
    'visitDate': visitDate?.toIso8601String(),
    'userRating': userRating,
    'userPhotos': userPhotos,
    'userNotes': userNotes,
  };

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      features: List<String>.from(json['features'] ?? []),
      phone: json['phone'],
      website: json['website'],
      openingHours: json['openingHours'],
      averageRating: json['averageRating']?.toDouble(),
      reviewCount: json['reviewCount'],
      isVisited: json['isVisited'] ?? false,
      visitDate: json['visitDate'] != null ? DateTime.parse(json['visitDate']) : null,
      userRating: json['userRating'],
      userPhotos: List<String>.from(json['userPhotos'] ?? []),
      userNotes: json['userNotes'],
    );
  }

  // Copy with - für State Updates
  Location copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    List<String>? imageUrls,
    List<String>? features,
    String? phone,
    String? website,
    String? openingHours,
    double? averageRating,
    int? reviewCount,
    bool? isVisited,
    DateTime? visitDate,
    int? userRating,
    List<String>? userPhotos,
    String? userNotes,
  }) {
    return Location(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrls: imageUrls ?? this.imageUrls,
      features: features ?? this.features,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      openingHours: openingHours ?? this.openingHours,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      isVisited: isVisited ?? this.isVisited,
      visitDate: visitDate ?? this.visitDate,
      userRating: userRating ?? this.userRating,
      userPhotos: userPhotos ?? this.userPhotos,
      userNotes: userNotes ?? this.userNotes,
    );
  }
}