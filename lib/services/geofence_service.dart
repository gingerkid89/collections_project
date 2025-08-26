import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/place.dart';
import '../models/location.dart';
import '../models/visit.dart';
import '../services/api_simulation.dart';

class MonitoredPlace {
  final Place place;
  bool isNearby;
  DateTime? lastEntered;
  bool hasNotifiedEntry;
  
  MonitoredPlace({
    required this.place,
    this.isNearby = false,
    this.lastEntered,
    this.hasNotifiedEntry = false,
  });
}

class MockPlace implements Place {
  @override
  final String id;
  @override
  final String name;
  final double latitude;
  final double longitude;
  
  MockPlace({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  @override
  String get type => 'Restaurant';
  
  @override
  String get emoji => '🍽️';
  
  @override
  PlaceCollectionStatus get collectionStatus => const PlaceCollectionStatus(
    isVisited: false,
    visitCount: 0,
  );
  
  @override
  List<Visit> get visits => [];
  
  @override
  PlaceInfo get info => PlaceInfo(address: '$latitude, $longitude');
  
  @override
  Map<String, dynamic> get specialData => {};
  
  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'latitude': latitude,
    'longitude': longitude,
  };
  
  @override
  Place copyWith({
    String? id,
    String? name,
    String? type,
    String? emoji,
    PlaceCollectionStatus? collectionStatus,
    List<Visit>? visits,
    PlaceInfo? info,
  }) {
    return MockPlace(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude,
      longitude: longitude,
    );
  }
}

class AppGeofenceService {
  static final AppGeofenceService _instance = AppGeofenceService._internal();
  factory AppGeofenceService() => _instance;
  AppGeofenceService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = 
      FlutterLocalNotificationsPlugin();

  Timer? _locationTimer;
  List<MonitoredPlace> _monitoredPlaces = [];
  Position? _lastPosition;

  bool _isInitialized = false;
  bool _geofencingEnabled = false;
  static const double _geofenceRadius = 150.0; // 150 meters

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize notifications
      await _initializeNotifications();

      // Check permissions
      final hasPermissions = await _checkPermissions();
      if (!hasPermissions) {
        print('GeofenceService: Required permissions not granted');
        return;
      }

