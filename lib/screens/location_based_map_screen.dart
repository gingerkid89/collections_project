// lib/screens/location_based_map_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../models/place.dart';
import '../providers/places_provider.dart';
import '../l10n/app_localizations.dart';
import 'place_detail_factory.dart';

class LocationBasedMapScreen extends StatefulWidget {
  const LocationBasedMapScreen({super.key});

  @override
  State<LocationBasedMapScreen> createState() => _LocationBasedMapScreenState();
}

class _LocationBasedMapScreenState extends State<LocationBasedMapScreen> {
  final MapController _mapController = MapController();
  Position? _userLocation;
  LatLng? _currentMapCenter; // Track current map center position
  List<Place> _nearbyPlaces = [];
  List<Place> _allPlaces = []; // Store all places for zoom-based filtering
  bool _isLoading = true;
  String? _errorMessage;
  double _currentZoom = 15.0;

  @override
  void initState() {
    super.initState();
    _initializeLocationMap();
  }

  // Calculate search radius based on zoom level
  double _getRadiusForZoom(double zoom) {
    // More zoom (higher number) = smaller radius, less zoom = larger radius
    if (zoom >= 16) return 500;      // Very close: 500m
    if (zoom >= 15) return 1000;     // Close: 1km  
    if (zoom >= 14) return 2000;     // Medium: 2km
    if (zoom >= 13) return 5000;     // Far: 5km
    if (zoom >= 12) return 10000;    // Very far: 10km
    return 20000;                    // Very far out: 20km
  }

  // Filter places based on current zoom level and current map center
  void _updateNearbyPlaces() {
    // Use current map center if available, fallback to user location
    final centerLat = _currentMapCenter?.latitude ?? _userLocation?.latitude;
    final centerLng = _currentMapCenter?.longitude ?? _userLocation?.longitude;
    
    if (centerLat == null || centerLng == null) {
      print('❌ No map center or user location available for filtering');
      return;
    }
    
    if (_allPlaces.isEmpty) {
      print('❌ No places loaded yet');
      return;
    }

    print('🔍 Filtering ${_allPlaces.length} places for map center: $centerLat, $centerLng');

    final radius = _getRadiusForZoom(_currentZoom);
    final nearbyPlaces = <Place>[];

    for (final place in _allPlaces) {
      if (place.latitude != null && place.longitude != null) {
        final distance = Geolocator.distanceBetween(
          centerLat,
          centerLng,
          place.latitude!,
          place.longitude!,
        );

        print('📏 ${place.name}: ${distance.round()}m away (radius: ${radius.round()}m)');

        if (distance <= radius) {
          nearbyPlaces.add(place);
          print('✅ Added ${place.name} to nearby places');
        }
      } else {
        print('❌ ${place.name} has no coordinates (lat: ${place.latitude}, lng: ${place.longitude})');
      }
    }

    setState(() {
      _nearbyPlaces = nearbyPlaces;
    });

    print('🔍 Zoom ${_currentZoom.toStringAsFixed(1)}: Showing ${nearbyPlaces.length} places within ${radius.round()}m from current map center');
  }

  Future<void> _initializeLocationMap() async {
    try {
      print('🔍 Starting location initialization...');
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Check if location services are enabled first
      print('📍 Checking if location services are enabled...');
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('📍 Location services enabled: $serviceEnabled');
      if (!serviceEnabled) {
        throw Exception('Location services are disabled. Please enable location services in your device settings.');
      }

      // Check location permissions
      print('🔒 Checking location permissions...');
      LocationPermission permission = await Geolocator.checkPermission();
      print('🔒 Initial permission status: $permission');
      
      if (permission == LocationPermission.denied) {
        print('🔒 Requesting location permissions...');
        permission = await Geolocator.requestPermission();
        print('🔒 Permission after request: $permission');
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied. Please enable location access in your device settings.');
      }
      
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are required to show nearby places.');
      }

      print('📡 Getting current position...');
      // Get current position with mobile-optimized settings
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high, // Use high accuracy for mobile
        timeLimit: const Duration(seconds: 45), // Longer timeout for mobile GPS
      );
      print('📡 Got position: ${position.latitude}, ${position.longitude} (accuracy: ${position.accuracy}m)');

      setState(() {
        _userLocation = position;
        _currentMapCenter = LatLng(position.latitude, position.longitude);
      });

      // Get all places  
      print('📦 Loading places...');
      final placesProvider = Provider.of<PlacesProvider>(context, listen: false);
      await placesProvider.refresh();
      
      if (!mounted) return; // Check if widget is still mounted
      final allPlaces = placesProvider.places;
      print('📦 Total places loaded: ${allPlaces.length}');

      // Log places without coordinates
      for (final place in allPlaces) {
        if (place.latitude == null || place.longitude == null) {
          print('⚠️ Place ${place.name} has no coordinates');
        }
      }

      setState(() {
        _allPlaces = allPlaces;
        _isLoading = false;
      });

