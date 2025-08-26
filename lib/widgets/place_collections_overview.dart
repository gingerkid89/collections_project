import 'package:flutter/material.dart';
import '../models/collection_base.dart';
import '../models/place.dart';
import '../services/collection_service.dart';
import '../screens/collection_detail_screen.dart';

class PlaceCollectionsOverview extends StatefulWidget {
  final Place place;
  final VoidCallback? onCollectionTapped;

  const PlaceCollectionsOverview({
    super.key,
    required this.place,
    this.onCollectionTapped,
  });

  @override
  State<PlaceCollectionsOverview> createState() => _PlaceCollectionsOverviewState();
}

class _PlaceCollectionsOverviewState extends State<PlaceCollectionsOverview> {
  final CollectionService _collectionService = CollectionService();
  List<CollectionBase>? _collections;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    try {
      final collections = await _collectionService.getCollectionsContainingPlace(widget.place);
      if (mounted) {
        setState(() {
          _collections = collections;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 60,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_error != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          'Error loading collections: $_error',
          style: TextStyle(
            color: Colors.red.shade600,
            fontSize: 12,
          ),
        ),
      );
    }

    if (_collections == null || _collections!.isEmpty) {
      return const SizedBox.shrink(); // Hide if no collections
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.collections_bookmark,
                size: 18,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                _collections!.length == 1 ? 'Part of collection:' : 'Part of collections:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Collections List
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _collections!.map((collection) => _buildCollectionChip(collection)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionChip(CollectionBase collection) {
    return InkWell(
      onTap: () => _navigateToCollection(collection),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Collection Icon
            Text(
              collection.iconEmoji,
              style: const TextStyle(fontSize: 16),
            ),
            
            const SizedBox(width: 6),
            
            // Collection Name
            Flexible(
              child: Text(
                collection.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Progress indicator (small)
            const SizedBox(width: 6),
            Text(
              '${collection.visitedCount}/${collection.totalCount}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
            
            // Arrow icon
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCollection(CollectionBase collection) {
    widget.onCollectionTapped?.call();
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CollectionDetailScreen(
          collection: collection,
        ),
      ),
    );
  }
}

// Alternative compact version for smaller spaces
class CompactPlaceCollectionsOverview extends StatelessWidget {
  final Place place;
  final VoidCallback? onCollectionTapped;

  const CompactPlaceCollectionsOverview({
    super.key,
    required this.place,
    this.onCollectionTapped,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CollectionBase>>(
      future: CollectionService().getCollectionsContainingPlace(place),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final collections = snapshot.data!;
        
        return Wrap(
          spacing: 4,
          children: collections.map((collection) => 
            InkWell(
              onTap: () {
                onCollectionTapped?.call();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CollectionDetailScreen(collection: collection),
                  ),
                );
              },
              child: Chip(
                avatar: Text(collection.iconEmoji, style: const TextStyle(fontSize: 12)),
                label: Text(
                  collection.name,
                  style: const TextStyle(fontSize: 11),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ).toList(),
        );
      },
    );
  }
}