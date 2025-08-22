// lib/screens/place_detail_implementations/museum_detail_view.dart

import 'package:flutter/material.dart';
import '../../models/museum.dart';
import '../../models/place_statistic.dart';
import '../place_detail_view_interface.dart';
import '../add_visit_implementations/add_museum_visit_dialog.dart';

class MuseumDetailView extends PlaceDetailViewInterface {
  final Museum museum;

  const MuseumDetailView({
    super.key,
    required this.museum,
  }) : super(place: museum);

  @override
  String get specialTabLabel => 'Ausstellungen';

  @override
  String get specialTabIcon => 'palette';

  @override
  List<PlaceStatistic> getSpecificStats() {
    return [
      PlaceStatistic.number(
        label: 'Aktuelle Ausstellungen',
        value: museum.currentExhibitions.length,
      ),
      PlaceStatistic.number(
        label: 'Sammlungen',
        value: museum.permanentCollections.length,
      ),
      if (museum.ticketPrice.isNotEmpty)
        PlaceStatistic.text(
          label: 'Eintritt',
          value: museum.ticketPrice,
        ),
    ];
  }

  @override
  List<Widget> getOverviewContent(BuildContext context) {
    return [
      _buildMuseumInfoCard(),
      const SizedBox(height: 16),
      _buildCurrentExhibitionsCard(),
      const SizedBox(height: 16),
      _buildFeaturesCard(),
    ];
  }

  @override
  Widget buildSpecialTab(BuildContext context) {
    return _buildExhibitionsTab();
  }

  @override
  Widget? getFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _addMuseumVisit(context),
      backgroundColor: Colors.purple,
      child: const Icon(Icons.museum, color: Colors.white),
    );
  }

  Widget _buildMuseumInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.museum, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'Museum Info',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Kategorie', _getCategoryDisplayName(museum.category)),
            _buildInfoRow('Eintritt', museum.ticketPrice),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (museum.hasAudioGuide)
                  _buildFeatureChip('Audio-Guide'),
                if (museum.hasGiftShop)
                  _buildFeatureChip('Museumsshop'),
                if (museum.isWheelchairAccessible)
                  _buildFeatureChip('Barrierefrei'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentExhibitionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.palette, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'Aktuelle Ausstellungen',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${museum.currentExhibitions.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.purple.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (museum.currentExhibitions.isEmpty)
              const Text(
                'Keine aktuellen Sonderausstellungen',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              ...museum.currentExhibitions.take(3).map((exhibition) => 
                _buildExhibitionTile(exhibition, isTemporary: true)),
            if (museum.currentExhibitions.length > 3)
              TextButton(
                onPressed: () {}, // TODO: Show all exhibitions
                child: Text('Alle ${museum.currentExhibitions.length} Ausstellungen anzeigen'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'Ausstattung & Service',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildFeatureItem(
                    Icons.headphones,
                    'Audio-Guide',
                    museum.hasAudioGuide,
                  ),
                ),
                Expanded(
                  child: _buildFeatureItem(
                    Icons.shopping_bag,
                    'Museumsshop',
                    museum.hasGiftShop,
                  ),
                ),
                Expanded(
                  child: _buildFeatureItem(
                    Icons.accessible,
                    'Barrierefrei',
                    museum.isWheelchairAccessible,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExhibitionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (museum.currentExhibitions.isNotEmpty) ...[
            _buildExhibitionsSection(
              'Aktuelle Sonderausstellungen',
              museum.currentExhibitions,
              isTemporary: true,
            ),
            const SizedBox(height: 24),
          ],
          if (museum.permanentCollections.isNotEmpty) ...[
            _buildExhibitionsSection(
              'Dauerausstellungen',
              museum.permanentCollections,
              isTemporary: false,
            ),
          ],
          if (museum.currentExhibitions.isEmpty && museum.permanentCollections.isEmpty)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.palette, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Keine Ausstellungsinformationen verf�gbar'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExhibitionsSection(String title, List<String> exhibitions, {required bool isTemporary}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isTemporary ? Icons.schedule : Icons.museum,
              color: Colors.purple,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${exhibitions.length}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.purple.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...exhibitions.map((exhibition) => 
          _buildDetailedExhibitionTile(exhibition, isTemporary: isTemporary)),
      ],
    );
  }

  Widget _buildExhibitionTile(String exhibition, {required bool isTemporary}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: isTemporary ? Colors.orange : Colors.purple,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exhibition,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  isTemporary ? 'Sonderausstellung' : 'Dauerausstellung',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedExhibitionTile(String exhibition, {required bool isTemporary}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: (isTemporary ? Colors.orange : Colors.purple).shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isTemporary ? Icons.schedule : Icons.museum,
                color: isTemporary ? Colors.orange : Colors.purple,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exhibition,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isTemporary ? Colors.orange : Colors.purple).shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isTemporary ? 'Sonderausstellung' : 'Dauerausstellung',
                      style: TextStyle(
                        fontSize: 12,
                        color: (isTemporary ? Colors.orange : Colors.purple).shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label, bool isAvailable) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: isAvailable ? Colors.purple : Colors.grey.shade300,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isAvailable ? Colors.black87 : Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isAvailable ? Colors.green : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String feature) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.purple.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        feature,
        style: TextStyle(
          fontSize: 12,
          color: Colors.purple.shade700,
        ),
      ),
    );
  }

  // Helper Methods
  String _getCategoryDisplayName(String category) {
    switch (category.toLowerCase()) {
      case 'art': return 'Kunst';
      case 'history': return 'Geschichte';
      case 'science': return 'Wissenschaft';
      case 'technology': return 'Technik';
      case 'nature': return 'Naturkunde';
      case 'archaeology': return 'Arch�ologie';
      default: return category;
    }
  }

  void _addMuseumVisit(BuildContext context) async {
    final visit = await showDialog(
      context: context,
      builder: (context) => AddMuseumVisitDialog(museum: museum),
    );
    
    // Return the visit to the calling navigator so collection screen can handle it
    if (visit != null && context.mounted) {
      Navigator.of(context).pop(visit);
    }
  }

  @override
  State<MuseumDetailView> createState() => _MuseumDetailViewState();
}

class _MuseumDetailViewState extends State<MuseumDetailView> {
  @override
  Widget build(BuildContext context) {
    return GenericPlaceDetailView(placeView: widget);
  }
}