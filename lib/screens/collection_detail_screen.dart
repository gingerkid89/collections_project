// lib/screens/collection_detail_screen.dart
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/collection_base.dart';
import '../models/location.dart';


class CollectionDetailScreen extends StatefulWidget {
  final CollectionBase collection;

  const CollectionDetailScreen({
    super.key,
    required this.collection,
  });

  @override
  State<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends State<CollectionDetailScreen> {
  String searchTerm = '';
  String filterMode = 'all';

  List<Location> get filteredLocations {
    var locations = widget.collection.locations.where((location) {
      final matchesSearch = location.name.toLowerCase().contains(searchTerm.toLowerCase()) ||
          location.address.toLowerCase().contains(searchTerm.toLowerCase());

      switch (filterMode) {
        case 'visited':
          return location.isVisited && matchesSearch;
        case 'unvisited':
          return !location.isVisited && matchesSearch;
        default:
          return matchesSearch;
      }
    }).toList();

    return locations;
  }

  Color get brandColor {
    switch (widget.collection.iconEmoji) {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final visitedCount = widget.collection.visitedCount;
    final totalCount = widget.collection.totalCount;
    final progressPercentage = widget.collection.progressPercentage;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Back Button und Info
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.collection.iconEmoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.collection.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              l10n.visitedCount(visitedCount, totalCount),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Progress Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.collectingProgress),
                      Text('${progressPercentage.toStringAsFixed(1)}%'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progressPercentage / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation(brandColor),
                  ),
                  const SizedBox(height: 16),

                  // Search
                  TextField(
                    onChanged: (value) => setState(() => searchTerm = value),
                    decoration: InputDecoration(
                      hintText: l10n.searchLocations,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filter Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => setState(() => filterMode = 'all'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: filterMode == 'all' ? brandColor : Colors.grey[300],
                            foregroundColor: filterMode == 'all' ? Colors.white : Colors.black,
                          ),
                          child: Text(l10n.allCount(totalCount)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => setState(() => filterMode = 'visited'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: filterMode == 'visited' ? Colors.green : Colors.grey[300],
                            foregroundColor: filterMode == 'visited' ? Colors.white : Colors.black,
                          ),
                          child: Text(l10n.collectedCount(visitedCount)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => setState(() => filterMode = 'unvisited'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: filterMode == 'unvisited' ? Colors.grey : Colors.grey[300],
                            foregroundColor: filterMode == 'unvisited' ? Colors.white : Colors.black,
                          ),
                          child: Text(l10n.openCount(totalCount - visitedCount)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Grid
            Expanded(
              child: filteredLocations.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noLocationsFound,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.tryDifferentSearch,
                      style: const TextStyle(color: Color(0xFF6B7280)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
                  : Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filteredLocations.length,
                  itemBuilder: (context, index) {
                    final location = filteredLocations[index];
                    return LocationTile(
                      location: location,
                      onTap: () {
                        print('Tapped ${location.name}');
                      },
                      onMarkVisited: () {
                        setState(() {
                          if (location.isVisited) {
                            location.markAsNotVisited();
                          } else {
                            location.markAsVisited(rating: 5);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LocationTile extends StatelessWidget {
  final Location location;
  final VoidCallback onTap;
  final VoidCallback onMarkVisited;

  const LocationTile({
    super.key,
    required this.location,
    required this.onTap,
    required this.onMarkVisited,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Foto oder Placeholder
              location.imageUrls.isNotEmpty
                  ? ColorFiltered(
                colorFilter: location.isVisited
                    ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                    : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                child: Image.network(
                  location.imageUrls.first,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.restaurant, size: 32),
                    );
                  },
                ),
              )
                  : Container(
                color: Colors.grey[300],
                child: const Icon(Icons.restaurant, size: 32),
              ),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),

              // Besucht Badge
              if (location.isVisited)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.green,
                    child: Icon(Icons.check, color: Colors.white, size: 16),
                  ),
                ),

              // Text unten
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      location.name.split(' ').last, // Nur letzter Teil des Namens
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      location.shortAddress,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (location.isVisited)
                      Text(
                        l10n.visitedToday,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),

              // Tap-to-mark overlay für nicht besuchte
              if (!location.isVisited)
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onMarkVisited,
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                        child: Center(
                          child: Text(
                            l10n.markAsVisited,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}