// lib/screens/place_detail_interface.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/place.dart';
import '../models/visit.dart';
import '../models/place_statistic.dart';
import '../models/restaurant.dart';
import '../models/museum.dart';
import '../providers/visits_provider.dart';
import '../l10n/app_localizations.dart';
// Dynamic imports to avoid circular dependency issues
// import 'place_detail_implementations/restaurant_detail_view.dart';
// import 'place_detail_implementations/museum_detail_view.dart';

// ================================
// PLACE DETAIL FACTORY
// ================================

class PlaceDetailFactory {
  static Widget createDetailView(Place place) {
    // Import implementations dynamically to avoid circular dependencies
    switch (place.type.toLowerCase()) {
      case 'restaurant':
        // Dynamic import
        return _createRestaurantDetailView(place as Restaurant);
      case 'museum':
        // Dynamic import  
        return _createMuseumDetailView(place as Museum);
    // case 'park':
    //   return ParkDetailView(park: place as Park);
      default:
        throw UnsupportedError('Place type "${place.type}" not supported');
    }
  }

  static Widget _createRestaurantDetailView(Restaurant restaurant) {
    // Late import to avoid circular dependency
    // ignore: unnecessary_import
    // This will be resolved at runtime
    throw UnimplementedError('RestaurantDetailView needs to be imported dynamically');
  }

  static Widget _createMuseumDetailView(Museum museum) {
    // Late import to avoid circular dependency  
    // ignore: unnecessary_import
    // This will be resolved at runtime
    throw UnimplementedError('MuseumDetailView needs to be imported dynamically');
  }

  // Optional: Liste aller unterstützten Place-Typen
  static List<String> get supportedPlaceTypes => [
    'restaurant',
    'museum',
    // 'park',
  ];

  // Optional: Prüfung ob ein Place-Typ unterstützt wird
  static bool isSupported(String placeType) {
    return supportedPlaceTypes.contains(placeType.toLowerCase());
  }
}

// ================================
// ABSTRACT INTERFACE
// ================================

abstract class PlaceDetailViewInterface extends StatefulWidget {
  final Place place;

  const PlaceDetailViewInterface({
    super.key,
    required this.place,
  });

  // Generische Eigenschaften die alle Orte haben
  String get placeName => place.name;
  String get placeType => place.type;
  String get heroEmoji => place.emoji;
  PlaceCollectionStatus get collectionStatus => place.collectionStatus;
  List<Visit> get visits => place.visits;
  PlaceInfo get basicInfo => place.info;

  // Spezifische Implementierung je Ort-Typ
  Widget buildSpecialTab(BuildContext context);
  String get specialTabLabel;
  String get specialTabIcon;
  List<PlaceStatistic> getSpecificStats(BuildContext? context);
  List<Widget> getOverviewContent(BuildContext context);
  Widget? getFloatingActionButton(BuildContext context);
}

// ================================
// GENERISCHE DETAIL VIEW
// ================================

class GenericPlaceDetailView extends StatefulWidget {
  final PlaceDetailViewInterface placeView;

  const GenericPlaceDetailView({
    super.key,
    required this.placeView,
  });

  @override
  State<GenericPlaceDetailView> createState() => _GenericPlaceDetailViewState();
}

class _GenericPlaceDetailViewState extends State<GenericPlaceDetailView> {
  int _currentTabIndex = 0;
  bool _showPrivateVisits = true; // Default to private visits

