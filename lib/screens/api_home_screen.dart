// lib/screens/api_home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/collection_base.dart';
import '../providers/places_provider.dart';
import '../providers/collections_provider.dart';
import 'collection_detail_screen.dart';
import 'settings_screen.dart';
import 'recent_visits_screen.dart';
import 'collection_map_screen.dart';
import 'place_creation/place_type_selection_dialog.dart';

class ApiHomeScreen extends StatefulWidget {
  const ApiHomeScreen({super.key});

  @override
  State<ApiHomeScreen> createState() => _ApiHomeScreenState();
}

class _ApiHomeScreenState extends State<ApiHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CollectionsProvider>(
      builder: (context, collectionsProvider, child) {
        final l10n = AppLocalizations.of(context)!;
        
        if (collectionsProvider.isLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFFF9FAFB),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading places...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (collectionsProvider.error != null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load places',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    collectionsProvider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => collectionsProvider.refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Get collections directly from provider
        final collections = collectionsProvider.collections;
        
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
                              IconButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const RecentVisitsScreen()),
                                ),
                                icon: const Icon(Icons.history, color: Color(0xFF6B7280)),
                                tooltip: l10n.recentVisits,
                              ),
                              IconButton(
                                onPressed: () {
                                  if (collections.isNotEmpty) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => CollectionMapScreen.allPlaces(collections: collections),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.map_outlined, color: Color(0xFF6B7280)),
                                tooltip: 'Explore Map',
                              ),
                              IconButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                                ),
                                icon: const Icon(Icons.settings, color: Color(0xFF6B7280)),
                                tooltip: l10n.settings,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Progress Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Your Progress',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${overallProgress.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: overallProgress / 100,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '$totalVisited of $totalLocations places visited',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Collections and Create Button
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Collections Grid
                        if (collections.isNotEmpty)
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: collections.length,
                            itemBuilder: (context, index) {
                              final collection = collections[index];
                              return _CollectionCard(collection: collection);
                            },
                          )
                        else
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 64,
                                    color: Color(0xFF6B7280),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No places found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Start by creating your first place',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        
                        const SizedBox(height: 32),
                        
                        // Create Place Button
                        _CreatePlaceButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final CollectionBase collection;

  const _CollectionCard({required this.collection});

  @override
  Widget build(BuildContext context) {
    final progress = collection.totalCount > 0 
        ? (collection.visitedCount / collection.totalCount) * 100 
        : 0.0;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CollectionDetailScreen(collection: collection),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: collection.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        collection.iconEmoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: progress == 100 
                          ? const Color(0xFF10B981).withOpacity(0.1)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      progress == 100 ? 'Complete' : '${progress.toInt()}%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: progress == 100 
                            ? const Color(0xFF10B981)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                collection.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                collection.description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: collection.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${collection.visitedCount}/${collection.totalCount} visited',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: collection.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: const Color(0xFFF3F4F6),
                  valueColor: AlwaysStoppedAnimation<Color>(collection.color),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreatePlaceButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          // Main Create Button
          Container(
            width: double.infinity,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showCreateOptions(context),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Color(0xFF10B981),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Create New Place',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Add restaurants, museums, and more',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PlaceTypeSelectionDialog(),
    );
  }
}