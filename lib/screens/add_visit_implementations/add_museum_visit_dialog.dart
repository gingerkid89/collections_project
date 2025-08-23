// lib/screens/add_visit_implementations/add_museum_visit_dialog.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../models/museum.dart';
import '../../models/visit.dart';
import '../../models/visit_activity.dart';
import '../../l10n/app_localizations.dart';

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

  // Photo and privacy data
  List<String> photoUrls = [];
  final ImagePicker _picker = ImagePicker();
  bool isPublic = true;

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
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.visitDetails(widget.museum.name)),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: canSave ? _saveVisit : null,
            child: Text(
              l10n.save,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
            _buildPhotoSection(),
            _buildPrivacySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicVisitSection() {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.visitInformation,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Date and Time Row
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(l10n.date),
                    subtitle: Text('${selectedDate.day}.${selectedDate.month}.${selectedDate.year}'),
                    onTap: _selectDate,
                  ),
                ),
                Expanded(
                  child: ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(l10n.time),
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
              title: Text(l10n.visitDuration),
              subtitle: Text(visitDuration != null ? 
                '${visitDuration!.inHours}h ${visitDuration!.inMinutes % 60}min' : 
                l10n.notSpecified),
              onTap: _selectDuration,
            ),
            
            // Rating
            const SizedBox(height: 16),
            Text('${l10n.overallRating} *', style: const TextStyle(fontWeight: FontWeight.w500)),
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
              decoration: InputDecoration(
                labelText: l10n.notes,
                hintText: l10n.museumVisitNotes,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExhibitionsSection() {
    final l10n = AppLocalizations.of(context)!;
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
            Row(
              children: [
                const Icon(Icons.palette, color: Colors.purple),
                const SizedBox(width: 8),
                Text(l10n.visitedExhibitions, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            
            if (allExhibitions.isEmpty)
              Text(
                l10n.noExhibitionsAvailable,
                style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              )
            else
              Column(
                children: allExhibitions.map((exhibition) {
                  final isSelected = visitedExhibitions.contains(exhibition);
                  final isTemporary = widget.museum.currentExhibitions.contains(exhibition);
                  
                  return CheckboxListTile(
                    title: Text(exhibition),
                    subtitle: Text(isTemporary ? l10n.temporaryExhibition : l10n.permanentExhibition),
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
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.purple),
                const SizedBox(width: 8),
                Text(l10n.additionalInformation, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            
            if (widget.museum.hasAudioGuide)
              CheckboxListTile(
                title: Text(l10n.audioGuideUsed),
                value: hadAudioGuide,
                onChanged: (value) => setState(() => hadAudioGuide = value ?? false),
                secondary: const Icon(Icons.headphones, color: Colors.purple),
              ),
            
            if (widget.museum.hasGiftShop)
              CheckboxListTile(
                title: Text(l10n.giftShopVisited),
                value: visitedGiftShop,
                onChanged: (value) => setState(() => visitedGiftShop = value ?? false),
                secondary: const Icon(Icons.shopping_bag, color: Colors.purple),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.photo_camera, color: Colors.purple),
                const SizedBox(width: 8),
                Text(l10n.photos, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            
            // Photo grid
            if (photoUrls.isNotEmpty) ...[
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: photoUrls.length,
                  itemBuilder: (context, index) {
                    return _buildPhotoTile(photoUrls[index], index);
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Add photo button
            OutlinedButton.icon(
              onPressed: _showPhotoOptions,
              icon: const Icon(Icons.add_photo_alternate),
              label: Text(l10n.addPhoto),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.purple,
                side: const BorderSide(color: Colors.purple),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection() {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.privacy_tip, color: Colors.purple),
                const SizedBox(width: 8),
                Text(l10n.privacy, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            
            Text(
              l10n.privacyDescription,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            
            // Privacy options
            RadioListTile<bool>(
              title: Text(l10n.publicData),
              subtitle: Text(l10n.publicDataDescription),
              value: true,
              groupValue: isPublic,
              onChanged: (value) => setState(() => isPublic = value!),
              activeColor: Colors.purple,
            ),
            RadioListTile<bool>(
              title: Text(l10n.privateData),
              subtitle: Text(l10n.privateDataDescription),
              value: false,
              groupValue: isPublic,
              onChanged: (value) => setState(() => isPublic = value!),
              activeColor: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoTile(String photoPath, int index) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(photoPath),
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.error, color: Colors.red),
                );
              },
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removePhoto(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
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
    final l10n = AppLocalizations.of(context)!;
    int hours = visitDuration?.inHours ?? 2;
    int minutes = visitDuration?.inMinutes.remainder(60) ?? 0;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.visitDuration),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text('${l10n.hours}: '),
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
                  Text('${l10n.minutes}: '),
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
            child: Text(l10n.cancel),
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

  void _showPhotoOptions() {
    final l10n = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(l10n.takePhoto),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(l10n.chooseFromGallery),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );
      
      if (image != null) {
        final String savedPath = await _saveImageToLocal(image.path);
        setState(() {
          photoUrls.add(savedPath);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.photoAdded),
              backgroundColor: Colors.purple,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorLoadingPhoto),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String> _saveImageToLocal(String imagePath) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String fileName = 'visit_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String localPath = path.join(appDir.path, 'visit_photos', fileName);
    
    // Create directory if it doesn't exist
    final Directory dir = Directory(path.dirname(localPath));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    // Copy file to local storage
    final File sourceFile = File(imagePath);
    final File targetFile = await sourceFile.copy(localPath);
    
    return targetFile.path;
  }

  void _removePhoto(int index) {
    setState(() {
      photoUrls.removeAt(index);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.photoRemoved),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _saveVisit() {
    final l10n = AppLocalizations.of(context)!;
    
    try {
      final visit = _createVisit();
      Navigator.of(context).pop(visit);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.museumVisitSaved),
          backgroundColor: Colors.purple,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorSaving(e.toString())),
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
      photoUrls: photoUrls,
      isPublic: isPublic,
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