// lib/screens/place_creation/widgets/address_picker_field.dart

import 'package:flutter/material.dart';
import '../../../services/geocoding_service.dart';

class AddressPickerField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onAddressSelected;
  final Function(AddressResult?)? onAddressValidated;

  const AddressPickerField({
    super.key,
    required this.controller,
    required this.onAddressSelected,
    this.onAddressValidated,
  });

  @override
  State<AddressPickerField> createState() => _AddressPickerFieldState();
}

class _AddressPickerFieldState extends State<AddressPickerField> {
  bool _isSearching = false;
  List<AddressResult> _suggestions = [];
  AddressResult? _selectedAddress;
  bool _isValid = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Address *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          onChanged: _onAddressChanged,
          validator: (value) {
            if (value?.isEmpty == true) {
              return 'Address is required';
            }
            if (!_isValid && value?.isNotEmpty == true) {
              return 'Please select a valid address from suggestions';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Enter street, house number, postal code, city',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _isValid ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _isValid ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _isValid ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            prefixIcon: _isValid 
                ? const Icon(Icons.check_circle, color: Color(0xFF10B981))
                : null,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isSearching)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    onPressed: _showMapPicker,
                    icon: const Icon(Icons.map, color: Color(0xFF6B7280)),
                    tooltip: 'Pick from map',
                  ),
              ],
            ),
          ),
        ),
        
        // Address Suggestions
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: _suggestions.map((suggestion) {
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.location_on, color: Color(0xFF6B7280), size: 16),
                  title: Text(
                    suggestion.formattedAddress,
                    style: const TextStyle(fontSize: 14),
                  ),
                  subtitle: suggestion.shortAddress.isNotEmpty 
                      ? Text(
                          suggestion.shortAddress,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                        )
                      : null,
                  onTap: () => _selectSuggestion(suggestion),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  void _onAddressChanged(String value) async {
    setState(() {
      _isValid = false;
      _selectedAddress = null;
    });
    
    widget.onAddressValidated?.call(null);
    
    if (value.length > 2) {
      setState(() => _isSearching = true);
      
      try {
        final results = await GeocodingService.searchAddresses(value);
        if (mounted) {
          setState(() {
            _isSearching = false;
            _suggestions = results;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSearching = false;
            _suggestions = [];
          });
        }
      }
    } else {
      setState(() => _suggestions = []);
    }
  }


  void _selectSuggestion(AddressResult suggestion) {
    setState(() {
      _selectedAddress = suggestion;
      _isValid = true;
      _suggestions = [];
    });
    
    widget.controller.text = suggestion.formattedAddress;
    widget.onAddressSelected(suggestion.formattedAddress);
    widget.onAddressValidated?.call(suggestion);
    
    // Show confirmation dialog
    _showAddressConfirmation(suggestion);
  }
  
  void _showAddressConfirmation(AddressResult address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_on, color: Color(0xFF10B981)),
            SizedBox(width: 8),
            Text('Address Confirmed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected Address:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              address.formattedAddress,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF111827),
              ),
            ),
            if (address.shortAddress.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Short Address:',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                address.shortAddress,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Coordinates:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${address.latitude.toStringAsFixed(6)}, ${address.longitude.toStringAsFixed(6)}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showMapPicker() {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Pick Location'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Mock selected address
                  const selectedAddress = 'Selected from Map, 50667 Köln, Germany';
                  widget.controller.text = selectedAddress;
                  widget.onAddressSelected(selectedAddress);
                  Navigator.of(context).pop();
                },
                child: const Text('Done'),
              ),
            ],
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFF3F4F6),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 64,
                    color: Color(0xFF9CA3AF),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Interactive Map',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Map integration coming soon!\nFor now, use the address search above.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}