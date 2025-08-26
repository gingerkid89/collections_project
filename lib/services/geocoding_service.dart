// lib/services/geocoding_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class AddressResult {
  final String formattedAddress;
  final double latitude;
  final double longitude;
  final String? street;
  final String? houseNumber;
  final String? postalCode;
  final String? city;
  final String? country;
  final bool isValid;

  AddressResult({
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
    this.street,
    this.houseNumber,
    this.postalCode,
    this.city,
    this.country,
    this.isValid = true,
  });

  factory AddressResult.invalid(String address) {
    return AddressResult(
      formattedAddress: address,
      latitude: 0.0,
      longitude: 0.0,
      isValid: false,
    );
  }

  factory AddressResult.fromNominatim(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;
    
    return AddressResult(
      formattedAddress: json['display_name'] as String,
      latitude: double.parse(json['lat'].toString()),
      longitude: double.parse(json['lon'].toString()),
      street: address?['road'] as String?,
      houseNumber: address?['house_number'] as String?,
      postalCode: address?['postcode'] as String?,
      city: address?['city'] ?? address?['town'] ?? address?['village'] as String?,
      country: address?['country'] as String?,
      isValid: true,
    );
  }

  String get shortAddress {
    final parts = <String>[];
    if (street != null && houseNumber != null) {
      parts.add('$street $houseNumber');
    }
    if (postalCode != null && city != null) {
      parts.add('$postalCode $city');
    }
    return parts.isNotEmpty ? parts.join(', ') : formattedAddress;
  }
}

class GeocodingService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  
  /// Search for addresses matching the query
  static Future<List<AddressResult>> searchAddresses(String query) async {
    if (query.trim().length < 3) return [];

    try {
      final encodedQuery = Uri.encodeComponent(query.trim());
      final url = Uri.parse('$_baseUrl/search?q=$encodedQuery&format=json&addressdetails=1&limit=5&countrycodes=de');
      
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'CollectionApp/1.0 (Flutter)',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        return results
            .map((result) => AddressResult.fromNominatim(result))
            .where((address) => _isValidAddress(address))
            .toList();
      }
    } catch (e) {
      // Silently handle geocoding errors in production
      // TODO: Add proper logging service
    }

    return [];
  }

  /// Verify a specific address and get its coordinates
  static Future<AddressResult?> verifyAddress(String address) async {
    final results = await searchAddresses(address);
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  /// Validate address format (German addresses)
  static bool validateAddressFormat(String address) {
    if (address.trim().isEmpty) return false;
    
    // Basic validation patterns for German addresses
    final patterns = [
      // Street + Number, Postal Code + City
      RegExp(r'^.+\s+\d+[a-z]?\s*,?\s*\d{5}\s+.+$', caseSensitive: false),
      // Just Street + Number (will be verified via API)
      RegExp(r'^.+\s+\d+[a-z]?$', caseSensitive: false),
      // Full address with country
      RegExp(r'^.+\s+\d+[a-z]?\s*,?\s*\d{5}\s+.+,?\s*(Germany|Deutschland)$', caseSensitive: false),
    ];

    return patterns.any((pattern) => pattern.hasMatch(address.trim()));
  }

  /// Check if the address result is suitable for a place
  static bool _isValidAddress(AddressResult address) {
    // Filter out addresses that are too generic or not suitable for places
    final formattedLower = address.formattedAddress.toLowerCase();
    
    // Exclude very generic locations
    if (formattedLower.contains('bundesrepublik deutschland') && 
        !formattedLower.contains('straße') && 
        !formattedLower.contains('platz') &&
        !formattedLower.contains('weg')) {
      return false;
    }

    // Must have coordinates
    if (address.latitude == 0.0 && address.longitude == 0.0) {
      return false;
    }

    // Should have at least a street or recognizable location name
    return address.street != null || 
           formattedLower.contains('straße') || 
           formattedLower.contains('platz') ||
           formattedLower.contains('weg') ||
           formattedLower.contains('allee');
  }

  /// Extract address components from a string
  static Map<String, String> parseAddressComponents(String address) {
    final components = <String, String>{};
    final parts = address.split(',').map((s) => s.trim()).toList();
    
    for (final part in parts) {
      // Look for postal code + city pattern
      final postalCityMatch = RegExp(r'^(\d{5})\s+(.+)$').firstMatch(part);
      if (postalCityMatch != null) {
        components['postalCode'] = postalCityMatch.group(1)!;
        components['city'] = postalCityMatch.group(2)!;
        continue;
      }
      
      // Look for street + house number pattern
      final streetMatch = RegExp(r'^(.+?)\s+(\d+[a-z]?)$').firstMatch(part);
      if (streetMatch != null) {
        components['street'] = streetMatch.group(1)!;
        components['houseNumber'] = streetMatch.group(2)!;
        continue;
      }
      
      // If it looks like a country
      if (part.toLowerCase() == 'germany' || part.toLowerCase() == 'deutschland') {
        components['country'] = part;
        continue;
      }
    }
    
    return components;
  }
}