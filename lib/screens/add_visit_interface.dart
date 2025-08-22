// lib/screens/dialogs/add_visit_interface.dart

import 'package:flutter/material.dart';
import '../models/place.dart';
import '../models/visit.dart';

// ================================
// ADD VISIT INTERFACE
// ================================

abstract class AddVisitInterface extends StatefulWidget {
  final Place place;

  const AddVisitInterface({
    super.key,
    required this.place,
  });

  // Context-spezifische Methoden (müssen implementiert werden)
  Widget buildContextSpecificSection(BuildContext context);
  Visit createVisitFromState();
  String get validationError;
}

// ================================
// MIXIN FÜR GEMEINSAME FUNKTIONALITÄT
// ================================

mixin AddVisitMixin<T extends AddVisitInterface> on State<T> {
  // Gemeinsame Form-Daten
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  Duration? selectedDuration;
  final TextEditingController notesController = TextEditingController();
  double overallRating = 0.0;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    selectedTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  // Gemeinsame Getter
  DateTime get visitDateTime => DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    selectedTime.hour,
    selectedTime.minute,
  );

  String get visitNotes => notesController.text.trim();
  double get visitRating => overallRating;
  Duration? get visitDuration => selectedDuration;

  bool get canSave => overallRating > 0 && widget.validationError.isEmpty;

  // Gemeinsame UI Builder
  Widget buildGenericSections() {
    return Column(
      children: [
        _buildPlaceHeader(),
        _buildDateTimeSection(),
        _buildDurationSection(),
        widget.buildContextSpecificSection(context),
        _buildNotesSection(),
        _buildOverallRatingSection(),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildPlaceHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
        ),
      ),
      child: Column(
        children: [
          Text(widget.place.emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text(
            widget.place.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '${selectedDate.day}.${selectedDate.month}.${selectedDate.year}',
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return buildSection(
      title: 'Datum & Zeit',
      icon: Icons.calendar_today,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: buildFormField(
                  label: 'Datum',
                  child: InkWell(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${selectedDate.day}.${selectedDate.month}.${selectedDate.year}'),
                          const Icon(Icons.calendar_today, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildFormField(
                  label: 'Uhrzeit',
                  child: InkWell(
                    onTap: _selectTime,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'),
                          const Icon(Icons.access_time, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSection() {
    return buildSection(
      title: 'Aufenthaltsdauer',
      icon: Icons.timer,
      child: buildFormField(
        label: 'Dauer (optional)',
        child: TextField(
          decoration: const InputDecoration(
            hintText: 'z.B. 2h 30min',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              selectedDuration = _parseDuration(value);
            });
          },
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return buildSection(
      title: 'Notizen',
      icon: Icons.note,
      child: buildFormField(
        label: 'Ihre Erfahrungen',
        child: TextField(
          controller: notesController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Wie war Ihr Besuch? Besondere Erlebnisse?',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }

  Widget _buildOverallRatingSection() {
    return buildSection(
      title: 'Gesamtbewertung',
      icon: Icons.star,
      child: Column(
        children: [
          const Text(
            'Wie war Ihr Besuch insgesamt?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => setState(() => overallRating = index + 1.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.star,
                    size: 40,
                    color: index < overallRating ? Colors.amber : Colors.grey.shade300,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            _getRatingText(overallRating),
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Abbrechen'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: canSave ? _saveVisit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Speichern'),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widgets (für Subclasses verfügbar)
  Widget buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget buildFormField({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  // Helper Methods
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() => selectedTime = picked);
    }
  }

  Duration? _parseDuration(String input) {
    if (input.isEmpty) return null;

    try {
      final RegExp regex = RegExp(r'(\d+)h\s*(\d+)min|(\d+)h|(\d+)min');
      final match = regex.firstMatch(input.toLowerCase());

      if (match != null) {
        int hours = 0;
        int minutes = 0;

        if (match.group(1) != null) hours = int.parse(match.group(1)!);
        if (match.group(2) != null) minutes = int.parse(match.group(2)!);
        if (match.group(3) != null) hours = int.parse(match.group(3)!);
        if (match.group(4) != null) minutes = int.parse(match.group(4)!);

        return Duration(hours: hours, minutes: minutes);
      }
    } catch (e) {
      // Invalid input, return null
    }

    return null;
  }

  String _getRatingText(double rating) {
    switch (rating.toInt()) {
      case 1: return 'Schlecht';
      case 2: return 'Okay';
      case 3: return 'Gut';
      case 4: return 'Sehr gut';
      case 5: return 'Ausgezeichnet';
      default: return 'Bewertung auswählen';
    }
  }

  void _saveVisit() {
    try {
      final visit = widget.createVisitFromState();
      Navigator.of(context).pop(visit);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Besuch erfolgreich gespeichert!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Speichern: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}