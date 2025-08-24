// lib/screens/place_detail_interface.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/place.dart';
import '../models/visit.dart';
import '../models/place_statistic.dart';
import '../models/restaurant.dart';
import '../models/museum.dart';
import '../providers/visits_provider.dart';
import '../providers/user_provider.dart';
import '../l10n/app_localizations.dart';
import 'visit_detail_screen.dart';
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
  bool _hasUserManuallySelectedTab = false; // Track if user has manually selected

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
    return Consumer2<VisitsProvider, UserProvider>(
      builder: (context, visitsProvider, userProvider, child) {
        final l10n = AppLocalizations.of(context)!;
        final currentUserId = userProvider.currentUserId ?? '';
        final allVisits = visitsProvider.getVisitsForPlace(widget.placeView.place.id);
        
        // Filter visits based on user ownership
        final myVisits = allVisits.where((visit) => visit.userId == currentUserId).toList();
        final otherUsersVisits = allVisits.where((visit) => visit.userId != currentUserId && visit.isPublic).toList();
        
        // Auto-switch to other users' visits if no my visits and user hasn't manually selected
        if (myVisits.isEmpty && otherUsersVisits.isNotEmpty && _showPrivateVisits && !_hasUserManuallySelectedTab) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _showPrivateVisits = false;
              });
            }
          });
        }
        
        final visitsToShow = _showPrivateVisits ? myVisits : otherUsersVisits;

        return Column(
          children: [
            // Toggle buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildToggleButton(
                      label: l10n.myVisits,
                      isActive: _showPrivateVisits,
                      onTap: () => setState(() {
                        _showPrivateVisits = true;
                        _hasUserManuallySelectedTab = true;
                      }),
                      count: myVisits.length,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildToggleButton(
                      label: l10n.visitsByOtherUsers,
                      isActive: !_showPrivateVisits,
                      onTap: () => setState(() {
                        _showPrivateVisits = false;
                        _hasUserManuallySelectedTab = true;
                      }),
                      count: otherUsersVisits.length,
                    ),
                  ),
                ],
              ),
            ),
            
            // Visit list or empty state
            Expanded(
              child: visitsToShow.isEmpty
                  ? _buildEmptyVisitsState(l10n, _showPrivateVisits, myVisits.isEmpty, otherUsersVisits.isEmpty)
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFF6B7280),
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
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
      icon = Icons.person;
      title = l10n.noMyVisits;
      subtitle = hasNoPublic ? l10n.addFirstVisit : l10n.switchToOthersVisits;
    } else {
      icon = Icons.people_outline;
      title = l10n.noVisitsByOtherUsers;
      subtitle = hasNoPrivate ? l10n.comingSoon : l10n.switchToMyVisits;
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
    final l10n = AppLocalizations.of(context)!;
    
    return GestureDetector(
      onTap: () => _openVisitDetail(visit),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo and header section
            Container(
              height: 120,
              child: Row(
                children: [
                  // Photo preview
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    child: visit.photoUrls.isNotEmpty
                        ? Stack(
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.image,
                                    size: 40,
                                    color: const Color(0xFF9CA3AF),
                                  ),
                                ),
                              ),
                              if (visit.photoUrls.length > 1)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '+${visit.photoUrls.length - 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : Center(
                            child: Icon(
                              Icons.photo_library_outlined,
                              size: 32,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                  ),
                  
                  // Content section
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Date and privacy row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDateShort(visit.date),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: visit.isPublic
                                      ? const Color(0xFFDCFCE7)
                                      : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      visit.isPublic ? Icons.public : Icons.lock,
                                      size: 12,
                                      color: visit.isPublic
                                          ? const Color(0xFF16A34A)
                                          : const Color(0xFF6B7280),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      visit.isPublic ? 'Public' : 'Private',
                                      style: TextStyle(
                                        fontSize: 10,
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
                          
                          // Notes preview
                          if (visit.notes?.isNotEmpty == true)
                            Text(
                              visit.notes!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          
                          // Bottom row with stats and rating
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Quick stats
                              Row(
                                children: [
                                  if (visit.totalCost != null) ...[
                                    Icon(Icons.euro, size: 14, color: const Color(0xFF6B7280)),
                                    const SizedBox(width: 2),
                                    Text(
                                      visit.totalCost!.toStringAsFixed(0),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B7280),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                  if (visit.activities.isNotEmpty && visit.totalCost != null)
                                    const SizedBox(width: 8),
                                  if (visit.activities.isNotEmpty) ...[
                                    Icon(Icons.local_activity, size: 14, color: const Color(0xFF6B7280)),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${visit.activities.length}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B7280),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              
                              // Rating
                              if (visit.overallRating != null)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: const Color(0xFFFB923C),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      visit.overallRating!.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // View Details button
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.viewDetails,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF3B82F6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 14,
                    color: const Color(0xFF3B82F6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openVisitDetail(Visit visit) {
    // Get place name from metadata or use a fallback
    final placeName = visit.metadata['placeName']?.toString() ?? 
                     widget.placeView.place.name;
                     
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VisitDetailScreen(
          visit: visit,
          placeName: placeName,
        ),
      ),
    );
  }

  String _formatDateShort(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final visitDate = DateTime(date.year, date.month, date.day);

    if (visitDate == today) {
      return 'Today, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (visitDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
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