  @override
  Widget build(BuildContext context) {
    final place = widget.placeView.place;

    return Scaffold(
      appBar: AppBar(
        title: Text(place.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () => _addToFavorites(),
            icon: const Icon(Icons.favorite_border),
          ),
          IconButton(
            onPressed: () => _sharePlace(),
            icon: const Icon(Icons.share),
          ),
        ],
      ),

      body: Column(
        children: [
          // Hero Section (generisch)
          _buildHeroSection(),

          // Collection Status (generisch)
          _buildCollectionStatus(),

          // Tab Content
          Expanded(
            child: IndexedStack(
              index: _currentTabIndex,
              children: [
                _buildOverviewTab(),
                widget.placeView.buildSpecialTab(context),
                _buildVisitsTab(),
                _buildInfoTab(),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: _buildBottomNavigation(),
      floatingActionButton: widget.placeView.getFloatingActionButton(context),
    );
  }

  Widget _buildHeroSection() {
    final place = widget.placeView.place;

    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              place.emoji,
              style: const TextStyle(fontSize: 48),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    place.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    place.type,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionStatus() {
    final status = widget.placeView.collectionStatus;
    final specificStats = widget.placeView.getSpecificStats(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Column(
        children: [
          // Visit Status Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: status.isVisited ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    status.isVisited ? AppLocalizations.of(context)!.alreadyVisited : AppLocalizations.of(context)!.notVisitedYet,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (status.lastVisit != null)
                Text(
                  'Letzter Besuch: ${_formatDate(status.lastVisit!)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Statistics Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(AppLocalizations.of(context)!.visits, status.visitCount.toString()),
              ...specificStats.map((stat) => _buildStatItem(stat.label, stat.formattedValue)),
              if (status.userRating != null)
                _buildStatItem(AppLocalizations.of(context)!.myRating, status.userRating!.toStringAsFixed(1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    final l10n = AppLocalizations.of(context)!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ...widget.placeView.getOverviewContent(context),

          const SizedBox(height: 24),

          // Zentrale Add Visit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _addVisit(),
              icon: const Icon(Icons.add),
              label: Text(l10n.addNewVisit),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Quick Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _startRoute(),
                  child: const Text('Route'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _makeReservation(),
                  child: const Text('Reservieren'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisitsTab() {
    return Consumer<VisitsProvider>(
      builder: (context, visitsProvider, child) {
        final l10n = AppLocalizations.of(context)!;
        final allVisits = visitsProvider.getVisitsForPlace(widget.placeView.place.id);
        
        // Filter visits based on privacy setting
        final privateVisits = allVisits.where((visit) => !visit.isPublic).toList();
        final publicVisits = allVisits.where((visit) => visit.isPublic).toList();
        
        // Auto-switch to public if no private visits and user hasn't manually selected
        if (privateVisits.isEmpty && publicVisits.isNotEmpty && _showPrivateVisits) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _showPrivateVisits = false;
              });
            }
          });
        }
        
        final visitsToShow = _showPrivateVisits ? privateVisits : publicVisits;

        return Column(
          children: [
            // Toggle buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildToggleButton(
                      label: l10n.privateVisits,
                      isActive: _showPrivateVisits,
                      onTap: () => setState(() => _showPrivateVisits = true),
                      count: privateVisits.length,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildToggleButton(
                      label: l10n.publicVisitsPlace,
                      isActive: !_showPrivateVisits,
                      onTap: () => setState(() => _showPrivateVisits = false),
                      count: publicVisits.length,
                    ),
                  ),
                ],
              ),
            ),
            
            // Visit list or empty state
            Expanded(
              child: visitsToShow.isEmpty
                  ? _buildEmptyVisitsState(l10n, _showPrivateVisits, privateVisits.isEmpty, publicVisits.isEmpty)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: visitsToShow.length,
                      itemBuilder: (context, index) {
                        final visit = visitsToShow[index];
                        return _buildVisitCard(visit);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required int count,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF3B82F6) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
          border: isActive 
              ? null 
              : Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF6B7280),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                fontSize: 14,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white.withOpacity(0.2) : const Color(0xFF9CA3AF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyVisitsState(AppLocalizations l10n, bool showingPrivate, bool hasNoPrivate, bool hasNoPublic) {
    IconData icon;
    String title;
    String subtitle;
    
    if (showingPrivate) {
      icon = Icons.lock;
      title = l10n.noPrivateVisits;
      subtitle = hasNoPublic ? l10n.addFirstVisit : l10n.switchToPublic;
    } else {
      icon = Icons.public_off;
      title = l10n.noPublicVisitsForPlace;
      subtitle = hasNoPrivate ? l10n.comingSoon : l10n.switchToPrivate;
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              icon,
              size: 40,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitCard(Visit visit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      _formatDate(visit.date),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: visit.isPublic 
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            visit.isPublic ? Icons.public : Icons.lock,
                            size: 10,
                            color: visit.isPublic 
                                ? const Color(0xFF16A34A)
                                : const Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            visit.isPublic ? 'Public' : 'Private',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: visit.isPublic 
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (visit.overallRating != null)
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < visit.overallRating! ? Icons.star : Icons.star_border,
                        size: 16,
                        color: Colors.amber,
                      );
                    }),
                  ),
              ],
            ),

            if (visit.activities.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: visit.activities.map((activity) {
                  return Chip(
                    label: Text(activity.name),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ],

            if (visit.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                visit.notes!,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],

            if (visit.duration != null || visit.totalCost != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (visit.duration != null) ...[
                    const Icon(Icons.access_time, size: 16),
                    const SizedBox(width: 4),
                    Text('${visit.duration!.inHours}h ${visit.duration!.inMinutes % 60}min'),
                  ],
                  if (visit.duration != null && visit.totalCost != null)
                    const SizedBox(width: 16),
                  if (visit.totalCost != null) ...[
                    const Icon(Icons.euro, size: 16),
                    const SizedBox(width: 4),
                    Text('${visit.totalCost!.toStringAsFixed(2)}'),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTab() {
    final info = widget.placeView.basicInfo;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(
          Icons.location_on,
          'Adresse',
          info.address,
        ),

        if (info.openingHours.isNotEmpty)
          _buildInfoCard(
            Icons.access_time,
            'Öffnungszeiten',
            info.openingHours.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
          ),

        if (info.phone != null)
          _buildInfoCard(
            Icons.phone,
            'Telefon',
            info.phone!,
          ),

        if (info.website != null)
          _buildInfoCard(
            Icons.language,
            'Website',
            info.website!,
          ),

        if (info.highlights.isNotEmpty)
          _buildInfoCard(
            Icons.star,
            'Highlights',
            info.highlights.map((h) => '• $h').join('\n'),
          ),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(content),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentTabIndex,
      onTap: (index) => setState(() => _currentTabIndex = index),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard),
          label: AppLocalizations.of(context)!.overview,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant_menu),
          label: widget.placeView.specialTabLabel,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.calendar_today),
          label: AppLocalizations.of(context)!.visits,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.info),
          label: AppLocalizations.of(context)!.info,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  void _addToFavorites() {
    // TODO: Implement
  }

  void _sharePlace() {
    // TODO: Implement
  }

  void _addVisit() async {
    // Use the place's specific FAB functionality
    final fab = widget.placeView.getFloatingActionButton(context);
    if (fab is FloatingActionButton) {
      // Execute the FAB's onPressed function
      fab.onPressed?.call();
    }
  }

  void _startRoute() {
    // TODO: Open maps
  }

  void _makeReservation() {
    // TODO: Open reservation
  }
}