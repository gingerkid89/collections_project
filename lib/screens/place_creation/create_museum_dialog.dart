// lib/screens/place_creation/create_museum_dialog.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/place.dart';
import '../../models/collection_base.dart';
import '../../models/museum.dart';
import '../../models/location.dart';
import '../../providers/places_provider.dart';
import '../../providers/collections_provider.dart';
import 'widgets/photo_upload_section.dart';
import 'widgets/address_picker_field.dart';
import 'widgets/opening_hours_picker.dart';
import 'widgets/chip_input_field.dart';
import '../../services/geocoding_service.dart';

class CreateMuseumDialog extends StatefulWidget {
  const CreateMuseumDialog({super.key});

  @override
  State<CreateMuseumDialog> createState() => _CreateMuseumDialogState();
}

class _CreateMuseumDialogState extends State<CreateMuseumDialog> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;
  
  // Form Controllers
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _ticketPriceController = TextEditingController();
  
  // Form Data
  List<String> _photos = [];
  String? _primaryPhoto;
  String _category = 'Art';
  bool _hasAudioGuide = false;
  bool _hasGiftShop = false;
  bool _isWheelchairAccessible = false;
  List<String> _currentExhibitions = [];
  List<String> _permanentCollections = [];
  Map<String, String> _openingHours = {};
  String? _selectedCollectionId;
  List<CollectionBase> _availableCollections = [];
  AddressResult? _validatedAddress;

  final List<String> _museumCategories = [
    'Art', 'History', 'Science', 'Technology', 'Natural History',
    'Cultural', 'Military', 'Transportation', 'Sports', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    _loadAvailableCollections();
  }

  void _loadAvailableCollections() {
    // Museum-compatible collections will be loaded dynamically from CollectionsProvider
    // This method is no longer needed since we use Consumer<CollectionsProvider> in the UI
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _ticketPriceController.dispose();
    _pageController.dispose();
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
                'Create Museum',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              Text(
                'Step ${_currentPage + 1} of 3',
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
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                      decoration: BoxDecoration(
                        color: index <= _currentPage 
                          ? const Color(0xFF8B5CF6) 
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
                    _buildMuseumDetailsPage(),
                    _buildContactInfoPage(),
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
                      onPressed: _currentPage == 2 ? _createMuseum : _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(_currentPage == 2 ? 'Create Museum' : 'Next'),
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
              'Tell us about your museum',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),

            // Museum Name
            _buildTextField(
              controller: _nameController,
              label: 'Museum Name *',
              hint: 'e.g., Modern Art Museum',
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
              'Add photos to showcase your museum',
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

  Widget _buildMuseumDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Museum Details',
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

          // Category
          const Text(
            'Museum Category',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: _inputDecoration('Select museum category'),
            items: _museumCategories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) => setState(() => _category = value!),
          ),
          const SizedBox(height: 20),

          // Ticket Price
          _buildTextField(
            controller: _ticketPriceController,
            label: 'Ticket Price',
            hint: 'e.g., €12 for adults, €8 for students',
          ),
          const SizedBox(height: 24),

          // Collections & Exhibitions
          const Text(
            'Permanent Collections',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add tags for permanent collections (tap to add)',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          ChipInputField(
            chips: _permanentCollections,
            onChipsChanged: (chips) {
              setState(() => _permanentCollections = chips);
            },
            hintText: 'e.g., Renaissance Art, Sculptures',
          ),
          const SizedBox(height: 20),

          const Text(
            'Current Exhibitions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add current special exhibitions',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          ChipInputField(
            chips: _currentExhibitions,
            onChipsChanged: (chips) {
              setState(() => _currentExhibitions = chips);
            },
            hintText: 'e.g., Van Gogh Exhibition, Modern Sculptures',
          ),
          const SizedBox(height: 24),

          // Features
          const Text(
            'Museum Features',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          _buildFeatureToggle('Audio Guide Available', _hasAudioGuide, (value) {
            setState(() => _hasAudioGuide = value);
          }),
          _buildFeatureToggle('Gift Shop', _hasGiftShop, (value) {
            setState(() => _hasGiftShop = value);
          }),
          _buildFeatureToggle('Wheelchair Accessible', _isWheelchairAccessible, (value) {
            setState(() => _isWheelchairAccessible = value);
          }),
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
            'Help visitors plan their trip',
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
            hint: 'e.g., www.museum.com',
            keyboardType: TextInputType.url,
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

  Widget _buildFeatureToggle(String title, bool value, ValueChanged<bool> onChanged) {
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
            activeColor: const Color(0xFF8B5CF6),
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
        borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  void _nextPage() {
    if (_currentPage < 2) {
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
                children: [
                  Text(
                    collection.iconEmoji,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      collection.name,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
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

  void _createMuseum() {
    print('Create museum button pressed'); // Debug
    
    if (_formKey.currentState?.validate() ?? false) {
      print('Form validation passed'); // Debug
      _performMuseumCreation();
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

  void _performMuseumCreation() async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Create the museum using PlacesProvider
      final placesProvider = context.read<PlacesProvider>();
      
      final museum = await placesProvider.createMuseum(
        name: _nameController.text,
        address: _addressController.text,
        category: _category,
        ticketPrice: _ticketPriceController.text.isNotEmpty ? _ticketPriceController.text : 'Free',
        currentExhibitions: _currentExhibitions,
        permanentCollections: _permanentCollections,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        website: _websiteController.text.isNotEmpty ? _websiteController.text : null,
        openingHours: _openingHours,
        latitude: _validatedAddress?.latitude,
        longitude: _validatedAddress?.longitude,
        imageUrl: _primaryPhoto,
        hasAudioGuide: _hasAudioGuide,
        hasGiftShop: _hasGiftShop,
        isWheelchairAccessible: _isWheelchairAccessible,
      );

      // Add to collection (now required)
      if (_selectedCollectionId != null && mounted) {
        final collectionsProvider = context.read<CollectionsProvider>();
        
        // Create a location from the created museum
        final location = Location(
          id: museum.id,
          name: museum.name,
          address: museum.info.address,
          latitude: museum.latitude ?? 50.9406,
          longitude: museum.longitude ?? 6.9623,
          imageUrls: museum.imageUrl != null ? [museum.imageUrl!] : _photos,
          features: [
            museum.category,
            museum.ticketPrice,
            if (museum.hasAudioGuide) 'Audio Guide',
            if (museum.hasGiftShop) 'Gift Shop',
            if (museum.isWheelchairAccessible) 'Wheelchair Accessible',
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
                    'Museum created and added to collection!',
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
            content: Text('Error creating museum: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}