      print('GeofenceService: Initialized successfully');
      _isInitialized = true;

    } catch (e) {
      print('GeofenceService initialization error: $e');
    }
  }

  Future<bool> _checkPermissions() async {
    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    // Check notification permissions
    final notificationStatus = await Permission.notification.status;
    if (!notificationStatus.isGranted) {
      await Permission.notification.request();
    }

    return true;
  }

  Future<void> _initializeNotifications() async {
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      print('Notification tapped with payload: $payload');
      // Handle notification tap - could navigate to add visit screen
    }
  }

  Future<void> enableGeofencing() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    if (_isInitialized) {
      _geofencingEnabled = true;
      await _setupGeofencesForAllPlaces();
      _startLocationMonitoring();
    }
  }

  Future<void> disableGeofencing() async {
    _geofencingEnabled = false;
    _stopLocationMonitoring();
    _monitoredPlaces.clear();
  }

  void _startLocationMonitoring() {
    _stopLocationMonitoring(); // Stop any existing timer
    
    // Check location every 30 seconds when app is in foreground
    _locationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_geofencingEnabled) {
        _checkCurrentLocation();
      }
    });
    
    // Initial check
    _checkCurrentLocation();
  }

  void _stopLocationMonitoring() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  Future<void> _checkCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _lastPosition = position;
      await _checkProximityToPlaces(position);

    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  Future<void> _checkProximityToPlaces(Position currentPosition) async {
    for (final monitoredPlace in _monitoredPlaces) {
      final mockPlace = monitoredPlace.place as MockPlace;
      final distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        mockPlace.latitude,
        mockPlace.longitude,
      );

      final wasNearby = monitoredPlace.isNearby;
      final isNowNearby = distance <= _geofenceRadius;

      if (!wasNearby && isNowNearby) {
        // Entered geofence
        monitoredPlace.isNearby = true;
        monitoredPlace.lastEntered = DateTime.now();
        monitoredPlace.hasNotifiedEntry = false;
        
        print('Entered geofence for ${monitoredPlace.place.name} (${distance.round()}m away)');
        
        // Wait 2 minutes before showing notification to confirm they're staying
        Timer(const Duration(minutes: 2), () async {
          if (monitoredPlace.isNearby && !monitoredPlace.hasNotifiedEntry) {
            await _showVisitPromptNotification(monitoredPlace.place, 'entered');
            monitoredPlace.hasNotifiedEntry = true;
          }
        });
        
      } else if (wasNearby && !isNowNearby) {
        // Exited geofence
        monitoredPlace.isNearby = false;
        monitoredPlace.hasNotifiedEntry = false;
        
        print('Exited geofence for ${monitoredPlace.place.name}');
        
        // Show exit notification if they were there for more than 5 minutes
        if (monitoredPlace.lastEntered != null) {
          final visitDuration = DateTime.now().difference(monitoredPlace.lastEntered!);
          if (visitDuration.inMinutes >= 5) {
            await _showVisitPromptNotification(monitoredPlace.place, 'exited');
          }
        }
      }
    }
  }

  Future<void> _setupGeofencesForAllPlaces() async {
    try {
      _monitoredPlaces.clear();

      // Create some sample locations for testing
      final samplePlaces = _createSamplePlaces();
      
      for (final place in samplePlaces) {
        _monitoredPlaces.add(MonitoredPlace(place: place));
      }

      print('GeofenceService: Monitoring ${_monitoredPlaces.length} places');
      
    } catch (e) {
      print('Error setting up geofences: $e');
    }
  }

  List<MockPlace> _createSamplePlaces() {
    // Sample McDonald's locations for testing
    return [
      MockPlace(
        id: 'mcdonalds_1',
        name: 'McDonald\'s Hauptbahnhof',
        latitude: 50.9429,
        longitude: 6.9583,
      ),
      MockPlace(
        id: 'mcdonalds_2', 
        name: 'McDonald\'s Schildergasse',
        latitude: 50.9364,
        longitude: 6.9534,
      ),
      MockPlace(
        id: 'mcdonalds_3',
        name: 'McDonald\'s Heumarkt',
        latitude: 50.9356,
        longitude: 6.9612,
      ),
    ];
  }


  Future<void> _showVisitPromptNotification(Place place, String action) async {
    String title = '';
    String body = '';
    
    switch (action) {
      case 'entered':
        title = '📍 You\'re at ${place.name}!';
        body = 'Add this visit to your collection?';
        break;
      case 'exited':
        title = '👋 Leaving ${place.name}?';
        body = 'How was your visit? Add it to your collection!';
        break;
      case 'dwelling':
        title = '⏰ Still at ${place.name}?';
        body = 'Don\'t forget to add this visit!';
        break;
    }

    const androidDetails = AndroidNotificationDetails(
      'visit_prompts',
      'Visit Prompts',
      channelDescription: 'Notifications to prompt adding visits',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      place.id.hashCode,
      title,
      body,
      notificationDetails,
      payload: 'visit_prompt:${place.id}',
    );
  }

  Future<void> addGeofenceForPlace(Place place) async {
    if (!_geofencingEnabled) return;

    final existingIndex = _monitoredPlaces.indexWhere((mp) => mp.place.id == place.id);
    if (existingIndex == -1) {
      _monitoredPlaces.add(MonitoredPlace(place: place));
      print('GeofenceService: Added monitoring for ${place.name}');
    }
  }

  Future<void> removeGeofenceForPlace(Place place) async {
    _monitoredPlaces.removeWhere((mp) => mp.place.id == place.id);
    print('GeofenceService: Removed monitoring for ${place.name}');
  }

  bool get isEnabled => _geofencingEnabled;
  bool get isInitialized => _isInitialized;
  int get activeGeofencesCount => _monitoredPlaces.length;
  Position? get lastKnownPosition => _lastPosition;

  Future<void> dispose() async {
    _stopLocationMonitoring();
    _monitoredPlaces.clear();
    _isInitialized = false;
    _geofencingEnabled = false;
  }
}