// lib/screens/edit_visit_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import '../models/visit.dart';
import '../models/visit_activity.dart';
import '../providers/visits_provider.dart';
import '../providers/user_provider.dart';

class EditVisitScreen extends StatefulWidget {
  final Visit visit;
  final String placeName;

  const EditVisitScreen({
    super.key,
    required this.visit,
    required this.placeName,
  });

  @override
  State<EditVisitScreen> createState() => _EditVisitScreenState();
}

class _EditVisitScreenState extends State<EditVisitScreen> {
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  final TextEditingController notesController = TextEditingController();
  late double overallRating;
  late List<String> photoUrls;
  late bool isPublic;
  late List<VisitActivity> activities;
  late double? totalCost;
  
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFromVisit();
  }

  void _initializeFromVisit() {
    selectedDate = DateTime(
      widget.visit.date.year,
      widget.visit.date.month,
      widget.visit.date.day,
    );
    selectedTime = TimeOfDay(
      hour: widget.visit.date.hour,
      minute: widget.visit.date.minute,
    );
    notesController.text = widget.visit.notes ?? '';
    overallRating = widget.visit.overallRating ?? 0.0;
    photoUrls = List.from(widget.visit.photoUrls);
    isPublic = widget.visit.isPublic;
    activities = List.from(widget.visit.activities);
    totalCost = widget.visit.totalCost;
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  bool get hasChanges {
    final originalDateTime = widget.visit.date;
    final currentDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    return originalDateTime != currentDateTime ||
           (widget.visit.notes ?? '') != notesController.text.trim() ||
           (widget.visit.overallRating ?? 0.0) != overallRating ||
           widget.visit.photoUrls.length != photoUrls.length ||
           !_listEquals(widget.visit.photoUrls, photoUrls) ||
           widget.visit.isPublic != isPublic ||
           widget.visit.totalCost != totalCost;
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(l10n.editVisit),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _handleBackPress(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveChanges,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    l10n.save,
                    style: TextStyle(
                      color: hasChanges ? const Color(0xFF3B82F6) : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPlaceHeader(),
            _buildEditableSections(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceHeader() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            '📍',
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 8),
          Text(
            widget.placeName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '${selectedDate.day}.${selectedDate.month}.${selectedDate.year}',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableSections(AppLocalizations l10n) {
    return Column(
      children: [
        const SizedBox(height: 8),
        _buildDateTimeSection(l10n),
        _buildRatingSection(l10n),
        _buildNotesSection(l10n),
        _buildPhotosSection(l10n),
        _buildPrivacySection(l10n),
        if (widget.visit.totalCost != null) _buildCostSection(l10n),
        if (widget.visit.activities.isNotEmpty) _buildActivitiesSection(l10n),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF6B7280)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDateTimeSection(AppLocalizations l10n) {
    return _buildSection(
      title: 'Date & Time',
      icon: Icons.calendar_today,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${selectedDate.day}.${selectedDate.month}.${selectedDate.year}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today, size: 20, color: Color(0xFF6B7280)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: InkWell(
              onTap: _selectTime,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.access_time, size: 20, color: Color(0xFF6B7280)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(AppLocalizations l10n) {
    return _buildSection(
      title: l10n.overallRating,
      icon: Icons.star,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => setState(() => overallRating = index + 1.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.star,
                    size: 32,
                    color: index < overallRating 
                        ? const Color(0xFFFB923C)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            _getRatingText(overallRating),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(AppLocalizations l10n) {
    return _buildSection(
      title: l10n.notes,
      icon: Icons.note,
      child: TextField(
        controller: notesController,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'Share your experience...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF3B82F6)),
          ),
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _buildPhotosSection(AppLocalizations l10n) {
    return _buildSection(
      title: l10n.photos,
      icon: Icons.photo_camera,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          OutlinedButton.icon(
            onPressed: kIsWeb ? null : _showPhotoOptions,
            icon: const Icon(Icons.add_photo_alternate),
            label: Text(l10n.addPhoto),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF3B82F6),
              side: const BorderSide(color: Color(0xFF3B82F6)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection(AppLocalizations l10n) {
    return _buildSection(
      title: l10n.privacy,
      icon: Icons.privacy_tip,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.privacyDescription,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Radio<bool>(
              value: true,
              groupValue: isPublic,
              onChanged: (value) => setState(() => isPublic = value!),
              activeColor: const Color(0xFF3B82F6),
            ),
            title: Text(l10n.publicData),
            subtitle: Text(l10n.publicDataDescription),
            onTap: () => setState(() => isPublic = true),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Radio<bool>(
              value: false,
              groupValue: isPublic,
              onChanged: (value) => setState(() => isPublic = value!),
              activeColor: const Color(0xFF3B82F6),
            ),
            title: Text(l10n.privateData),
            subtitle: Text(l10n.privateDataDescription),
            onTap: () => setState(() => isPublic = false),
          ),
        ],
      ),
    );
  }

  Widget _buildCostSection(AppLocalizations l10n) {
    return _buildSection(
      title: l10n.cost,
      icon: Icons.euro,
      child: TextField(
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          hintText: '0.00',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF3B82F6)),
          ),
          prefixText: '€ ',
        ),
        controller: TextEditingController(
          text: totalCost?.toStringAsFixed(2) ?? '',
        ),
        onChanged: (value) {
          setState(() {
            totalCost = double.tryParse(value);
          });
        },
      ),
    );
  }

  Widget _buildActivitiesSection(AppLocalizations l10n) {
    return _buildSection(
      title: l10n.activities,
      icon: Icons.local_activity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activities from your visit:',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: activities.map((activity) {
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
            child: kIsWeb
                ? Container(
                    width: 100,
                    height: 100,
                    color: const Color(0xFFF3F4F6),
                    child: const Icon(
                      Icons.photo,
                      size: 32,
                      color: Color(0xFF9CA3AF),
                    ),
                  )
                : _buildPhotoWidget(photoPath),
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

  Widget _buildPhotoWidget(String photoPath) {
    if (!kIsWeb) {
      try {
        return Image.asset(
          photoPath,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 100,
              height: 100,
              color: const Color(0xFFF3F4F6),
              child: const Icon(Icons.broken_image, color: Colors.red),
            );
          },
        );
      } catch (e) {
        // Fall through to placeholder
      }
    }
    return Container(
      width: 100,
      height: 100,
      color: const Color(0xFFF3F4F6),
      child: const Icon(
        Icons.photo,
        size: 32,
        color: Color(0xFF9CA3AF),
      ),
    );
  }

  String _getRatingText(double rating) {
    switch (rating.toInt()) {
      case 1: return 'Poor';
      case 2: return 'Fair';
      case 3: return 'Good';
      case 4: return 'Very Good';
      case 5: return 'Excellent';
      default: return 'Tap to rate';
    }
  }

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
              backgroundColor: Colors.green,
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
    // On web, just return the path as-is for now
    // In production, this would handle proper file uploads
    return imagePath;
  }

  void _removePhoto(int index) {
    setState(() {
      photoUrls.removeAt(index);
    });
  }

  void _handleBackPress() {
    if (hasChanges) {
      _showUnsavedChangesDialog();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _showUnsavedChangesDialog() {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unsaved Changes'),
        content: Text('You have unsaved changes. Are you sure you want to leave?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close edit screen
            },
            child: const Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (!hasChanges) return;

    setState(() => _isLoading = true);

    try {
      final updatedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      final updatedVisit = widget.visit.copyWith(
        date: updatedDateTime,
        notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
        overallRating: overallRating == 0.0 ? null : overallRating,
        photoUrls: photoUrls,
        isPublic: isPublic,
        totalCost: totalCost,
      );

      final visitsProvider = Provider.of<VisitsProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      final success = await visitsProvider.updateVisitWithPermissionCheck(
        updatedVisit,
        userProvider.currentUserId ?? '',
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Visit updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(updatedVisit);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission denied. You can only edit your own visits.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating visit: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}