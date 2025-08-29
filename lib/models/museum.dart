// lib/models/museum.dart

import 'place.dart';
import 'visit.dart';

class Museum implements Place {
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

  final String category; // 'art', 'history', 'science', 'technology'
  final List<String> currentExhibitions;
  final List<String> permanentCollections;
  final String ticketPrice;
  final bool hasAudioGuide;
  final bool hasGiftShop;
  final bool isWheelchairAccessible;

  const Museum({
    required this.id,
    required this.name,
    required this.category,
    required this.currentExhibitions,
    required this.permanentCollections,
    required this.ticketPrice,
    required this.collectionStatus,
    required this.visits,
    required this.info,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.hasAudioGuide = false,
    this.hasGiftShop = false,
    this.isWheelchairAccessible = false,
  }) : type = 'museum', emoji = '🏛️';

  @override
  Map<String, dynamic> get specialData => {
    'category': category,
    'currentExhibitions': currentExhibitions,
    'permanentCollections': permanentCollections,
    'ticketPrice': ticketPrice,
    'hasAudioGuide': hasAudioGuide,
    'hasGiftShop': hasGiftShop,
    'isWheelchairAccessible': isWheelchairAccessible,
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

  factory Museum.fromJson(Map<String, dynamic> json) {
    final specialData = json['specialData'] as Map<String, dynamic>;
    return Museum(
      id: json['id'],
      name: json['name'],
      category: specialData['category'] ?? '',
      currentExhibitions: List<String>.from(specialData['currentExhibitions'] ?? []),
      permanentCollections: List<String>.from(specialData['permanentCollections'] ?? []),
      ticketPrice: specialData['ticketPrice'] ?? '',
      imageUrl: json['imageUrl'],
      collectionStatus: PlaceCollectionStatus.fromJson(json['collectionStatus']),
      visits: (json['visits'] as List<dynamic>?)
          ?.map((visit) => Visit.fromJson(visit as Map<String, dynamic>))
          .toList() ?? [],
      info: PlaceInfo.fromJson(json['info']),
      hasAudioGuide: specialData['hasAudioGuide'] ?? false,
      hasGiftShop: specialData['hasGiftShop'] ?? false,
      isWheelchairAccessible: specialData['isWheelchairAccessible'] ?? false,
    );
  }

  @override
  Museum copyWith({
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
    return Museum(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category,
      currentExhibitions: currentExhibitions,
      permanentCollections: permanentCollections,
      ticketPrice: ticketPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      collectionStatus: collectionStatus ?? this.collectionStatus,
      visits: visits ?? this.visits,
      info: info ?? this.info,
      hasAudioGuide: hasAudioGuide,
      hasGiftShop: hasGiftShop,
      isWheelchairAccessible: isWheelchairAccessible,
    );
  }
}