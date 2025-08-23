// lib/screens/recent_visits_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/visits_provider.dart';
import '../models/visit.dart';

class RecentVisitsScreen extends StatelessWidget {
  const RecentVisitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: Text(l10n.recentVisits),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF111827),
          elevation: 0,
          bottom: TabBar(
            labelColor: const Color(0xFF3B82F6),
            unselectedLabelColor: const Color(0xFF6B7280),
            indicatorColor: const Color(0xFF3B82F6),
            tabs: [
              Tab(text: l10n.myVisits),
              Tab(text: l10n.publicVisits),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PersonalVisitsTab(),
            PublicVisitsTab(),
          ],
        ),
      ),
    );
  }
}

class PersonalVisitsTab extends StatelessWidget {
  const PersonalVisitsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Consumer<VisitsProvider>(
      builder: (context, visitsProvider, child) {
        final visits = visitsProvider.visits;
        
        if (visits.isEmpty) {
          return _buildEmptyState(
            icon: Icons.explore_off,
            title: l10n.noVisitsYet,
            subtitle: l10n.startExploring,
          );
        }

        // Sort visits by date (newest first)
        final sortedVisits = List<Visit>.from(visits)
          ..sort((a, b) => b.date.compareTo(a.date));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedVisits.length,
          itemBuilder: (context, index) {
            final visit = sortedVisits[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PersonalVisitCard(visit: visit),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
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
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class PublicVisitsTab extends StatelessWidget {
  const PublicVisitsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // TODO: Replace with actual API call to fetch public visits
    return _buildEmptyState(
      icon: Icons.public_off,
      title: l10n.noPublicVisits,
      subtitle: l10n.comingSoon,
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
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
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: const Color(0xFF0284C7),
                ),
                const SizedBox(width: 8),
                Text(
                  'API Integration Placeholder',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF0284C7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalVisitCard extends StatelessWidget {
  final Visit visit;

  const _PersonalVisitCard({required this.visit});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visit.metadata['placeName']?.toString() ?? 'Visit #${visit.placeId}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(visit.date),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    if (visit.isPublic)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.public,
                              size: 12,
                              color: const Color(0xFF16A34A),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Public',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF16A34A),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (!visit.isPublic)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock,
                              size: 12,
                              color: const Color(0xFF6B7280),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Private',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (visit.overallRating != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: const Color(0xFFFB923C),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${visit.overallRating!.toStringAsFixed(1)}/5',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            if (visit.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Text(
                visit.notes!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4B5563),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (visit.photoUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: visit.photoUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 60,
                          height: 60,
                          color: const Color(0xFFF3F4F6),
                          child: Icon(
                            Icons.image,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final visitDate = DateTime(date.year, date.month, date.day);

    if (visitDate == today) {
      return 'Today, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (visitDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }
}