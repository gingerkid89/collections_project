// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/collection_factory.dart';
import '../models/collection_base.dart';
import '../models/location.dart';
import 'collection_detail_screen.dart';
import 'settings_screen.dart';
import 'recent_visits_screen.dart';
import 'collection_map_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CollectionBase> collections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDummyDataAsync();
  }

  Future<void> _loadDummyDataAsync() async {
    // Move heavy data creation to background to avoid blocking main thread
    await Future.delayed(const Duration(milliseconds: 10)); // Allow UI to render first
    
    setState(() {
      _isLoading = true;
    });
    
    // Create collections asynchronously
    final collectionData = await _createCollectionData();
    
    setState(() {
      collections = collectionData;
      _isLoading = false;
    });
  }

  Future<List<CollectionBase>> _createCollectionData() async {
    // Create collections one by one with yields to allow UI updates
    final mcdonalds = CollectionFactory.createMcDonalds();
    await Future.delayed(const Duration(milliseconds: 1));
    
    final starbucks = CollectionFactory.createStarbucks();
    await Future.delayed(const Duration(milliseconds: 1));
    
    final museums = CollectionFactory.createMuseums();
    await Future.delayed(const Duration(milliseconds: 1));
    
    final italianRestaurants = CollectionFactory.createItalianRestaurants();
    await Future.delayed(const Duration(milliseconds: 1));
    
    final artMuseums = CollectionFactory.createArtMuseums();
    await Future.delayed(const Duration(milliseconds: 1));
    
    final scienceMuseums = CollectionFactory.createScienceMuseums();
    await Future.delayed(const Duration(milliseconds: 1));

    mcdonalds.locations.addAll([
      Location(
        id: 'mc_1',
        name: "McDonald's Hauptbahnhof",
        address: 'Trankgasse 11, 50667 Köln',
        latitude: 50.9429,
        longitude: 6.9584,
        imageUrls: ['https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=300&h=300&fit=crop'],
        features: ['Drive-Through', 'McCafé', '24h Service'],
        averageRating: 4.2,
        isVisited: true,
      ),
      Location(
        id: 'mc_2',
        name: "McDonald's Schildergasse",
        address: 'Schildergasse 65, 50667 Köln',
        latitude: 50.9364,
        longitude: 6.9528,
        imageUrls: ['https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=300&h=300&fit=crop'],
        features: ['McCafé', 'WiFi'],
        averageRating: 4.0,
        isVisited: true,
      ),
      Location(
        id: 'mc_3',
        name: "McDonald's Neumarkt",
        address: 'Neumarkt 1c, 50667 Köln',
        latitude: 50.9333,
        longitude: 6.9472,
        imageUrls: ['https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=300&h=300&fit=crop'],
        features: ['Playground', 'WiFi'],
        averageRating: 4.1,
      ),
    ]);
    await Future.delayed(const Duration(milliseconds: 1));
    await Future.delayed(const Duration(milliseconds: 1));

    starbucks.locations.addAll([
      Location(
        id: 'sb_1',
        name: 'Starbucks Friedensplatz',
        address: 'Friedensplatz 1, 50667 Köln',
        latitude: 50.9351,
        longitude: 6.9543,
        imageUrls: ['https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=300&h=300&fit=crop'],
        features: ['WiFi', 'Outdoor Seating'],
        averageRating: 4.3,
        isVisited: true,
      ),
      Location(
        id: 'sb_2',
        name: 'Starbucks Hohe Straße',
        address: 'Hohe Str. 52, 50667 Köln',
        latitude: 50.9375,
        longitude: 6.9603,
        imageUrls: ['https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=300&h=300&fit=crop'],
        features: ['WiFi', 'Mobile Order'],
        averageRating: 4.1,
      ),
    ]);
    await Future.delayed(const Duration(milliseconds: 1));

    museums.locations.addAll([
      Location(
        id: 'museum_1',
        name: 'Museum Ludwig',
        address: 'Heinrich-Böll-Platz, 50667 Köln',
        latitude: 50.9406,
        longitude: 6.9623,
        imageUrls: ['https://images.unsplash.com/photo-1554907984-15263bfd63bd?w=300&h=300&fit=crop'],
        features: ['Modern Art', 'Audio Guide'],
        averageRating: 4.5,
        isVisited: true,
      ),
      Location(
        id: 'museum_2',
        name: 'Wallraf-Richartz-Museum',
        address: 'Obenmarspforten 40, 50667 Köln',
        latitude: 50.9395,
        longitude: 6.9598,
        imageUrls: ['https://images.unsplash.com/photo-1545558014-8692077e9b5c?w=300&h=300&fit=crop'],
        features: ['Classical Art', 'Audio Guide', 'Café'],
        averageRating: 4.3,
      ),
      Location(
        id: 'museum_3',
        name: 'Romano-Germanisches Museum',
        address: 'Roncalliplatz 4, 50667 Köln',
        latitude: 50.9413,
        longitude: 6.9581,
        imageUrls: ['https://images.unsplash.com/photo-1587825140708-dfaf72ae4b04?w=300&h=300&fit=crop'],
        features: ['Roman History', 'Mosaics', 'Audio Guide'],
        averageRating: 4.4,
        isVisited: true,
      ),
    ]);
    await Future.delayed(const Duration(milliseconds: 1));

    // Italian Restaurants
    italianRestaurants.locations.addAll([
      Location(
        id: 'italian_1',
        name: 'La Dolce Vita',
        address: 'Aachener Str. 15, 50674 Köln',
        latitude: 50.9351,
        longitude: 6.9255,
        imageUrls: ['https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=300&h=300&fit=crop'],
        features: ['Authentic Pizza', 'Wine Selection', 'Terrace'],
        averageRating: 4.6,
        isVisited: true,
      ),
      Location(
        id: 'italian_2',
        name: 'Osteria Il Convivio',
        address: 'Ehrenstr. 77, 50672 Köln',
        latitude: 50.9312,
        longitude: 6.9389,
        imageUrls: ['https://images.unsplash.com/photo-1579952363873-27d3bfad9c0d?w=300&h=300&fit=crop'],
        features: ['Fresh Pasta', 'Italian Wine', 'Romantic Setting'],
        averageRating: 4.7,
      ),
      Location(
        id: 'italian_3',
        name: 'Trattoria da Nino',
        address: 'Venloer Str. 45, 50672 Köln',
        latitude: 50.9442,
        longitude: 6.9267,
        imageUrls: ['https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=300&h=300&fit=crop'],
        features: ['Family Recipe', 'Homemade Pasta', 'Cozy Atmosphere'],
        averageRating: 4.5,
        isVisited: true,
      ),
      Location(
        id: 'italian_4',
        name: 'Ristorante San Remo',
        address: 'Römerstr. 23, 50676 Köln',
        latitude: 50.9356,
        longitude: 6.9612,
        imageUrls: ['https://images.unsplash.com/photo-1555992336-03a23981e3ba?w=300&h=300&fit=crop'],
        features: ['Seafood Special', 'Italian Classics', 'Business Lunch'],
        averageRating: 4.4,
      ),
      Location(
        id: 'italian_5',
        name: 'Pizzeria Mama Mia',
        address: 'Zülpicher Str. 28, 50674 Köln',
        latitude: 50.9298,
        longitude: 6.9345,
        imageUrls: ['https://images.unsplash.com/photo-1513104890138-7c749659a591?w=300&h=300&fit=crop'],
        features: ['Wood Fired Pizza', 'Takeaway', 'Student Friendly'],
        averageRating: 4.2,
      ),
    ]);
    await Future.delayed(const Duration(milliseconds: 1));


    // Art Museums
    artMuseums.locations.addAll([
      Location(
        id: 'art_museum_1',
        name: 'Museum für Angewandte Kunst',
        address: 'An der Rechtschule, 50667 Köln',
        latitude: 50.9389,
        longitude: 6.9634,
        imageUrls: ['https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=300&h=300&fit=crop'],
        features: ['Design', 'Decorative Arts', 'Contemporary'],
        averageRating: 4.2,
        isVisited: true,
      ),
      Location(
        id: 'art_museum_2',
        name: 'Kölnischer Kunstverein',
        address: 'Drususgasse 1-5, 50667 Köln',
        latitude: 50.9401,
        longitude: 6.9567,
        imageUrls: ['https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=300&h=300&fit=crop'],
        features: ['Contemporary Art', 'Exhibitions', 'Artist Talks'],
        averageRating: 4.3,
      ),
      Location(
        id: 'art_museum_3',
        name: 'Käthe Kollwitz Museum',
        address: 'Neumarkt 18-24, 50667 Köln',
        latitude: 50.9356,
        longitude: 6.9472,
        imageUrls: ['https://images.unsplash.com/photo-1577720643271-6760b5d4c52d?w=300&h=300&fit=crop'],
        features: ['Sculpture', 'Prints', 'Historical Context'],
        averageRating: 4.4,
      ),
    ]);
    await Future.delayed(const Duration(milliseconds: 1));

    // Science Museums
    scienceMuseums.locations.addAll([
      Location(
        id: 'science_museum_1',
        name: 'Odysseum Köln',
        address: 'Corintostr. 1, 51103 Köln',
        latitude: 50.8901,
        longitude: 7.0156,
        imageUrls: ['https://images.unsplash.com/photo-1581833971358-2c8b550f87b3?w=300&h=300&fit=crop'],
        features: ['Interactive', 'Planetarium', 'Family Friendly'],
        averageRating: 4.5,
        isVisited: true,
      ),
      Location(
        id: 'science_museum_2',
        name: 'Deutsches Sport & Olympia Museum',
        address: 'Im Zollhafen 1, 50678 Köln',
        latitude: 50.9267,
        longitude: 6.9656,
        imageUrls: ['https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=300&h=300&fit=crop'],
        features: ['Sports History', 'Olympics', 'Interactive'],
        averageRating: 4.3,
      ),
      Location(
        id: 'science_museum_3',
        name: 'Imhoff Chocolate Museum',
        address: 'Am Schokoladenmuseum 1A, 50678 Köln',
        latitude: 50.9312,
        longitude: 6.9689,
        imageUrls: ['https://images.unsplash.com/photo-1481391319762-47dff72954d9?w=300&h=300&fit=crop'],
        features: ['Chocolate Making', 'Tastings', 'Gift Shop'],
        averageRating: 4.6,
      ),
    ]);
    await Future.delayed(const Duration(milliseconds: 1));

    // Allow UI to breathe between heavy operations
    await Future.delayed(const Duration(milliseconds: 5));
    
    return [
      mcdonalds, 
      starbucks, 
      italianRestaurants,
      museums,
      artMuseums,
      scienceMuseums,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Show loading state while data is being created
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final totalVisited = collections.fold<int>(0, (sum, c) => sum + c.visitedCount);
    final totalLocations = collections.fold<int>(0, (sum, c) => sum + c.totalCount);
    final overallProgress = totalLocations > 0 ? (totalVisited / totalLocations) * 100 : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.myCollections,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.discoverAndCollect,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const RecentVisitsScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.history, color: Color(0xFF6B7280)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const SettingsScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.settings, color: Color(0xFF6B7280)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: l10n.searchPlacesOrCollections,
                        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      value: totalVisited.toString(),
                      label: l10n.visited,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      value: totalLocations.toString(),
                      label: l10n.total,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      value: '${overallProgress.toStringAsFixed(1)}%',
                      label: l10n.progress,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.activeCollections,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        _ViewModeButton(Icons.view_list, true),
                        _ViewModeButton(Icons.map, false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: collections.length,
                itemBuilder: (context, index) {
                  final collection = collections[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _CollectionCard(
                      collection: collection,
                      onMapPressed: () => _openCollectionMap(collection),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCollectionMap(CollectionBase collection) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CollectionMapScreen(collection: collection),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewModeButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;

  const _ViewModeButton(this.icon, this.isActive);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        boxShadow: isActive
            ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]
            : null,
      ),
      child: Icon(
        icon,
        size: 16,
        color: isActive ? const Color(0xFF374151) : const Color(0xFF9CA3AF),
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final CollectionBase collection;
  final VoidCallback onMapPressed;

  const _CollectionCard({
    required this.collection,
    required this.onMapPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CollectionDetailScreen(collection: collection),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      collection.iconEmoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        collection.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        collection.visitedCount > 0 ? l10n.visitedToday : l10n.notVisitedYet,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${collection.visitedCount}/${collection.totalCount}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Text(
                      '${collection.progressPercentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: collection.progressPercentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: _getCollectionColor(collection),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onMapPressed,
                icon: const Icon(Icons.map, size: 16),
                label: Text(l10n.map),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6B7280),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCollectionColor(CollectionBase collection) {
    switch (collection.iconEmoji) {
      case '🍟':
        return const Color(0xFFEF4444);
      case '☕':
        return const Color(0xFF10B981);
      case '🏛️':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF3B82F6);
    }
  }

}