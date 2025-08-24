// lib/screens/visit_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/visit.dart';
import '../providers/visits_provider.dart';
import '../providers/user_provider.dart';

class VisitDetailScreen extends StatefulWidget {
  final Visit visit;
  final String placeName;

  const VisitDetailScreen({
    super.key,
    required this.visit,
    required this.placeName,
  });

  @override
  State<VisitDetailScreen> createState() => _VisitDetailScreenState();
}

class _VisitDetailScreenState extends State<VisitDetailScreen> {
  late PageController _photoController;
  int _currentPhotoIndex = 0;

  bool get showEditButtons {
    final userProvider = context.read<UserProvider>();
    final currentUserId = userProvider.currentUserId ?? '';
    return widget.visit.userId == currentUserId;
  }

  @override
  void initState() {
    super.initState();
    _photoController = PageController();
  }

  @override
  void dispose() {
    _photoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(l10n.visitDetails),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        actions: [
          if (showEditButtons)
            IconButton(
              onPressed: () => _showEditOptions(context),
              icon: const Icon(Icons.more_vert),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo Gallery Section
            _buildPhotoGallery(l10n),
            
            // Visit Information
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with rating and privacy
                  _buildVisitHeader(l10n),
                  
                  const SizedBox(height: 24),
                  
                  // Place and date info
                  _buildPlaceInfo(l10n),
                  
                  if (widget.visit.notes?.isNotEmpty == true) ...[
                    const SizedBox(height: 24),
                    _buildNotesSection(l10n),
                  ],
                  
                  if (widget.visit.activities.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildActivitiesSection(l10n),
                  ],
                  
                  const SizedBox(height: 24),
                  _buildVisitStats(l10n),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            _buildActionButtons(l10n),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGallery(AppLocalizations l10n) {
    if (widget.visit.photoUrls.isEmpty) {
      return Container(
        height: 240,
        color: const Color(0xFFF3F4F6),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 48,
                color: const Color(0xFF9CA3AF),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.noPhotos,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 300,
      child: Stack(
        children: [
          PageView.builder(
            controller: _photoController,
            onPageChanged: (index) {
              setState(() {
                _currentPhotoIndex = index;
              });
            },
            itemCount: widget.visit.photoUrls.length,
            itemBuilder: (context, index) {
              return Container(
                color: const Color(0xFF111827),
                child: Center(
                  child: Container(
                    width: double.infinity,
                    height: 300,
                    color: const Color(0xFFF3F4F6),
                    child: Icon(
                      Icons.image,
                      size: 80,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Photo counter
          if (widget.visit.photoUrls.length > 1)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_currentPhotoIndex + 1}/${widget.visit.photoUrls.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          
          // Navigation dots
          if (widget.visit.photoUrls.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.visit.photoUrls.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == _currentPhotoIndex
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVisitHeader(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rating
        if (widget.visit.overallRating != null)
          Row(
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  index < widget.visit.overallRating! ? Icons.star : Icons.star_border,
                  size: 24,
                  color: const Color(0xFFFB923C),
                );
              }),
              const SizedBox(width: 8),
              Text(
                '${widget.visit.overallRating!.toStringAsFixed(1)}/5',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        
        // Privacy badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: widget.visit.isPublic
                ? const Color(0xFFDCFCE7)
                : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.visit.isPublic ? Icons.public : Icons.lock,
                size: 16,
                color: widget.visit.isPublic
                    ? const Color(0xFF16A34A)
                    : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 6),
              Text(
                widget.visit.isPublic ? 'Public' : 'Private',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: widget.visit.isPublic
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceInfo(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.placeName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.schedule,
              size: 16,
              color: const Color(0xFF6B7280),
            ),
            const SizedBox(width: 6),
            Text(
              _formatDateTime(widget.visit.date),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotesSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.notes,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Text(
            widget.visit.notes!,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF374151),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivitiesSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.activities,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.visit.activities.map((activity) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF8FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
              ),
              child: Text(
                activity.name,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1D4ED8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildVisitStats(AppLocalizations l10n) {
    final stats = <Widget>[];

    // Duration removed as requested

    if (widget.visit.totalCost != null) {
      stats.add(_buildStatItem(
        Icons.euro,
        l10n.cost,
        widget.visit.formattedCost,
      ));
    }

    if (stats.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Visit Information',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: stats
              .expand((stat) => [stat, const SizedBox(width: 24)])
              .take(stats.length * 2 - 1)
              .toList(),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6B7280)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _shareVisit(),
              icon: const Icon(Icons.share),
              label: Text(l10n.shareVisit),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF3B82F6),
                side: const BorderSide(color: Color(0xFF3B82F6)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          if (showEditButtons) ...[
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _editVisit(),
                icon: const Icon(Icons.edit),
                label: Text(l10n.editVisit),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showEditOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showEditButtons) ...[
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(l10n.editVisit),
                onTap: () {
                  Navigator.pop(context);
                  _editVisit();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(l10n.deleteVisit, style: const TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation();
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.share),
              title: Text(l10n.shareVisit),
              onTap: () {
                Navigator.pop(context);
                _shareVisit();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _deleteVisit();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _deleteVisit() async {
    final visitsProvider = Provider.of<VisitsProvider>(context, listen: false);
    await visitsProvider.deleteVisit(widget.visit.id);
    Navigator.pop(context); // Go back to previous screen
  }

  void _editVisit() {
    // TODO: Navigate to edit visit screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality coming soon')),
    );
  }

  void _shareVisit() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
    );
  }

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final visitDate = DateTime(date.year, date.month, date.day);

    if (visitDate == today) {
      return 'Today, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (visitDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}.${date.month}.${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
}