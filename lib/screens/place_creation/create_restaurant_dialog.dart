// lib/screens/place_creation/create_restaurant_dialog.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/place.dart';
import '../../models/collection_base.dart';
import '../../models/restaurant.dart';
import '../../models/location.dart';
import '../../models/menu_item.dart';
import '../../providers/collections_provider.dart';
import '../../providers/places_provider.dart';
import 'widgets/photo_upload_section.dart';
import 'widgets/address_picker_field.dart';
import 'widgets/opening_hours_picker.dart';
import 'widgets/chip_input_field.dart';
import '../../services/geocoding_service.dart';

class CreateRestaurantDialog extends StatefulWidget {
  const CreateRestaurantDialog({super.key});

  @override
  State<CreateRestaurantDialog> createState() => _CreateRestaurantDialogState();
}

class _CreateRestaurantDialogState extends State<CreateRestaurantDialog> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;
  
  // Form Controllers
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _emailController = TextEditingController();
  
  // Form Data
  List<String> _photos = [];
  String? _primaryPhoto;
  String _cuisine = 'Italian';
  String _priceCategory = '€€';
  bool _hasReservation = false;
  bool _hasDelivery = false;
  bool _hasTakeout = false;
  Map<String, String> _openingHours = {};
  String? _selectedCollectionId;
  List<CollectionBase> _availableCollections = [];
  AddressResult? _validatedAddress;
  List<String> _highlights = [];
  List<MenuItem> _menuItems = [];
  
  // Menu item creation controllers
  final _menuItemNameController = TextEditingController();
  final _menuItemDescriptionController = TextEditingController();
  final _menuItemPriceController = TextEditingController();
  String _menuItemCategory = 'Main Dishes';
  List<String> _menuItemAllergens = [];
  bool _isVegetarian = false;
  bool _isVegan = false;
  bool _isGlutenFree = false;

  final List<String> _cuisineTypes = [
    'Italian', 'Asian', 'Fast Food', 'German', 'French', 'Mexican',
    'Indian', 'Greek', 'American', 'Mediterranean', 'Japanese', 'Other'
  ];
  
  final List<String> _menuCategories = [
    'Main Dishes', 'Appetizers', 'Soups', 'Salads', 'Pizza', 'Pasta', 
    'Burgers', 'Sides', 'Desserts', 'Beverages', 'Coffee', 'Wine', 'Beer'
  ];
  
  final List<String> _commonAllergens = [
    'Gluten', 'Milk', 'Eggs', 'Fish', 'Shellfish', 'Tree Nuts', 
    'Peanuts', 'Soy', 'Sesame', 'Celery', 'Mustard', 'Sulphites'
  ];

  @override
  void initState() {
    super.initState();
    // Collections will be loaded from provider when needed
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _emailController.dispose();
    _pageController.dispose();
    _menuItemNameController.dispose();
    _menuItemDescriptionController.dispose();
    _menuItemPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Restaurant',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              Text(
                'Step ${_currentPage + 1} of 4',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          actions: [
            if (_currentPage > 0)
              TextButton(
                onPressed: _previousPage,
                child: const Text('Back'),
              ),
          ],
        ),
        body: Column(
          children: [
            // Progress Indicator
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                      decoration: BoxDecoration(
                        color: index <= _currentPage 
                          ? const Color(0xFFEF4444) 
                          : const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            // Form Content
            Expanded(
              child: Form(
                key: _formKey,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  physics: const NeverScrollableScrollPhysics(), // Disable swipe
                  children: [
                    _buildBasicInfoPage(),
                    _buildRestaurantDetailsPage(),
                    _buildContactInfoPage(),
                    _buildMenuPage(),
                  ],
                ),
              ),
            ),
            
            // Bottom Actions
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _currentPage == 3 ? _createRestaurant : _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(_currentPage == 3 ? 'Create Restaurant' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tell us about your restaurant',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),

            // Restaurant Name
            _buildTextField(
              controller: _nameController,
              label: 'Restaurant Name *',
              hint: 'e.g., La Bella Vista',
              validator: (value) => value?.isEmpty == true ? 'Name is required' : null,
            ),
            const SizedBox(height: 20),

            // Address
            AddressPickerField(
              controller: _addressController,
              onAddressSelected: (address) {
                _addressController.text = address;
              },
              onAddressValidated: (addressResult) {
                setState(() {
                  _validatedAddress = addressResult;
                });
              },
            ),
            const SizedBox(height: 24),

            // Photos Section
            const Text(
              'Photos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add photos to help others find your restaurant',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 12),
            PhotoUploadSection(
              photos: _photos,
              primaryPhoto: _primaryPhoto,
              onPhotosChanged: (photos, primaryPhoto) {
                setState(() {
                  _photos = photos;
                  _primaryPhoto = primaryPhoto;
                });
              },
            ),
            const SizedBox(height: 24),

            // Add to Collection
            const Text(
              'Add to Collection (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose an existing collection or leave empty to create a standalone place',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 12),
            _buildCollectionSelector(),
          ],
      ),
    );
  }

  Widget _buildRestaurantDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Restaurant Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Help visitors know what to expect',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),

          // Cuisine Type
          const Text(
            'Cuisine Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _cuisine,
            decoration: _inputDecoration('Select cuisine type'),
            items: _cuisineTypes.map((cuisine) {
              return DropdownMenuItem(
                value: cuisine,
                child: Text(cuisine),
              );
            }).toList(),
            onChanged: (value) => setState(() => _cuisine = value!),
          ),
          const SizedBox(height: 20),

          // Price Category
          const Text(
            'Price Range',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: ['€', '€€', '€€€'].map((price) {
              final isSelected = _priceCategory == price;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _priceCategory = price),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFEF4444) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFEF4444) : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Text(
                      price,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Services
          const Text(
            'Available Services',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          _buildServiceToggle('Reservations', _hasReservation, (value) {
            setState(() => _hasReservation = value);
          }),
          _buildServiceToggle('Delivery', _hasDelivery, (value) {
            setState(() => _hasDelivery = value);
          }),
          _buildServiceToggle('Takeout', _hasTakeout, (value) {
            setState(() => _hasTakeout = value);
          }),
          const SizedBox(height: 24),

          // Restaurant Highlights
          const Text(
            'Restaurant Highlights',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add special features or highlights (e.g., "Outdoor Seating", "Live Music")',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 12),
          ChipInputField(
            chips: _highlights,
            onChipsChanged: (highlights) {
              setState(() => _highlights = highlights);
            },
            hintText: 'Add highlight and press Enter',
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact & Hours',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Help customers reach you',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),

          // Phone
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            hint: 'e.g., +49 221 1234567',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),

          // Website
          _buildTextField(
            controller: _websiteController,
            label: 'Website',
            hint: 'e.g., www.restaurant.com',
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 20),

          // Email
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'e.g., info@restaurant.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),

          // Opening Hours
          const Text(
            'Opening Hours',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          OpeningHoursPicker(
            openingHours: _openingHours,
            onHoursChanged: (hours) {
              setState(() => _openingHours = hours);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }

  Widget _buildServiceToggle(String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF111827),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      filled: true,
      fillColor: Colors.white,
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
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildMenuPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Restaurant Menu',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add dishes to your restaurant menu (optional but recommended)',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),

          // Add Menu Item Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add New Menu Item',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 16),

                // Item Name
                _buildTextField(
                  controller: _menuItemNameController,
                  label: 'Dish Name *',
                  hint: 'e.g., Margherita Pizza',
                  validator: (value) => value?.isEmpty == true ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),

                // Item Description
                _buildTextField(
                  controller: _menuItemDescriptionController,
                  label: 'Description',
                  hint: 'Brief description of the dish...',
                ),
                const SizedBox(height: 16),

                // Price and Category Row
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildTextField(
                        controller: _menuItemPriceController,
                        label: 'Price (€) *',
                        hint: '12.50',
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value?.isEmpty == true) return 'Price is required';
                          if (double.tryParse(value!) == null) return 'Invalid price';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Category',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _menuItemCategory,
                            decoration: _inputDecoration('Select category'),
                            items: _menuCategories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _menuItemCategory = value!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Dietary Information
                const Text(
                  'Dietary Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildCheckboxTile('Vegetarian', _isVegetarian, (value) {
                        setState(() {
                          _isVegetarian = value;
                          if (!value) _isVegan = false; // Vegan implies vegetarian
                        });
                      }),
                    ),
                    Expanded(
                      child: _buildCheckboxTile('Vegan', _isVegan, (value) {
                        setState(() {
                          _isVegan = value;
                          if (value) _isVegetarian = true; // Vegan implies vegetarian
                        });
                      }),
                    ),
                    Expanded(
                      child: _buildCheckboxTile('Gluten-Free', _isGlutenFree, (value) {
                        setState(() => _isGlutenFree = value);
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Allergens
                const Text(
                  'Allergens',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select all allergens present in this dish',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _commonAllergens.map((allergen) {
                    final isSelected = _menuItemAllergens.contains(allergen);
                    return FilterChip(
                      label: Text(allergen),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _menuItemAllergens.add(allergen);
                          } else {
                            _menuItemAllergens.remove(allergen);
                          }
                        });
                      },
                      selectedColor: const Color(0xFFEF4444).withOpacity(0.2),
                      checkmarkColor: const Color(0xFFEF4444),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Add Item Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addMenuItem,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Add to Menu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          if (_menuItems.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Current Menu Items',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            ...(_menuItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildMenuItemCard(item, index);
            }).toList()),
          ],
        ],
      ),
    );
  }

  Widget _buildCheckboxTile(String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: value,
            onChanged: (newValue) => onChanged(newValue ?? false),
            activeColor: const Color(0xFFEF4444),
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemCard(MenuItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Category: ${item.category}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    item.formattedPrice,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _removeMenuItem(index),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
          if (item.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
          if (item.hasDietaryRestrictions || item.allergens.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                ...item.dietaryLabels.map((label) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green.shade700,
                    ),
                  ),
                )),
                ...item.allergens.map((allergen) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    allergen,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.orange.shade700,
                    ),
                  ),
                )),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _addMenuItem() {
    if (_menuItemNameController.text.trim().isEmpty || 
        _menuItemPriceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter name and price'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final price = double.tryParse(_menuItemPriceController.text.trim());
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid price'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final menuItem = MenuItem(
      id: 'item_${DateTime.now().millisecondsSinceEpoch}',
      name: _menuItemNameController.text.trim(),
      description: _menuItemDescriptionController.text.trim(),
      price: price,
      category: _menuItemCategory,
      allergens: List<String>.from(_menuItemAllergens),
      isVegetarian: _isVegetarian,
      isVegan: _isVegan,
      isGlutenFree: _isGlutenFree,
    );

    setState(() {
      _menuItems.add(menuItem);
      // Clear form
      _menuItemNameController.clear();
      _menuItemDescriptionController.clear();
      _menuItemPriceController.clear();
      _menuItemCategory = 'Main Dishes';
      _menuItemAllergens.clear();
      _isVegetarian = false;
      _isVegan = false;
      _isGlutenFree = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Menu item added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeMenuItem(int index) {
    setState(() {
      _menuItems.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Menu item removed'),
      ),
    );
  }

  Widget _buildCollectionSelector() {
    return Consumer<CollectionsProvider>(
      builder: (context, collectionsProvider, child) {
        final availableCollections = collectionsProvider.collections;
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedCollectionId,
            hint: const Text(
              'Select a collection (required)',
              style: TextStyle(color: Color(0xFF9CA3AF)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a collection';
              }
              return null;
            },
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: availableCollections.map((collection) {
                return DropdownMenuItem<String>(
                  value: collection.id,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        collection.iconEmoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          collection.name,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF111827),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${collection.totalCount} places',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            onChanged: (value) {
              setState(() => _selectedCollectionId = value);
            },
          ),
        );
      },
    );
  }

  void _createRestaurant() {
    print('Create restaurant button pressed'); // Debug
    
    if (_formKey.currentState?.validate() ?? false) {
      print('Form validation passed'); // Debug
      _performRestaurantCreation();
    } else {
      print('Form validation failed'); // Debug
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _performRestaurantCreation() async {
    try {
      print('Starting restaurant creation process'); // Debug
      
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Create the restaurant using PlacesProvider
      final placesProvider = context.read<PlacesProvider>();
      
      final restaurant = await placesProvider.createRestaurant(
        name: _nameController.text,
        address: _addressController.text,
        cuisine: _cuisine,
        priceCategory: _priceCategory,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        website: _websiteController.text.isNotEmpty ? _websiteController.text : null,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        openingHours: _openingHours,
        highlights: List<String>.from(_highlights),
        latitude: _validatedAddress?.latitude,
        longitude: _validatedAddress?.longitude,
        imageUrl: _primaryPhoto,
        hasReservation: _hasReservation,
        hasDelivery: _hasDelivery,
        hasTakeout: _hasTakeout,
        menuItems: List<MenuItem>.from(_menuItems),
      );

      // Add to collection (now required)
      if (_selectedCollectionId != null && mounted) {
        final collectionsProvider = context.read<CollectionsProvider>();
        
        // Create a location from the created restaurant
        final location = Location(
          id: restaurant.id,
          name: restaurant.name,
          address: restaurant.info.address,
          latitude: restaurant.latitude ?? 50.9364,
          longitude: restaurant.longitude ?? 6.9528,
          imageUrls: restaurant.imageUrl != null ? [restaurant.imageUrl!] : _photos,
          features: [
            restaurant.cuisine,
            restaurant.priceCategory,
            if (restaurant.hasDelivery) 'Delivery',
            if (restaurant.hasTakeout) 'Takeout',
            if (restaurant.hasReservation) 'Reservations',
          ],
          averageRating: 0.0,
          isVisited: false,
        );
        
        // Add to collection using provider
        collectionsProvider.addLocationToCollection(_selectedCollectionId!, location);
      }

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Restaurant created and added to collection!',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // Close dialog
      if (mounted) Navigator.of(context).pop();

    } catch (e) {
      // Close loading dialog if open
      if (mounted) Navigator.of(context).pop();
      
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating restaurant: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}