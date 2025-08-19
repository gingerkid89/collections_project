// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/collection_factory.dart';
import '../models/collection_base.dart';
import '../models/location.dart';
import 'collection_detail_screen.dart';
import 'settings_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CollectionBase> collections = [];

  @override
  void initState() {
    super.initState();
    _loadDummyData();
  }

  void _loadDummyData() {
    final mcdonalds = CollectionFactory.createMcDonalds();
    final starbucks = CollectionFactory.createStarbucks();
    final museums = CollectionFactory.createMuseums();

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
    ]);

    setState(() {
      collections = [mcdonalds, starbucks, museums];
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                      Column(
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
                      Row(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF3B82F6),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.add, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
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
                    child: _CollectionCard(collection: collection),
                  );
                },
              ),
            ),
          ],
        ),
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

  const _CollectionCard({required this.collection});

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
                        collection.visitedCount > 0 ? l10n.visitedToday : 'Not visited yet',
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
                onPressed: () {},
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