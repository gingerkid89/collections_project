// lib/screens/collection_map_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/collection_base.dart';
import '../models/location.dart';
import '../models/place.dart';
import '../models/restaurant.dart';
import '../models/museum.dart';
import '../models/menu_item.dart';
import '../models/visit.dart';
import '../providers/visits_provider.dart';
import '../l10n/app_localizations.dart';
import 'place_detail_factory.dart';

class CollectionMapScreen extends StatefulWidget {
  final CollectionBase? collection;
  final List<CollectionBase>? collections;
  final bool showAllPlaces;

  const CollectionMapScreen({
    super.key,
    required this.collection,
  }) : collections = null, showAllPlaces = false;

  const CollectionMapScreen.allPlaces({
    super.key,
    required this.collections,
  }) : collection = null, showAllPlaces = true;

  @override
  State<CollectionMapScreen> createState() => _CollectionMapScreenState();
}

class _CollectionMapScreenState extends State<CollectionMapScreen> {
  final MapController _mapController = MapController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitBounds();
    });
  }

  void _fitBounds() {
    final locations = _getAllLocations()
        .where((loc) => loc.latitude != 0.0 && loc.longitude != 0.0)
        .toList();
    
    if (locations.isEmpty) return;
    
    if (locations.length == 1) {
      // Single location - center on it
      _mapController.move(
        LatLng(locations.first.latitude, locations.first.longitude),
        13.0,
      );
    } else {
      // Multiple locations - fit all in view  
      final coordinates = locations.map((location) => 
        LatLng(location.latitude, location.longitude)
      ).toList();
      
      final bounds = LatLngBounds.fromPoints(coordinates);
      _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)));
    }
  }

  List<Location> _getAllLocations() {
    if (widget.showAllPlaces && widget.collections != null) {
      return widget.collections!
          .expand((collection) => collection.locations)
          .toList();
    } else if (widget.collection != null) {
      return widget.collection!.locations;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.showAllPlaces ? 'All Places' : '${widget.collection!.name} Map'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _fitBounds,
            icon: const Icon(Icons.center_focus_strong),
            tooltip: 'Fit all locations',
          ),
        ],
      ),
      body: Column(
        children: [
          // Collection info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: _getCollectionColor().withOpacity(0.1),
            child: Row(
              children: [
                Text(
                  widget.showAllPlaces ? '📍' : widget.collection!.iconEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.showAllPlaces ? 'All Places' : widget.collection!.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.showAllPlaces 
                          ? '${_getTotalVisitedCount()}/${_getTotalLocationCount()} visited'
                          : '${widget.collection!.visitedCount}/${widget.collection!.totalCount} visited',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Map
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(52.5200, 13.4050), // Berlin default
                initialZoom: 10.0,
                minZoom: 3.0,
                maxZoom: 18.0,
              ),
              children: [
                // Tile layer (OpenStreetMap)
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.collection_app',
                  maxNativeZoom: 19,
                ),
                
                // Markers layer
                MarkerLayer(
                  markers: _buildMarkers(),
                ),
              ],
            ),
          ),
        ],
      ),
      
      // Bottom info panel
      bottomSheet: _buildBottomSheet(),
    );
  }

  List<Marker> _buildMarkers() {
    final allLocations = _getAllLocations();
    return allLocations
        .where((location) => location.latitude != 0.0 && location.longitude != 0.0)
        .map((location) => _buildMarker(location))
        .toList();
  }

  int _getTotalVisitedCount() {
    if (widget.collections == null) return 0;
    return widget.collections!
        .expand((collection) => collection.locations)
        .where((location) => location.isVisited)
        .length;
  }

  int _getTotalLocationCount() {
    if (widget.collections == null) return 0;
    return widget.collections!
        .expand((collection) => collection.locations)
        .length;
  }

  Marker _buildMarker(Location location) {
    final collection = _getCollectionForLocation(location);
    final color = location.isVisited 
        ? (collection?.color ?? Colors.grey)
        : Colors.grey.shade400;
    final emoji = collection?.iconEmoji ?? '📍';

    return Marker(
      point: LatLng(location.latitude, location.longitude),
      width: 50,
      height: 50,
      child: GestureDetector(
        onTap: () => _navigateToLocationDetail(location),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }

  CollectionBase? _getCollectionForLocation(Location location) {
    if (widget.showAllPlaces && widget.collections != null) {
      // Find which collection this location belongs to
      for (final collection in widget.collections!) {
        if (collection.locations.any((loc) => loc.id == location.id)) {
          return collection;
        }
      }
      return null;
    } else {
      return widget.collection;
    }
  }

  Widget _buildBottomSheet() {
    final visitedLocations = widget.showAllPlaces 
        ? _getTotalVisitedCount() 
        : widget.collection!.locations.where((l) => l.isVisited).length;
    final totalLocations = widget.showAllPlaces 
        ? _getTotalLocationCount() 
        : widget.collection!.locations.length;
    final progress = totalLocations > 0 ? visitedLocations / totalLocations : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(_getCollectionColor()),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(
                  color: _getCollectionColor(),
                  label: 'Visited ($visitedLocations)',
                ),
                _buildLegendItem(
                  color: Colors.grey.shade400,
                  label: 'Not Visited (${totalLocations - visitedLocations})',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Color _getCollectionColor() {
    if (widget.showAllPlaces) {
      return const Color(0xFF3B82F6); // Default blue for all places view
    }
    
    // Use the collection's color property
    return widget.collection?.color ?? const Color(0xFF3B82F6);
  }

  void _navigateToLocationDetail(Location location) async {
    // Convert Location to appropriate Place type based on collection
    final place = _convertLocationToPlace(location);
    
    if (place != null) {
      final detailView = PlaceDetailFactory.createDetailView(place);
      final result = await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => detailView),
      );
      
      // If a visit was created and returned, mark location as visited
      if (result != null && result is Visit && mounted) {
        // Visit is already added by the interface - no need to add again
        final visitsProvider = Provider.of<VisitsProvider>(context, listen: false);
        
        setState(() {
          // Use the actual rating from the visit instead of hardcoded 5
          location.markAsVisited(rating: result.overallRating?.toInt() ?? 5);
        });
        
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Visit saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } else {
      // Fallback: show simple location info
      _showLocationDetails(location);
    }
  }

  void _showLocationDetails(Location location) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Location info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: location.isVisited 
                          ? _getCollectionColor() 
                          : Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _getCollectionForLocation(location)?.iconEmoji ?? '📍',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          location.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          location.address.trim().isEmpty ? 'Adresse nicht verfügbar' : location.address,
                          style: TextStyle(
                            color: location.address.trim().isEmpty ? Colors.grey.shade400 : Colors.grey,
                            fontSize: 14,
                            fontStyle: location.address.trim().isEmpty ? FontStyle.italic : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: location.isVisited 
                                ? Colors.green.shade100 
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            location.isVisited ? 'Visited' : 'Not Visited',
                            style: TextStyle(
                              fontSize: 12,
                              color: location.isVisited 
                                  ? Colors.green.shade700 
                                  : Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openInMaps(location),
                      icon: const Icon(Icons.navigation, size: 18),
                      label: const Text('Navigate'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _viewLocationDetails(location),
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text('View Details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getCollectionColor(),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openInMaps(Location location) {
    // TODO: Open in external maps app
    // This would use url_launcher to open Google Maps or Apple Maps
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigation feature coming soon!')),
    );
  }

  void _viewLocationDetails(Location location) {
    Navigator.of(context).pop(); // Close bottom sheet first
    
    // Navigate to place detail view if we have place data
    // For now, just show a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening details for ${location.name}')),
    );
  }

  // Location to Place conversion methods
  Place? _convertLocationToPlace(Location location) {
    // Create a Place object from Location based on collection type
    final collection = _getCollectionForLocation(location);
    if (collection == null) return null;
    
    final collectionType = collection.collectionType;
    
    switch (collectionType) {
      case 'restaurant':
        return _createRestaurantFromLocation(location);
      case 'museum':
        return _createMuseumFromLocation(location);
      default:
        return null;
    }
  }

  // Generic helper to get existing visits for any location
  List<Visit> _getExistingVisits(String locationId) {
    final visitsProvider = Provider.of<VisitsProvider>(context, listen: false);
    return visitsProvider.getVisitsForPlace(locationId);
  }

  // Generic helper to create collection status based on visits and location data
  PlaceCollectionStatus _createCollectionStatus(Location location, List<Visit> visits) {
    final visitsProvider = Provider.of<VisitsProvider>(context, listen: false);
    
    return PlaceCollectionStatus(
      isVisited: visitsProvider.hasVisited(location.id),
      lastVisit: visitsProvider.getLastVisitDate(location.id),
      userRating: visitsProvider.getAverageRating(location.id),
      visitCount: visitsProvider.getVisitCount(location.id),
    );
  }

  Restaurant _createRestaurantFromLocation(Location location) {
    // Determine restaurant type based on location name and collection
    final locationName = location.name.toLowerCase();
    final collection = _getCollectionForLocation(location);
    final collectionName = collection?.name.toLowerCase() ?? '';
    
    if (locationName.contains('starbucks') || collectionName.contains('starbucks')) {
      return _createStarbucksFromLocation(location);
    } else if (collectionName.contains('italian') || 
               locationName.contains('italian') ||
               locationName.contains('dolce vita') ||
               locationName.contains('osteria') ||
               locationName.contains('trattoria') ||
               locationName.contains('ristorante') ||
               locationName.contains('pizzeria')) {
      return _createItalianRestaurantFromLocation(location);
    } else {
      return _createMcDonaldsFromLocation(location);
    }
  }

  Restaurant _createMcDonaldsFromLocation(Location location) {
    // Get existing visits for this location
    final existingVisits = _getExistingVisits(location.id);
    
    // Create a simplified McDonald's menu (just key items for performance)
    final mcdonaldsMenu = [
      MenuItem(
        id: 'mc_big_mac',
        name: 'Big Mac',
        description: 'Zwei Rindfleisch-Patties, Spezialsoße, Salat, Käse, Zwiebeln und Gewürzgurken auf einem Sesambrötchen',
        price: 5.50,
        category: 'Burger',
      ),
      MenuItem(
        id: 'mc_fries_medium',
        name: 'Pommes frites mittel',
        description: 'Goldgelbe, knusprige Pommes frites',
        price: 3.20,
        category: 'Pommes & Beilagen',
      ),
      MenuItem(
        id: 'mc_coca_cola',
        name: 'Coca-Cola 0,4l',
        description: 'Erfrischende Coca-Cola',
        price: 2.50,
        category: 'Getränke',
      ),
    ];

    return Restaurant(
      id: location.id,
      name: location.name,
      cuisine: 'Fast Food',
      priceCategory: '€€',
      menu: mcdonaldsMenu,
      collectionStatus: _createCollectionStatus(location, existingVisits),
      visits: existingVisits,
      info: PlaceInfo(
        address: location.address,
        phone: location.phone,
        website: location.website,
        openingHours: location.openingHours != null 
            ? {'daily': location.openingHours!} 
            : {},
        highlights: location.features,
      ),
      hasReservation: false,
      hasDelivery: true,
      hasTakeout: true,
    );
  }

  Restaurant _createStarbucksFromLocation(Location location) {
    final existingVisits = _getExistingVisits(location.id);
    
    final starbucksMenu = [
      MenuItem(
        id: 'sb_latte',
        name: 'Caffè Latte',
        description: 'Espresso mit gedämpfter Milch',
        price: 4.25,
        category: 'Kaffee',
      ),
      MenuItem(
        id: 'sb_cappuccino',
        name: 'Cappuccino',
        description: 'Espresso mit heißer Milch und Milchschaum',
        price: 3.95,
        category: 'Kaffee',
      ),
      MenuItem(
        id: 'sb_muffin',
        name: 'Blueberry Muffin',
        description: 'Fluffiger Muffin mit Blaubeeren',
        price: 3.50,
        category: 'Snacks',
      ),
    ];

    return Restaurant(
      id: location.id,
      name: location.name,
      cuisine: 'Café',
      priceCategory: '€€',
      menu: starbucksMenu,
      collectionStatus: _createCollectionStatus(location, existingVisits),
      visits: existingVisits,
      info: PlaceInfo(
        address: location.address,
        phone: location.phone,
        website: location.website,
        openingHours: location.openingHours != null 
            ? {'daily': location.openingHours!} 
            : {},
        highlights: location.features,
      ),
      hasReservation: false,
      hasDelivery: false,
      hasTakeout: true,
    );
  }

  Restaurant _createItalianRestaurantFromLocation(Location location) {
    final existingVisits = _getExistingVisits(location.id);
    
    final italianMenu = [
      MenuItem(
        id: 'it_carbonara',
        name: 'Spaghetti Carbonara',
        description: 'Spaghetti mit Speck, Ei und Parmesan',
        price: 12.90,
        category: 'Pasta',
      ),
      MenuItem(
        id: 'it_margherita',
        name: 'Pizza Margherita',
        description: 'Pizza mit Tomaten, Mozzarella und Basilikum',
        price: 9.50,
        category: 'Pizza',
      ),
      MenuItem(
        id: 'it_tiramisu',
        name: 'Tiramisu',
        description: 'Klassisches italienisches Dessert',
        price: 6.50,
        category: 'Desserts',
      ),
    ];

    return Restaurant(
      id: location.id,
      name: location.name,
      cuisine: 'Italienisch',
      priceCategory: '€€€',
      menu: italianMenu,
      collectionStatus: _createCollectionStatus(location, existingVisits),
      visits: existingVisits,
      info: PlaceInfo(
        address: location.address,
        phone: location.phone,
        website: location.website,
        openingHours: location.openingHours != null 
            ? {'daily': location.openingHours!} 
            : {},
        highlights: location.features,
      ),
      hasReservation: true,
      hasDelivery: true,
      hasTakeout: true,
    );
  }

  Museum _createMuseumFromLocation(Location location) {
    final existingVisits = _getExistingVisits(location.id);
    
    return Museum(
      id: location.id,
      name: location.name,
      category: 'Mixed',
      ticketPrice: '€12.00',
      currentExhibitions: location.features.take(2).toList(),
      permanentCollections: location.features.isNotEmpty 
          ? location.features 
          : ['Permanent Collection'],
      collectionStatus: _createCollectionStatus(location, existingVisits),
      visits: existingVisits,
      info: PlaceInfo(
        address: location.address,
        phone: location.phone,
        website: location.website,
        openingHours: location.openingHours != null 
            ? {'daily': location.openingHours!} 
            : {},
        highlights: location.features,
      ),
      hasAudioGuide: true,
      hasGiftShop: true,
      isWheelchairAccessible: true,
    );
  }
}