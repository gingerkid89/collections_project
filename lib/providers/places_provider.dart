// lib/providers/places_provider.dart

import 'package:flutter/foundation.dart';
import '../models/place.dart';
import '../models/restaurant.dart';
import '../models/museum.dart';
import '../models/menu_item.dart';
import '../services/api_service.dart';

class PlacesProvider with ChangeNotifier {
  List<Place> _places = [];
  List<Place> _restaurants = [];
  List<Place> _museums = [];
  List<Place> _userFavorites = [];
  Map<String, dynamic> _userStats = {};
  
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Place> get places => List.unmodifiable(_places);
  List<Place> get restaurants => List.unmodifiable(_restaurants);
  List<Place> get museums => List.unmodifiable(_museums);
  List<Place> get userFavorites => List.unmodifiable(_userFavorites);
  Map<String, dynamic> get userStats => Map.unmodifiable(_userStats);
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Computed getters for collection compatibility
  List<Place> get restaurantPlaces => _restaurants;
  List<Place> get museumPlaces => _museums;

  PlacesProvider() {
    // Initialize data when provider is created
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      loadAllPlaces(),
      loadUserFavorites(),
      loadUserStats(),
    ]);
  }

  // Load all places
  Future<void> loadAllPlaces() async {
    _setLoading(true);
    try {
      _places = await ApiService.getPlaces();
      _restaurants = _places.where((p) => p.type == 'restaurant').toList();
      _museums = _places.where((p) => p.type == 'museum').toList();
      _clearError();
    } catch (e) {
      _setError('Failed to load places: $e');
      debugPrint('Error loading places: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load only restaurants
  Future<void> loadRestaurants() async {
    _setLoading(true);
    try {
      _restaurants = await ApiService.getRestaurants();
      _clearError();
    } catch (e) {
      _setError('Failed to load restaurants: $e');
      debugPrint('Error loading restaurants: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load only museums
  Future<void> loadMuseums() async {
    _setLoading(true);
    try {
      _museums = await ApiService.getMuseums();
      _clearError();
    } catch (e) {
      _setError('Failed to load museums: $e');
      debugPrint('Error loading museums: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load user favorites
  Future<void> loadUserFavorites() async {
    try {
      _userFavorites = await ApiService.getUserFavorites();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load favorites: $e');
      debugPrint('Error loading favorites: $e');
    }
  }

  // Load user statistics
  Future<void> loadUserStats() async {
    try {
      _userStats = await ApiService.getUserStats();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load user stats: $e');
      debugPrint('Error loading user stats: $e');
    }
  }

  // Get single place by ID
  Future<Place?> getPlace(String placeId) async {
    try {
      final place = await ApiService.getPlace(placeId);
      return place;
    } catch (e) {
      debugPrint('Error getting place $placeId: $e');
      return null;
    }
  }

  // Search places
  Future<List<Place>> searchPlaces(String query) async {
    _setLoading(true);
    try {
      final results = await ApiService.searchPlaces(query);
      _clearError();
      return results;
    } catch (e) {
      _setError('Search failed: $e');
      debugPrint('Error searching places: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Get restaurants with specific criteria
  List<Place> getRestaurantsWithCuisine(String cuisine) {
    return _restaurants.where((restaurant) {
      if (restaurant is Restaurant) {
        return restaurant.cuisine.toLowerCase().contains(cuisine.toLowerCase());
      }
      return false;
    }).toList();
  }

  // Get museums with specific category
  List<Place> getMuseumsWithCategory(String category) {
    return _museums.where((museum) {
      if (museum is Museum) {
        return museum.category.toLowerCase().contains(category.toLowerCase());
      }
      return false;
    }).toList();
  }

  // Get visited places
  List<Place> getVisitedPlaces() {
    return _places.where((place) => place.collectionStatus.isVisited).toList();
  }

  // Get places by rating
  List<Place> getPlacesByMinRating(double minRating) {
    return _places.where((place) {
      final rating = place.collectionStatus.userRating;
      return rating != null && rating >= minRating;
    }).toList();
  }

  // Refresh all data
  Future<void> refresh() async {
    await _initializeData();
  }

  // Retry loading data after error
  Future<void> retry() async {
    _clearError();
    await _initializeData();
  }

  // Create a new place (restaurant or museum)
  Future<Place> createPlace({
    required String name,
    required String type,
    required String address,
    String? phone,
    String? website,
    String? email,
    Map<String, String>? openingHours,
    List<String>? highlights,
    double? latitude,
    double? longitude,
    String? imageUrl,
    Map<String, dynamic>? specialData,
    List<Map<String, dynamic>>? menuItems,
  }) async {
    _setLoading(true);
    try {
      final placeData = {
        'name': name,
        'type': type,
        'address': address,
        'phone': phone,
        'website': website,
        'email': email,
        'openingHours': openingHours ?? {},
        'highlights': highlights ?? [],
        'latitude': latitude,
        'longitude': longitude,
        'imageUrl': imageUrl,
        'specialData': specialData ?? {},
        if (menuItems != null) 'menuItems': menuItems,
      };

      final createdPlace = await ApiService.createPlace(placeData);
      
      // Add to local lists
      _places.add(createdPlace);
      
      if (createdPlace.type == 'restaurant') {
        _restaurants.add(createdPlace);
      } else if (createdPlace.type == 'museum') {
        _museums.add(createdPlace);
      }
      
      _clearError();
      notifyListeners();
      
      return createdPlace;
    } catch (e) {
      _setError('Failed to create place: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Create a restaurant specifically
  Future<Restaurant> createRestaurant({
    required String name,
    required String address,
    required String cuisine,
    required String priceCategory,
    String? phone,
    String? website,
    String? email,
    Map<String, String>? openingHours,
    List<String>? highlights,
    double? latitude,
    double? longitude,
    String? imageUrl,
    bool hasReservation = false,
    bool hasDelivery = false,
    bool hasTakeout = false,
    List<MenuItem>? menuItems,
  }) async {
    _setLoading(true);
    try {
      // Convert MenuItem objects to API format
      List<Map<String, dynamic>>? menuItemsData;
      if (menuItems != null) {
        menuItemsData = menuItems.map((item) => {
          'name': item.name,
          'description': item.description,
          'price': item.price,
          'category': item.category,
          'allergens': item.allergens,
          'isVegetarian': item.isVegetarian,
          'isVegan': item.isVegan,
          'isGlutenFree': item.isGlutenFree,
          'imageUrl': item.imageUrl,
        }).toList();
      }

      final restaurant = await ApiService.createRestaurant(
        name: name,
        address: address,
        cuisine: cuisine,
        priceCategory: priceCategory,
        phone: phone,
        website: website,
        email: email,
        openingHours: openingHours,
        highlights: highlights,
        latitude: latitude,
        longitude: longitude,
        imageUrl: imageUrl,
        hasReservation: hasReservation,
        hasDelivery: hasDelivery,
        hasTakeout: hasTakeout,
        menuItems: menuItemsData,
      );
      
      // Add to local lists
      _places.add(restaurant);
      _restaurants.add(restaurant);
      
      _clearError();
      notifyListeners();
      
      return restaurant;
    } catch (e) {
      _setError('Failed to create restaurant: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Create a museum specifically
  Future<Museum> createMuseum({
    required String name,
    required String address,
    required String category,
    String? ticketPrice,
    List<String>? currentExhibitions,
    List<String>? permanentCollections,
    String? phone,
    String? website,
    String? email,
    Map<String, String>? openingHours,
    List<String>? highlights,
    double? latitude,
    double? longitude,
    String? imageUrl,
    bool hasAudioGuide = false,
    bool hasGiftShop = false,
    bool isWheelchairAccessible = false,
  }) async {
    _setLoading(true);
    try {
      final museum = await ApiService.createMuseum(
        name: name,
        address: address,
        category: category,
        ticketPrice: ticketPrice,
        currentExhibitions: currentExhibitions,
        permanentCollections: permanentCollections,
        phone: phone,
        website: website,
        email: email,
        openingHours: openingHours,
        highlights: highlights,
        latitude: latitude,
        longitude: longitude,
        imageUrl: imageUrl,
        hasAudioGuide: hasAudioGuide,
        hasGiftShop: hasGiftShop,
        isWheelchairAccessible: isWheelchairAccessible,
      );
      
      // Add to local lists
      _places.add(museum);
      _museums.add(museum);
      
      _clearError();
      notifyListeners();
      
      return museum;
    } catch (e) {
      _setError('Failed to create museum: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Collection compatibility methods (for existing UI)
  Place? getPlaceById(String id) {
    try {
      return _places.firstWhere((place) => place.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get Italian restaurants (for compatibility)
  List<Place> getItalianRestaurants() {
    return getRestaurantsWithCuisine('italian');
  }

  // Get art museums (for compatibility)
  List<Place> getArtMuseums() {
    return getMuseumsWithCategory('art');
  }

  // Get science museums (for compatibility)  
  List<Place> getScienceMuseums() {
    return getMuseumsWithCategory('science');
  }

  // Statistics getters
  int get totalPlaces => _places.length;
  int get totalRestaurants => _restaurants.length;
  int get totalMuseums => _museums.length;
  int get totalVisited => getVisitedPlaces().length;
  int get totalFavorites => _userFavorites.length;

  // User statistics
  int get userVisitedPlaces => _userStats['placesVisited'] ?? 0;
  int get userRestaurantsVisited => _userStats['restaurantsVisited'] ?? 0;
  int get userMuseumsVisited => _userStats['museumsVisited'] ?? 0;
  int get userTotalVisits => _userStats['totalVisits'] ?? 0;
  double get userAverageRating => double.tryParse(_userStats['averageRating']?.toString() ?? '0') ?? 0.0;
  double get userTotalSpent => double.tryParse(_userStats['totalSpent']?.toString() ?? '0') ?? 0.0;

  @override
  void dispose() {
    super.dispose();
  }
}