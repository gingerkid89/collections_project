// lib/services/api_simulation.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/visit.dart';
import '../models/visit_activity.dart';

class ApiSimulation {
  static final ApiSimulation _instance = ApiSimulation._internal();
  factory ApiSimulation() => _instance;
  ApiSimulation._internal();

  static const String _dummyDataInitializedKey = 'dummy_data_initialized';
  static const String _apiSimulationKey = 'api_simulation_enabled';
  
  // Simulated API delay
  static const Duration _apiDelay = Duration(milliseconds: 500);

  /// Check if dummy data has been initialized
  Future<bool> isDummyDataInitialized() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dummyDataInitializedKey) ?? false;
  }

  /// Mark dummy data as initialized
  Future<void> markDummyDataInitialized() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dummyDataInitializedKey, true);
  }

  /// Reset dummy data flag (for development/testing)
  Future<void> resetDummyData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dummyDataInitializedKey);
  }

  /// Simulate fetching user's personal visits
  Future<List<Visit>> fetchPersonalVisits() async {
    await Future.delayed(_apiDelay);
    
    if (!(await isDummyDataInitialized())) {
      final visits = _generateDummyPersonalVisits();
      await markDummyDataInitialized();
      return visits;
    }
    
    return []; // Return empty if already initialized
  }

  /// Simulate fetching public visits for a specific place
  Future<List<Visit>> fetchPublicVisitsForPlace(String placeId) async {
    await Future.delayed(_apiDelay);
    
    return _generatePublicVisitsForPlace(placeId);
  }

  /// Simulate fetching all public visits
  Future<List<Visit>> fetchAllPublicVisits() async {
    await Future.delayed(_apiDelay);
    
    return _generateAllPublicVisits();
  }

  /// Simulate posting a new visit
  Future<Visit> postVisit(Visit visit) async {
    await Future.delayed(_apiDelay);
    
    // Simulate server processing and return visit with server-generated ID
    return visit.copyWith(
      id: 'server_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(4)}',
    );
  }

  /// Simulate updating an existing visit
  Future<Visit> updateVisit(Visit visit) async {
    await Future.delayed(_apiDelay);
    
    // Return the updated visit
    return visit;
  }

  /// Simulate deleting a visit
  Future<bool> deleteVisit(String visitId) async {
    await Future.delayed(_apiDelay);
    
    // Simulate successful deletion
    return true;
  }

  /// Generate comprehensive dummy personal visits
  List<Visit> _generateDummyPersonalVisits() {
    final visits = <Visit>[];
    
    // McDonald's visits
    visits.addAll(_generateMcDonaldsVisits());
    
    // Starbucks visits
    visits.addAll(_generateStarbucksVisits());
    
    // Museum visits
    visits.addAll(_generateMuseumVisits());
    
    // Italian restaurant visits
    visits.addAll(_generateItalianRestaurantVisits());
    
    debugPrint('ApiSimulation: Generated ${visits.length} dummy personal visits');
    return visits;
  }

  List<Visit> _generateMcDonaldsVisits() {
    return [
      Visit.create(
        userId: 'user_123', // Current user ID
        date: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        placeId: 'mc_1',
        placeType: 'restaurant',
        overallRating: 4.2,
        notes: 'Quick lunch break. The Big Mac was fresh and the fries were perfectly crispy!',
        duration: const Duration(minutes: 25),
        totalCost: 8.50,
        activities: [
          RestaurantDish(id: 'big_mac', name: 'Big Mac', category: 'Main', price: 4.99),
          RestaurantDish(id: 'fries_m', name: 'Medium Fries', category: 'Sides', price: 2.49),
          RestaurantDish(id: 'coke', name: 'Coca Cola', category: 'Drinks', price: 1.99),
        ],
        metadata: {'placeName': 'McDonald\'s Hauptbahnhof'},
        photoUrls: ['dummy_photo_1.jpg', 'dummy_photo_2.jpg'],
        isPublic: true, // PUBLIC VISIT
      ),
      
      Visit.create(
        userId: 'user_456', // Other user ID
        date: DateTime.now().subtract(const Duration(days: 3)),
        placeId: 'mc_2', 
        placeType: 'restaurant',
        overallRating: 3.8,
        notes: 'Busy location but good service. Coffee was surprisingly good.',
        duration: const Duration(minutes: 45),
        totalCost: 12.30,
        activities: [
          RestaurantDish(id: 'qp', name: 'Quarter Pounder', category: 'Main', price: 5.49),
          RestaurantDish(id: 'latte', name: 'McCafé Latte', category: 'Drinks', price: 2.99),
          RestaurantDish(id: 'pie', name: 'Apple Pie', category: 'Dessert', price: 1.99),
        ],
        metadata: {'placeName': 'McDonald\'s Schildergasse'},
        photoUrls: ['dummy_photo_3.jpg'],
        isPublic: false, // PRIVATE VISIT
      ),

      Visit.create(
        userId: 'user_789', // Other user ID
        date: DateTime.now().subtract(const Duration(days: 8, hours: 5)),
        placeId: 'mc_3',
        placeType: 'restaurant',
        overallRating: 4.0,
        notes: 'Family dinner. Kids loved the playground and Happy Meals.',
        duration: const Duration(minutes: 55),
        totalCost: 24.80,
        activities: [
          RestaurantDish(id: 'happy_meal', name: 'Happy Meal', category: 'Kids', price: 4.99),
          RestaurantDish(id: 'happy_meal_2', name: 'Happy Meal', category: 'Kids', price: 4.99),
          RestaurantDish(id: 'big_tasty', name: 'Big Tasty', category: 'Main', price: 6.49),
          RestaurantDish(id: 'nuggets_20', name: '20 Chicken McNuggets', category: 'Main', price: 8.99),
        ],
        metadata: {'placeName': 'McDonald\'s Neumarkt'},
        photoUrls: ['dummy_photo_playground.jpg'],
        isPublic: false, // PRIVATE VISIT
      ),
    ];
  }

  List<Visit> _generateStarbucksVisits() {
    return [
      Visit.create(
        userId: 'user_123', // Current user ID
        date: DateTime.now().subtract(const Duration(hours: 6)),
        placeId: 'sb_1',
        placeType: 'restaurant', 
        overallRating: 4.5,
        notes: 'Perfect spot for working on my laptop. Great atmosphere and WiFi.',
        duration: const Duration(hours: 2, minutes: 30),
        totalCost: 15.80,
        activities: [
          RestaurantDish(id: 'cap_g', name: 'Cappuccino Grande', category: 'Coffee', price: 4.25),
          RestaurantDish(id: 'muffin', name: 'Blueberry Muffin', category: 'Pastry', price: 3.50),
          RestaurantDish(id: 'americano', name: 'Americano', category: 'Coffee', price: 3.75),
          RestaurantDish(id: 'cookie', name: 'Chocolate Chip Cookie', category: 'Snack', price: 2.50),
        ],
        metadata: {'placeName': 'Starbucks Friedensplatz'},
        photoUrls: ['dummy_photo_4.jpg', 'dummy_photo_5.jpg', 'dummy_photo_6.jpg'],
        isPublic: true, // PUBLIC VISIT
      ),

      Visit.create(
        userId: 'user_456', // Other user ID
        date: DateTime.now().subtract(const Duration(days: 5, hours: 3)),
        placeId: 'sb_2',
        placeType: 'restaurant',
        overallRating: 4.1,
        notes: 'Quick coffee break while shopping. Service was fast.',
        duration: const Duration(minutes: 20),
        totalCost: 4.95,
        activities: [
          RestaurantDish(id: 'latte_tall', name: 'Caffè Latte Tall', category: 'Coffee', price: 4.95),
        ],
        metadata: {'placeName': 'Starbucks Hohe Straße'},
        photoUrls: [],
        isPublic: true, // PUBLIC VISIT
      ),
    ];
  }

  List<Visit> _generateMuseumVisits() {
    return [
      Visit.create(
        userId: 'user_123', // Current user ID
        date: DateTime.now().subtract(const Duration(days: 5, hours: 3)),
        placeId: 'museum_1',
        placeType: 'museum',
        overallRating: 4.8,
        notes: 'Incredible Picasso exhibition! The Pop Art collection was also fascinating. Highly recommend the audio guide.',
        duration: const Duration(hours: 3, minutes: 15),
        totalCost: 14.00,
        activities: [
          MuseumExhibition(id: 'picasso_ex', name: 'Picasso Exhibition', exhibitionType: 'temporary'),
          MuseumExhibition(id: 'pop_art', name: 'Pop Art Collection', exhibitionType: 'permanent'),
          MuseumExhibition(id: 'photo_ex', name: 'Contemporary Photography', exhibitionType: 'temporary'),
        ],
        metadata: {'placeName': 'Museum Ludwig'},
        photoUrls: ['dummy_museum_1.jpg', 'dummy_museum_2.jpg'],
        isPublic: true, // PUBLIC VISIT
      ),
      
      Visit.create(
        userId: 'user_456', // Other user ID
        date: DateTime.now().subtract(const Duration(days: 7)),
        placeId: 'museum_3',
        placeType: 'museum',
        overallRating: 4.3,
        notes: 'Amazing Roman artifacts and the famous Dionysus mosaic is breathtaking!',
        duration: const Duration(hours: 2),
        totalCost: 9.00,
        activities: [
          MuseumExhibition(id: 'roman_glass', name: 'Roman Glass Collection', exhibitionType: 'permanent'),
          MuseumExhibition(id: 'mosaics', name: 'Ancient Mosaics', exhibitionType: 'permanent'),
        ],
        metadata: {'placeName': 'Romano-Germanisches Museum'},
        photoUrls: ['dummy_museum_3.jpg'],
        isPublic: false, // PRIVATE VISIT
      ),

      Visit.create(
        userId: 'user_789', // Other user ID
        date: DateTime.now().subtract(const Duration(days: 10, hours: 4)),
        placeId: 'museum_2',
        placeType: 'museum',
        overallRating: 4.4,
        notes: 'Beautiful medieval art collection. The Gothic sculptures were particularly impressive.',
        duration: const Duration(hours: 2, minutes: 45),
        totalCost: 12.00,
        activities: [
          MuseumExhibition(id: 'medieval', name: 'Medieval Art', exhibitionType: 'permanent'),
          MuseumExhibition(id: 'gothic', name: 'Gothic Sculptures', exhibitionType: 'permanent'),
        ],
        metadata: {'placeName': 'Wallraf-Richartz-Museum'},
        photoUrls: ['dummy_museum_medieval.jpg'],
        isPublic: true, // PUBLIC VISIT
      ),
    ];
  }

  List<Visit> _generateItalianRestaurantVisits() {
    return [
      Visit.create(
        userId: 'user_123', // Current user ID
        date: DateTime.now().subtract(const Duration(days: 2, hours: 8)),
        placeId: 'italian_1',
        placeType: 'restaurant',
        overallRating: 4.7,
        notes: 'Authentic Italian experience! The pasta was homemade and the tiramisu was to die for.',
        duration: const Duration(hours: 1, minutes: 45),
        totalCost: 28.50,
        activities: [
          RestaurantDish(id: 'carbonara', name: 'Spaghetti Carbonara', category: 'Pasta', price: 12.90),
          RestaurantDish(id: 'tiramisu', name: 'Tiramisu', category: 'Dessert', price: 6.50),
          RestaurantDish(id: 'chianti', name: 'Chianti Classico', category: 'Wine', price: 9.00),
        ],
        metadata: {'placeName': 'La Dolce Vita'},
        photoUrls: ['dummy_italian_1.jpg', 'dummy_italian_2.jpg'],
        isPublic: true, // PUBLIC VISIT
      ),
      
      Visit.create(
        userId: 'user_456', // Other user ID
        date: DateTime.now().subtract(const Duration(days: 4, hours: 12)),
        placeId: 'italian_2',
        placeType: 'restaurant',
        overallRating: 4.9,
        notes: 'Best Italian restaurant in Köln! Romantic atmosphere and exceptional food quality.',
        duration: const Duration(hours: 2, minutes: 30),
        totalCost: 65.80,
        activities: [
          RestaurantDish(id: 'osso_buco', name: 'Osso Buco alla Milanese', category: 'Main', price: 18.50),
          RestaurantDish(id: 'risotto', name: 'Risotto ai Porcini', category: 'Main', price: 14.90),
          RestaurantDish(id: 'panna_cotta', name: 'Panna Cotta', category: 'Dessert', price: 7.50),
          RestaurantDish(id: 'prosecco', name: 'Prosecco di Valdobbiadene', category: 'Wine', price: 24.90),
        ],
        metadata: {'placeName': 'Osteria Il Convivio'},
        photoUrls: ['dummy_italian_3.jpg', 'dummy_italian_4.jpg', 'dummy_italian_5.jpg'],
        isPublic: true, // PUBLIC VISIT
      ),
      
      Visit.create(
        userId: 'user_789', // Other user ID
        date: DateTime.now().subtract(const Duration(days: 6)),
        placeId: 'italian_3',
        placeType: 'restaurant',
        overallRating: 4.4,
        notes: 'Family-run trattoria with authentic recipes passed down through generations.',
        duration: const Duration(hours: 1, minutes: 20),
        totalCost: 19.90,
        activities: [
          RestaurantDish(id: 'margherita', name: 'Pizza Margherita', category: 'Pizza', price: 9.50),
          RestaurantDish(id: 'caprese', name: 'Insalata Caprese', category: 'Salad', price: 7.90),
          RestaurantDish(id: 'limoncello', name: 'Limoncello', category: 'Digestive', price: 2.50),
        ],
        metadata: {'placeName': 'Trattoria da Nino'},
        photoUrls: ['dummy_italian_6.jpg'],
        isPublic: false, // PRIVATE VISIT
      ),

      Visit.create(
        userId: 'user_456', // Other user ID
        date: DateTime.now().subtract(const Duration(days: 9, hours: 7)),
        placeId: 'italian_4',
        placeType: 'restaurant',
        overallRating: 4.2,
        notes: 'Business lunch meeting. Professional atmosphere, good for work discussions.',
        duration: const Duration(hours: 1, minutes: 10),
        totalCost: 32.40,
        activities: [
          RestaurantDish(id: 'seafood_pasta', name: 'Linguine ai Frutti di Mare', category: 'Pasta', price: 16.90),
          RestaurantDish(id: 'caesar', name: 'Caesar Salad', category: 'Salad', price: 8.50),
          RestaurantDish(id: 'pinot_grigio', name: 'Pinot Grigio', category: 'Wine', price: 7.00),
        ],
        metadata: {'placeName': 'Ristorante San Remo'},
        photoUrls: ['dummy_italian_business.jpg'],
        isPublic: false, // PRIVATE VISIT
      ),
    ];
  }

  /// Generate public visits from other users for a specific place
  List<Visit> _generatePublicVisitsForPlace(String placeId) {
    final random = Random();
    final visits = <Visit>[];
    
    // Other user IDs for simulation
    final otherUserIds = ['user_456', 'user_789', 'user_101', 'user_202', 'user_303'];

    // Generate 1-3 public visits from "other users" for the specified place
    final visitCount = 1 + random.nextInt(3);
    
    for (int i = 0; i < visitCount; i++) {
      final daysAgo = 1 + random.nextInt(14); // 1-14 days ago
      final rating = 3.0 + random.nextDouble() * 2.0; // 3.0-5.0 rating
      
      visits.add(Visit.create(
        userId: otherUserIds[random.nextInt(otherUserIds.length)], // Random other user
        date: DateTime.now().subtract(Duration(days: daysAgo, hours: random.nextInt(24))),
        placeId: placeId,
        placeType: _getPlaceTypeFromId(placeId),
        overallRating: double.parse(rating.toStringAsFixed(1)),
        notes: _getRandomPublicVisitNote(placeId),
        duration: Duration(minutes: 30 + random.nextInt(120)), // 30min - 2.5h
        totalCost: 5.0 + random.nextDouble() * 40.0, // €5-45
        activities: _getRandomActivitiesForPlace(placeId),
        metadata: {'placeName': _getPlaceNameFromId(placeId), 'userId': 'user_${random.nextInt(1000)}'},
        photoUrls: _getRandomPhotoUrls(1 + random.nextInt(3)),
        isPublic: true, // Always public for this simulation
      ));
    }

    return visits;
  }

  /// Generate all public visits for the public visits tab
  List<Visit> _generateAllPublicVisits() {
    final publicVisits = <Visit>[];
    
    // Get public visits from our personal visits
    final personalPublicVisits = _generateDummyPersonalVisits()
        .where((visit) => visit.isPublic)
        .toList();
    
    publicVisits.addAll(personalPublicVisits);
    
    // Add some additional public visits from "other users"
    final allPlaceIds = ['mc_1', 'mc_2', 'sb_1', 'museum_1', 'italian_1', 'italian_2'];
    
    for (final placeId in allPlaceIds) {
      publicVisits.addAll(_generatePublicVisitsForPlace(placeId).take(1)); // 1 per place
    }

    return publicVisits..sort((a, b) => b.date.compareTo(a.date)); // Newest first
  }

  // Helper methods
  String _getPlaceTypeFromId(String placeId) {
    if (placeId.startsWith('mc_') || placeId.startsWith('sb_') || placeId.startsWith('italian_')) {
      return 'restaurant';
    } else if (placeId.startsWith('museum_') || placeId.startsWith('art_') || placeId.startsWith('science_')) {
      return 'museum';
    }
    return 'restaurant'; // default
  }

  String _getPlaceNameFromId(String placeId) {
    final placeNames = {
      'mc_1': 'McDonald\'s Hauptbahnhof',
      'mc_2': 'McDonald\'s Schildergasse',
      'mc_3': 'McDonald\'s Neumarkt',
      'sb_1': 'Starbucks Friedensplatz',
      'sb_2': 'Starbucks Hohe Straße',
      'museum_1': 'Museum Ludwig',
      'museum_2': 'Wallraf-Richartz-Museum',
      'museum_3': 'Romano-Germanisches Museum',
      'italian_1': 'La Dolce Vita',
      'italian_2': 'Osteria Il Convivio',
      'italian_3': 'Trattoria da Nino',
      'italian_4': 'Ristorante San Remo',
    };
    
    return placeNames[placeId] ?? 'Unknown Place';
  }

  String _getRandomPublicVisitNote(String placeId) {
    final restaurantNotes = [
      'Great food and friendly service!',
      'Loved the atmosphere, will definitely come back.',
      'Good value for money, recommended!',
      'Nice place for a quick bite.',
      'Perfect for a casual meal with friends.',
    ];

    final museumNotes = [
      'Amazing exhibitions, very educational!',
      'Perfect for a cultural afternoon.',
      'Impressive collection, worth the visit.',
      'Great for families and art lovers.',
      'Inspiring and thought-provoking displays.',
    ];

    final notes = _getPlaceTypeFromId(placeId) == 'museum' ? museumNotes : restaurantNotes;
    return notes[Random().nextInt(notes.length)];
  }

  List<VisitActivity> _getRandomActivitiesForPlace(String placeId) {
    if (_getPlaceTypeFromId(placeId) == 'museum') {
      return [
        MuseumExhibition(
          id: 'random_ex',
          name: 'Featured Exhibition',
          exhibitionType: 'temporary',
        ),
      ];
    } else {
      return [
        RestaurantDish(
          id: 'random_dish',
          name: 'Popular Dish',
          category: 'Main',
          price: 8.0 + Random().nextDouble() * 12.0,
        ),
      ];
    }
  }

  List<String> _getRandomPhotoUrls(int count) {
    return List.generate(count, (index) => 'dummy_public_photo_${index + 1}.jpg');
  }

  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
  }
}