      // Filter places based on initial zoom level
      _updateNearbyPlaces();

      // Center map on user location after a delay to ensure map is ready
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          try {
            _mapController.move(
              LatLng(position.latitude, position.longitude),
              15.0,
            );
            print('🗺️ Map centered on user location');
          } catch (e) {
            print('⚠️ Could not center map: $e');
          }
        }
      });

    } catch (e) {
      print('❌ Location error: $e');
      print('❌ Error type: ${e.runtimeType}');
      
      String friendlyMessage;
      
      if (e.toString().contains('Location services are disabled')) {
        friendlyMessage = 'Location services are disabled. Please enable location services in your device settings and try again.';
      } else if (e.toString().contains('permanently denied')) {
        friendlyMessage = 'Location permissions are permanently denied. Please enable location access in your device settings, then restart the app.';
      } else if (e.toString().contains('Location permissions')) {
        friendlyMessage = 'Location permissions are required. Please allow location access when prompted.';
      } else if (e.toString().contains('timeout')) {
        friendlyMessage = 'Location request timed out. Please ensure GPS is enabled and try again.';
      } else if (e.toString().contains('Position unavailable')) {
        friendlyMessage = 'Location unavailable. Please ensure GPS is enabled in your device settings.';
      } else {
        friendlyMessage = 'Unable to get your location. Please check your location settings and try again.';
      }
      
      setState(() {
        _errorMessage = friendlyMessage;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Places'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh location',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Getting your location...'),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 64,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Location Error',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _initializeLocationMap,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Map
                    Expanded(
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _userLocation != null
                              ? LatLng(_userLocation!.latitude, _userLocation!.longitude)
                              : const LatLng(50.7374, 7.0982), // Default center
                          initialZoom: 15.0,
                          minZoom: 10.0,
                          maxZoom: 18.0,
                          onMapReady: () {
                            print('🗺️ Map is ready');
                          },
                          onPositionChanged: (position, hasGesture) {
                            if (hasGesture) {
                              bool shouldUpdate = false;
                              
                              // Update zoom if changed
                              if (position.zoom != _currentZoom) {
                                _currentZoom = position.zoom!;
                                shouldUpdate = true;
                              }
                              
                              // Update center if changed (with threshold to avoid too many updates)
                              if (position.center != null) {
                                if (_currentMapCenter == null ||
                                    (_currentMapCenter!.latitude - position.center!.latitude).abs() > 0.0001 ||
                                    (_currentMapCenter!.longitude - position.center!.longitude).abs() > 0.0001) {
                                  _currentMapCenter = position.center!;
                                  shouldUpdate = true;
                                }
                              }
                              
                              if (shouldUpdate) {
                                _updateNearbyPlaces();
                              }
                            }
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.collections_app',
                          ),
                          MarkerLayer(
                            markers: _buildMarkers(),
                          ),
                        ],
                      ),
                    ),
                    // Places list
                    if (_nearbyPlaces.isNotEmpty)
                      Container(
                        height: 200,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nearby Places',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _nearbyPlaces.length,
                                itemBuilder: (context, index) {
                                  final place = _nearbyPlaces[index];
                                  // Use current map center for distance calculation, fallback to user location
                                  final centerLat = _currentMapCenter?.latitude ?? _userLocation?.latitude;
                                  final centerLng = _currentMapCenter?.longitude ?? _userLocation?.longitude;
                                  final distanceMeters = (centerLat != null && centerLng != null)
                                      ? Geolocator.distanceBetween(
                                          centerLat,
                                          centerLng,
                                          place.latitude!,
                                          place.longitude!,
                                        ).round()
                                      : 0;

                                  return _buildPlaceCard(place, distanceMeters);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _buildPlaceCard(Place place, int distanceMeters) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        child: InkWell(
          onTap: () => _navigateToPlace(place),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      place.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        place.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  place.type.capitalize(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      distanceMeters >= 1000 
                        ? '${(distanceMeters / 1000).toStringAsFixed(1)}km away'
                        : '${distanceMeters}m away',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    // User location marker
    if (_userLocation != null) {
      markers.add(
        Marker(
          point: LatLng(_userLocation!.latitude, _userLocation!.longitude),
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );
    }

    // Place markers
    for (final place in _nearbyPlaces) {
      if (place.latitude != null && place.longitude != null) {
        markers.add(
          Marker(
            point: LatLng(place.latitude!, place.longitude!),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => _navigateToPlace(place),
              child: Container(
                decoration: BoxDecoration(
                  color: _getPlaceColor(place.type),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    place.emoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return markers;
  }

  Color _getPlaceColor(String type) {
    switch (type.toLowerCase()) {
      case 'restaurant':
        return Colors.orange;
      case 'museum':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _navigateToPlace(Place place) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlaceDetailFactory.createDetailView(place),
      ),
    );
  }

  Future<void> _refresh() async {
    await _initializeLocationMap();
  }

}

extension StringCapitalize on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}