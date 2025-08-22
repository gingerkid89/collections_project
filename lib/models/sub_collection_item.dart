class SubCollectionItem {
  final String id;
  final String name;
  final String icon;  // Emoji oder Icon-Name
  final String category; // "menu", "artwork", "attraction"
  final bool isCollected;
  final DateTime? collectedDate;
  final String? userNote;
  final List<String> userPhotos;

  const SubCollectionItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    this.isCollected = false,
    this.collectedDate,
    this.userNote,
    this.userPhotos = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'category': category,
      'isCollected': isCollected,
      'collectedDate': collectedDate?.toIso8601String(),
      'userNote': userNote,
      'userPhotos': userPhotos,
    };
  }

  factory SubCollectionItem.fromJson(Map<String, dynamic> json) {
    return SubCollectionItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      category: json['category'] ?? '',
      isCollected: json['isCollected'] ?? false,
      collectedDate: json['collectedDate'] != null 
          ? DateTime.parse(json['collectedDate']) 
          : null,
      userNote: json['userNote'],
      userPhotos: List<String>.from(json['userPhotos'] ?? []),
    );
  }

  SubCollectionItem copyWith({
    String? id,
    String? name,
    String? icon,
    String? category,
    bool? isCollected,
    DateTime? collectedDate,
    String? userNote,
    List<String>? userPhotos,
  }) {
    return SubCollectionItem(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      isCollected: isCollected ?? this.isCollected,
      collectedDate: collectedDate ?? this.collectedDate,
      userNote: userNote ?? this.userNote,
      userPhotos: userPhotos ?? this.userPhotos,
    );
  }
}

class LocationSubCollection {
  final String type; // "restaurant_menu", "museum_exhibitions", "park_attractions"
  final String displayName; // "Menü-Items", "Ausstellungen", "Attraktionen"
  final String description;
  final List<SubCollectionItem> items;
  final String primaryColor; // Für UI-Theming

  const LocationSubCollection({
    required this.type,
    required this.displayName,
    required this.description,
    required this.items,
    required this.primaryColor,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'displayName': displayName,
      'description': description,
      'items': items.map((item) => item.toJson()).toList(),
      'primaryColor': primaryColor,
    };
  }

  factory LocationSubCollection.fromJson(Map<String, dynamic> json) {
    return LocationSubCollection(
      type: json['type'] ?? '',
      displayName: json['displayName'] ?? '',
      description: json['description'] ?? '',
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => SubCollectionItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      primaryColor: json['primaryColor'] ?? '#000000',
    );
  }

  LocationSubCollection copyWith({
    String? type,
    String? displayName,
    String? description,
    List<SubCollectionItem>? items,
    String? primaryColor,
  }) {
    return LocationSubCollection(
      type: type ?? this.type,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      items: items ?? this.items,
      primaryColor: primaryColor ?? this.primaryColor,
    );
  }

  // Utility methods
  int get collectedCount => items.where((item) => item.isCollected).length;
  int get totalCount => items.length;
  double get progressPercentage => totalCount > 0 ? (collectedCount / totalCount) * 100 : 0;
}
