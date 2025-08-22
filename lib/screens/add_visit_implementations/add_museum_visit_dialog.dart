// lib/screens/add_visit_implementations/add_museum_visit_dialog.dart

import 'package:flutter/material.dart';
import '../../models/museum.dart';
import '../../models/visit.dart';
import '../../models/visit_activity.dart';

class AddMuseumVisitDialog extends StatefulWidget {
  final Museum museum;

  const AddMuseumVisitDialog({
    super.key,
    required this.museum,
  });

  @override
  State<AddMuseumVisitDialog> createState() => _AddMuseumVisitDialogState();
}

class _AddMuseumVisitDialogState extends State<AddMuseumVisitDialog> {
  // Basic visit data
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  final TextEditingController notesController = TextEditingController();
  double overallRating = 0.0;

  // Museum-specific data
  List<String> visitedExhibitions = [];
  bool hadAudioGuide = false;
  bool visitedGiftShop = false;
  Duration? visitDuration;

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

  // Getters
  DateTime get visitDateTime => DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    selectedTime.hour,
    selectedTime.minute,
  );

  bool get canSave => overallRating > 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Besuch: ${widget.museum.name}'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: canSave ? _saveVisit : null,
            child: const Text(
              'Speichern',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildBasicVisitSection(),
            _buildExhibitionsSection(),
            _buildMuseumSpecificSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicVisitSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Besuchsinformationen',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Date and Time Row
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Datum'),
                    subtitle: Text('${selectedDate.day}.${selectedDate.month}.${selectedDate.year}'),
                    onTap: _selectDate,
                  ),
                ),
                Expanded(
                  child: ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Uhrzeit'),
                    subtitle: Text('${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}'),
                    onTap: _selectTime,
                  ),
                ),
              ],
            ),
            
            // Duration
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Besuchsdauer'),
              subtitle: Text(visitDuration != null ? 
                '${visitDuration!.inHours}h ${visitDuration!.inMinutes % 60}min' : 
                'Nicht angegeben'),
              onTap: _selectDuration,
            ),
            
            // Rating
            const SizedBox(height: 16),
            const Text('Gesamtbewertung *', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () => setState(() => overallRating = index + 1.0),
                  icon: Icon(
                    index < overallRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                );
              }),
            ),
            
            // Notes
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notizen (optional)',
                hintText: 'Wie war dein Museumsbesuch?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExhibitionsSection() {
    final allExhibitions = [
      ...widget.museum.currentExhibitions,
      ...widget.museum.permanentCollections,
    ];

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.palette, color: Colors.purple),
                SizedBox(width: 8),
                Text('Besuchte Ausstellungen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            
            if (allExhibitions.isEmpty)
              const Text(
                'Keine Ausstellungsinformationen verfügbar',
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              )
            else
              Column(
                children: allExhibitions.map((exhibition) {
                  final isSelected = visitedExhibitions.contains(exhibition);
                  final isTemporary = widget.museum.currentExhibitions.contains(exhibition);
                  
                  return CheckboxListTile(
                    title: Text(exhibition),
                    subtitle: Text(isTemporary ? 'Sonderausstellung' : 'Dauerausstellung'),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          visitedExhibitions.add(exhibition);
                        } else {
                          visitedExhibitions.remove(exhibition);
                        }
                      });
                    },
                    secondary: Icon(
                      isTemporary ? Icons.schedule : Icons.museum,
                      color: isTemporary ? Colors.orange : Colors.purple,
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuseumSpecificSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.purple),
                SizedBox(width: 8),
                Text('Zusätzliche Informationen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            
            if (widget.museum.hasAudioGuide)
              CheckboxListTile(
                title: const Text('Audio-Guide verwendet'),
                value: hadAudioGuide,
                onChanged: (value) => setState(() => hadAudioGuide = value ?? false),
                secondary: const Icon(Icons.headphones, color: Colors.purple),
              ),
            
            if (widget.museum.hasGiftShop)
              CheckboxListTile(
                title: const Text('Museumsshop besucht'),
                value: visitedGiftShop,
                onChanged: (value) => setState(() => visitedGiftShop = value ?? false),
                secondary: const Icon(Icons.shopping_bag, color: Colors.purple),
              ),
          ],
        ),
      ),
    );
  }

  // Event handlers
  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  void _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (time != null) {
      setState(() => selectedTime = time);
    }
  }

  void _selectDuration() async {
    int hours = visitDuration?.inHours ?? 2;
    int minutes = visitDuration?.inMinutes.remainder(60) ?? 0;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Besuchsdauer'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('Stunden: '),
                  Expanded(
                    child: Slider(
                      value: hours.toDouble(),
                      min: 0,
                      max: 12,
                      divisions: 12,
                      label: '$hours h',
                      onChanged: (value) => setDialogState(() => hours = value.toInt()),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('Minuten: '),
                  Expanded(
                    child: Slider(
                      value: minutes.toDouble(),
                      min: 0,
                      max: 59,
                      divisions: 11,
                      label: '$minutes min',
                      onChanged: (value) => setDialogState(() => minutes = value.toInt()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                visitDuration = Duration(hours: hours, minutes: minutes);
              });
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _saveVisit() {
    try {
      final visit = _createVisit();
      Navigator.of(context).pop(visit);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Museumsbesuch erfolgreich gespeichert!'),
          backgroundColor: Colors.purple,
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

  Visit _createVisit() {
    final exhibitionActivities = visitedExhibitions.map((exhibition) {
      final isTemporary = widget.museum.currentExhibitions.contains(exhibition);
      return MuseumExhibition(
        id: 'exhibition_${exhibition.hashCode}',
        name: exhibition,
        exhibitionType: isTemporary ? 'temporary' : 'permanent',
        notes: isTemporary ? 'Sonderausstellung' : 'Dauerausstellung',
      );
    }).toList();

    return Visit.create(
      date: visitDateTime,
      placeId: widget.museum.id,
      placeType: 'museum',
      overallRating: overallRating,
      notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
      duration: visitDuration,
      activities: exhibitionActivities,
      metadata: {
        'museum_name': widget.museum.name,
        'had_audio_guide': hadAudioGuide,
        'visited_gift_shop': visitedGiftShop,
        'exhibition_count': visitedExhibitions.length,
        'museum_category': widget.museum.category,
      },
    );
  }
}