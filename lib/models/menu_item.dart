// lib/models/menu_item.dart

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category; // 'pasta', 'pizza', 'desserts', etc.
  final List<String> allergens;
  final bool isVegetarian;
  final bool isVegan;
  final bool isGlutenFree;
  final String? imageUrl;
  final double? userRating;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.allergens = const [],
    this.isVegetarian = false,
    this.isVegan = false,
    this.isGlutenFree = false,
    this.imageUrl,
    this.userRating,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'allergens': allergens,
      'isVegetarian': isVegetarian,
      'isVegan': isVegan,
      'isGlutenFree': isGlutenFree,
      'imageUrl': imageUrl,
      'userRating': userRating,
    };
  }

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      category: json['category'] ?? '',
      allergens: List<String>.from(json['allergens'] ?? []),
      isVegetarian: json['isVegetarian'] ?? false,
      isVegan: json['isVegan'] ?? false,
      isGlutenFree: json['isGlutenFree'] ?? false,
      imageUrl: json['imageUrl'],
      userRating: json['userRating']?.toDouble(),
    );
  }

  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    List<String>? allergens,
    bool? isVegetarian,
    bool? isVegan,
    bool? isGlutenFree,
    String? imageUrl,
    double? userRating,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      allergens: allergens ?? this.allergens,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isVegan: isVegan ?? this.isVegan,
      isGlutenFree: isGlutenFree ?? this.isGlutenFree,
      imageUrl: imageUrl ?? this.imageUrl,
      userRating: userRating ?? this.userRating,
    );
  }

  // Utility methods
  bool get hasDietaryRestrictions => isVegetarian || isVegan || isGlutenFree;
  String get formattedPrice => '€${price.toStringAsFixed(2)}';
  
  List<String> get dietaryLabels {
    final labels = <String>[];
    if (isVegan) {
      labels.add('Vegan');
    } else if (isVegetarian) {
      labels.add('Vegetarisch');
    }
    if (isGlutenFree) {
      labels.add('Glutenfrei');
    }
    return labels;
  }
}