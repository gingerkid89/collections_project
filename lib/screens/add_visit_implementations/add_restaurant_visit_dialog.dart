// lib/screens/add_visit_implementations/add_restaurant_visit_dialog.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import '../../models/restaurant.dart';
import '../../models/menu_item.dart';
import '../../models/visit.dart';
import '../../models/visit_activity.dart';
import '../../providers/user_provider.dart';
import '../../l10n/app_localizations.dart';

class AddRestaurantVisitDialog extends StatefulWidget {
  final Restaurant restaurant;

  const AddRestaurantVisitDialog({
    super.key,
    required this.restaurant,
  });

  @override
  State<AddRestaurantVisitDialog> createState() => _AddRestaurantVisitDialogState();
}

class _AddRestaurantVisitDialogState extends State<AddRestaurantVisitDialog> {
  // Basic visit data
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  final TextEditingController notesController = TextEditingController();
  double overallRating = 0.0;

  // Photo and privacy data
  List<String> photoUrls = [];
  final ImagePicker _picker = ImagePicker();
  bool isPublic = true;

  // Restaurant-specific data
  List<MenuItem> selectedDishes = [];
  double tipAmount = 0.0;
  double otherCosts = 0.0;

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

  double get totalCost {
    final dishTotal = selectedDishes.fold<double>(0, (sum, dish) => sum + dish.price);
    return dishTotal + tipAmount + otherCosts;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.visitDetails} - ${widget.restaurant.name}'),
        backgroundColor: Colors.green,
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
            _buildMenuSelectionSection(),
            _buildCostSection(),
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
                hintText: l10n.restaurantVisitNotes,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSelectionSection() {
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
                const Icon(Icons.restaurant_menu, color: Colors.green),
                const SizedBox(width: 8),
                Text(l10n.dishesOrdered, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            
            // Selected dishes
            if (selectedDishes.isNotEmpty) ...[
              Text(l10n.selectedDishes, style: const TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              ...selectedDishes.map((dish) => _buildSelectedDishTile(dish)),
              const SizedBox(height: 16),
            ],
            
            // Available dishes
            Text(l10n.availableDishes, style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: widget.restaurant.menu.length,
                itemBuilder: (context, index) {
                  final dish = widget.restaurant.menu[index];
                  final isSelected = selectedDishes.any((d) => d.id == dish.id);
                  return ListTile(
                    title: Text(dish.name),
                    subtitle: Text('${dish.formattedPrice} - ${dish.category}'),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Colors.green)
                        : const Icon(Icons.add),
                    onTap: isSelected ? null : () => _addDish(dish),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostSection() {
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
                const Icon(Icons.euro, color: Colors.green),
                const SizedBox(width: 8),
                Text(l10n.costs, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            
            // Cost summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.dishesWithColon),
                      Text('€${(totalCost - tipAmount - otherCosts).toStringAsFixed(2)}'),
                    ],
                  ),
                  if (tipAmount > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.tip),
                        Text('€${tipAmount.toStringAsFixed(2)}'),
                      ],
                    ),
                  ],
                  if (otherCosts > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.other),
                        Text('€${otherCosts.toStringAsFixed(2)}'),
                      ],
                    ),
                  ],
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.total, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        '€${totalCost.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
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
                const Icon(Icons.photo_camera, color: Colors.green),
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
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
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
                const Icon(Icons.privacy_tip, color: Colors.green),
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
              activeColor: Colors.green,
            ),
            RadioListTile<bool>(
              title: Text(l10n.privateData),
              subtitle: Text(l10n.privateDataDescription),
              value: false,
              groupValue: isPublic,
              onChanged: (value) => setState(() => isPublic = value!),
              activeColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDishTile(MenuItem dish) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dish.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text('${dish.formattedPrice} - ${dish.category}', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeDish(dish),
            icon: const Icon(Icons.close, color: Colors.red),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
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

  void _addDish(MenuItem dish) {
    setState(() {
      selectedDishes.add(dish);
    });
  }

  void _removeDish(MenuItem dish) {
    setState(() {
      selectedDishes.removeWhere((d) => d.id == dish.id);
    });
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
          content: Text(l10n.visitSavedSuccessfully),
          backgroundColor: Colors.green,
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
    final dishActivities = selectedDishes.map((dish) {
      return RestaurantDish(
        id: dish.id,
        name: dish.name,
        category: dish.category,
        price: dish.price,
        description: dish.description,
      );
    }).toList();

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserId = userProvider.currentUserId ?? '';
    
    return Visit.create(
      userId: currentUserId,
      date: visitDateTime,
      placeId: widget.restaurant.id,
      placeType: 'restaurant',
      overallRating: overallRating,
      notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
      totalCost: totalCost > 0 ? totalCost : null,
      activities: dishActivities,
      photoUrls: photoUrls,
      isPublic: isPublic,
      metadata: {
        'restaurant_name': widget.restaurant.name,
        'tip_amount': tipAmount,
        'other_costs': otherCosts,
        'dish_count': selectedDishes.length,
      },
    );
  }
}