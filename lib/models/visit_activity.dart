// lib/models/visit_activity.dart

abstract class VisitActivity {
  String get id;
  String get name;
  String get type; // 'dish', 'exhibition', 'attraction'
  double? get rating;
  Map<String, dynamic> get activityData;

  Map<String, dynamic> toJson();
  VisitActivity copyWith({double? rating});
}

class RestaurantDish implements VisitActivity {
  @override
  final String id;
  @override
  final String name;
  final String category;
  final double price;
  @override
  final double? rating;
  final String? description;

  const RestaurantDish({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.rating,
    this.description,
  });

  @override
  String get type => 'dish';

  @override
  Map<String, dynamic> get activityData => {
    'category': category,
    'price': price,
    'description': description,
  };

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'category': category,
      'price': price,
      'rating': rating,
      'description': description,
    };
  }

  factory RestaurantDish.fromJson(Map<String, dynamic> json) {
    return RestaurantDish(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      rating: json['rating']?.toDouble(),
      description: json['description'],
    );
  }

  @override
  RestaurantDish copyWith({double? rating}) {
    return RestaurantDish(
      id: id,
      name: name,
      category: category,
      price: price,
      rating: rating ?? this.rating,
      description: description,
    );
  }
}

class MuseumExhibition implements VisitActivity {
  @override
  final String id;
  @override
  final String name;
  final String exhibitionType; // 'permanent', 'temporary'
  final String? artist;
  final String? period;
  @override
  final double? rating;
  final String? notes;

  const MuseumExhibition({
    required this.id,
    required this.name,
    required this.exhibitionType,
    this.artist,
    this.period,
    this.rating,
    this.notes,
  });

  @override
  String get type => 'exhibition';

  @override
  Map<String, dynamic> get activityData => {
    'exhibitionType': exhibitionType,
    'artist': artist,
    'period': period,
    'notes': notes,
  };

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'exhibitionType': exhibitionType,
      'artist': artist,
      'period': period,
      'rating': rating,
      'notes': notes,
    };
  }

  factory MuseumExhibition.fromJson(Map<String, dynamic> json) {
    return MuseumExhibition(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      exhibitionType: json['exhibitionType'] ?? 'permanent',
      artist: json['artist'],
      period: json['period'],
      rating: json['rating']?.toDouble(),
      notes: json['notes'],
    );
  }

  @override
  MuseumExhibition copyWith({double? rating}) {
    return MuseumExhibition(
      id: id,
      name: name,
      exhibitionType: exhibitionType,
      artist: artist,
      period: period,
      rating: rating ?? this.rating,
      notes: notes,
    );
  }
}

class VisitActivityFactory {
  static VisitActivity fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    
    switch (type) {
      case 'dish':
        return RestaurantDish.fromJson(json);
      case 'exhibition':
        return MuseumExhibition.fromJson(json);
      default:
        throw UnsupportedError('Visit activity type "$type" not supported');
    }
  }
}