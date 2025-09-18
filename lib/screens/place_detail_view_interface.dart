// lib/screens/place_detail_interface.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/place.dart';
import '../models/visit.dart';
import '../models/place_statistic.dart';
import '../models/restaurant.dart';
import '../models/museum.dart';
import '../models/collection_base.dart';
import '../models/location.dart';
import '../providers/visits_provider.dart';
import '../providers/user_provider.dart';
import '../providers/collections_provider.dart';
import '../utils/default_place_images.dart';
import '../l10n/app_localizations.dart';
import 'visit_detail_screen.dart';
import 'collection_map_screen.dart';
import '../widgets/place_collections_overview.dart';
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
  
  // Abstract method for creating place-specific visits
  Future<Visit?> createVisit(BuildContext context);
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
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeroSection() {
    final place = widget.placeView.place;

    return Container(
      height: 180,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Enhanced background image with beautiful defaults
          DefaultPlaceImages.buildPlaceImage(
            placeType: place.type,
            placeName: place.name,
            imageUrl: place.imageUrl,
            emoji: place.emoji,
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
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
    return Flexible(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final l10n = AppLocalizations.of(context)!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Collections Overview - shows which collections this place belongs to
          PlaceCollectionsOverview(place: widget.placeView.place),
          
          const SizedBox(height: 16),
          
          ...widget.placeView.getOverviewContent(context),

          const SizedBox(height: 16),

          // Quick Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showOnMap(),
                  icon: const Icon(Icons.map_outlined, size: 16),
                  label: const Text('Show on Map'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _startNavigation(),
                  icon: const Icon(Icons.navigation, size: 16),
                  label: const Text('Navigate'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
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
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  bottomLeft: Radius.circular(16),
                                ),
                                child: kIsWeb 
                                    ? _buildPhotoPlaceholder()
                                    : _buildPhotoWidget(visit.photoUrls.first),
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
    // Handle empty or null content
    final displayContent = content.trim().isEmpty ? 'Nicht verfügbar' : content;

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
                  Text(
                    displayContent,
                    style: TextStyle(
                      color: content.trim().isEmpty ? Colors.grey : null,
                      fontStyle: content.trim().isEmpty ? FontStyle.italic : null,
                    ),
                  ),
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

  Widget _buildPhotoPlaceholder() {
    return Container(
      width: 120,
      height: 120,
      color: const Color(0xFFF3F4F6),
      child: Center(
        child: Icon(
          Icons.broken_image,
          size: 40,
          color: const Color(0xFF9CA3AF),
        ),
      ),
    );
  }

  Widget _buildPhotoWidget(String photoUrl) {
    // For now, just show placeholder on all platforms
    // In production, this would handle real file paths on mobile
    // and network URLs on web
    return _buildPhotoPlaceholder();
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  Widget _buildFloatingActionButton() {
    // Get the place-specific FAB for styling info
    final placeFab = widget.placeView.getFloatingActionButton(context);
    if (placeFab is FloatingActionButton) {
      return FloatingActionButton(
        onPressed: () => _addVisit(), // Use interface method
        backgroundColor: placeFab.backgroundColor,
        child: placeFab.child,
        heroTag: placeFab.heroTag,
      );
    }
    
    // Fallback generic FAB
    return FloatingActionButton(
      onPressed: () => _addVisit(),
      backgroundColor: Colors.blue,
      child: const Icon(Icons.add),
    );
  }

  void _addToFavorites() {
    // TODO: Implement
  }

  void _sharePlace() {
    // TODO: Implement
  }

  void _addVisit() async {
    try {
      // Use the place's specific visit creation dialog
      final visit = await widget.placeView.createVisit(context);
      
      if (visit != null && mounted) {
        // Add the visit to provider
        final visitsProvider = Provider.of<VisitsProvider>(context, listen: false);
        await visitsProvider.addVisit(visit);
        
        // Return the visit to the parent screen for collection updates
        Navigator.of(context).pop(visit);
        
        // Show confirmation message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Visit saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save visit: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showOnMap() {
    // Create a minimal collection just for this place to show on map
    final place = widget.placeView.place;
    final location = _createLocationFromPlace(place);
    
    if (location != null) {
      // Create a temporary collection for this single place
      final tempCollection = _createTempCollectionForPlace(place, location);
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CollectionMapScreen(collection: tempCollection),
        ),
      );
    } else {
      _showErrorSnackBar('No location information available for ${place.name}');
    }
  }

  void _startNavigation() async {
    final place = widget.placeView.place;
    final address = place.info.address;
    
    if (address.isEmpty) {
      _showErrorSnackBar('Address not available for navigation');
      return;
    }

    try {
      // Try to get precise coordinates first
      final location = _createLocationFromPlace(place);
      final encodedAddress = Uri.encodeComponent(address);
      List<String> urlsToTry = [];
      
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        // Try Apple Maps with coordinates first, then address fallback
        if (location != null && location.latitude != 0.0 && location.longitude != 0.0) {
          urlsToTry = [
            'http://maps.apple.com/?daddr=${location.latitude},${location.longitude}',
            'comgooglemaps://?daddr=${location.latitude},${location.longitude}',
            'http://maps.apple.com/?daddr=$encodedAddress',
            'https://www.google.com/maps/search/?api=1&query=$encodedAddress',
          ];
        } else {
          urlsToTry = [
            'http://maps.apple.com/?daddr=$encodedAddress',
            'comgooglemaps://?daddr=$encodedAddress',
            'https://www.google.com/maps/search/?api=1&query=$encodedAddress',
          ];
        }
      } else {
        // Try Google Maps with coordinates first, then address fallback
        if (location != null && location.latitude != 0.0 && location.longitude != 0.0) {
          urlsToTry = [
            'google.navigation:q=${location.latitude},${location.longitude}',
            'geo:${location.latitude},${location.longitude}?z=16',
            'google.navigation:q=$encodedAddress',
            'https://www.google.com/maps/search/?api=1&query=$encodedAddress',
          ];
        } else {
          urlsToTry = [
            'google.navigation:q=$encodedAddress',
            'geo:0,0?q=$encodedAddress',
            'https://www.google.com/maps/search/?api=1&query=$encodedAddress',
          ];
        }
      }
      
      bool launched = false;
      for (String mapUrl in urlsToTry) {
        try {
          final uri = Uri.parse(mapUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            launched = true;
            break;
          }
        } catch (e) {
          // Try next URL
          continue;
        }
      }
      
      if (!launched) {
        _showErrorSnackBar('No maps app available for navigation');
      }
      
    } catch (e) {
      _showErrorSnackBar('Could not open navigation: ${e.toString()}');
    }
  }

  Location? _createLocationFromPlace(Place place) {
    // Try to find the original location data by matching place ID with location ID
    // First check if we can get the real location from the collections provider
    final realLocation = _findOriginalLocation(place);
    if (realLocation != null) {
      return realLocation;
    }
    
    // Use the Place's own latitude and longitude if available (from API data)
    double? latitude = place.latitude;
    double? longitude = place.longitude;
    
    // If Place doesn't have coordinates, try to match with known locations
    if (latitude == null || longitude == null) {
      final locationCoords = _getCoordinatesForPlace(place);
      if (locationCoords != null) {
        latitude = locationCoords['lat']!;
        longitude = locationCoords['lng']!;
      } else if (place.info.address.isNotEmpty) {
        // If we have an address but no coordinates, use center of Bonn as fallback
        // This allows the map to show with address-based display
        latitude = 50.7374; // Bonn city center
        longitude = 7.0982;
      } else {
        // No coordinates or address available
        return null;
      }
    }
    
    return Location(
      id: place.id,
      name: place.name,
      address: place.info.address,
      latitude: latitude,
      longitude: longitude,
      features: place.info.highlights,
      phone: place.info.phone,
      website: place.info.website,
      isVisited: place.collectionStatus.isVisited,
    );
  }
  
  Location? _findOriginalLocation(Place place) {
    // Access collections provider to find the original location with validated coordinates
    try {
      final collectionsProvider = Provider.of<CollectionsProvider>(context, listen: false);
      
      // Search through all collections to find the location by ID
      for (final collection in collectionsProvider.collections) {
        for (final location in collection.locations) {
          if (location.id == place.id) {
            return location;
          }
        }
      }
    } catch (e) {
      // Provider not available or other error, continue to fallback
    }
    
    return null;
  }

  Map<String, double>? _getCoordinatesForPlace(Place place) {
    // Known coordinates for common places (matching home_screen.dart data)
    final knownCoordinates = <String, Map<String, double>>{
      'mc_1': {'lat': 50.9429, 'lng': 6.9584},
      'mc_2': {'lat': 50.9364, 'lng': 6.9528},
      'mc_3': {'lat': 50.9333, 'lng': 6.9472},
      'sb_1': {'lat': 50.9351, 'lng': 6.9543},
      'sb_2': {'lat': 50.9385, 'lng': 6.9555},
      'sb_3': {'lat': 50.9372, 'lng': 6.9601},
      // Add more as needed...
    };
    
    return knownCoordinates[place.id];
  }

  CollectionBase _createTempCollectionForPlace(Place place, Location location) {
    // Check if we're using fallback coordinates
    final usingFallback = place.latitude == null || place.longitude == null;
    final description = usingFallback 
        ? 'Approximate location - ${place.info.address}'
        : 'Single place view';
    
    // Create a minimal collection implementation for the map view
    return _TempCollection(
      id: 'temp_${place.id}',
      name: place.name,
      iconEmoji: place.emoji,
      description: description,
      createdAt: DateTime.now(),
      locations: [location],
      color: Colors.grey,
      collectionType: place.type,
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// Temporary collection class for single place map display
class _TempCollection extends CollectionBase {
  final String collectionType;

  _TempCollection({
    required super.id,
    required super.name,
    required super.iconEmoji,
    required super.description,
    required super.createdAt,
    required super.locations,
    required super.color,
    required this.collectionType,
  });

  @override
  Map<String, dynamic> get specificProperties => {
    'collectionType': collectionType,
  };
}