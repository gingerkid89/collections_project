// lib/utils/default_place_images.dart

import 'package:flutter/material.dart';

/// Utility class to generate visually appealing default images for places
/// when no actual photo is available from the API
class DefaultPlaceImages {
  
  /// Generate a default image widget for a place based on its type and properties
  static Widget generateDefaultImage({
    required String placeType,
    required String placeName,
    String? emoji,
    double? width,
    double? height,
  }) {
    // Use place name hash to generate consistent colors
    final nameHash = placeName.hashCode.abs();
    
    switch (placeType.toLowerCase()) {
      case 'restaurant':
        return _buildRestaurantDefault(
          placeName: placeName,
          emoji: emoji,
          nameHash: nameHash,
          width: width,
          height: height,
        );
      case 'museum':
        return _buildMuseumDefault(
          placeName: placeName,
          emoji: emoji,
          nameHash: nameHash,
          width: width,
          height: height,
        );
      default:
        return _buildGenericDefault(
          placeName: placeName,
          emoji: emoji,
          nameHash: nameHash,
          width: width,
          height: height,
        );
    }
  }

  /// Build default image for restaurants with food/dining theme
  static Widget _buildRestaurantDefault({
    required String placeName,
    String? emoji,
    required int nameHash,
    double? width,
    double? height,
  }) {
    final colors = _getRestaurantGradient(nameHash);
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          _buildRestaurantPattern(),
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Emoji or default restaurant icon
                Text(
                  emoji ?? '🍽️',
                  style: const TextStyle(
                    fontSize: 48,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                // Place name
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getTruncatedName(placeName, 20),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build default image for museums with cultural/art theme
  static Widget _buildMuseumDefault({
    required String placeName,
    String? emoji,
    required int nameHash,
    double? width,
    double? height,
  }) {
    final colors = _getMuseumGradient(nameHash);
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          _buildMuseumPattern(),
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Emoji or default museum icon
                Text(
                  emoji ?? '🏛️',
                  style: const TextStyle(
                    fontSize: 48,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                // Place name
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getTruncatedName(placeName, 20),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build generic default image for unknown place types
  static Widget _buildGenericDefault({
    required String placeName,
    String? emoji,
    required int nameHash,
    double? width,
    double? height,
  }) {
    final colors = _getGenericGradient(nameHash);
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji or default location icon
            Text(
              emoji ?? '📍',
              style: const TextStyle(
                fontSize: 48,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            // Place name
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getTruncatedName(placeName, 20),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get restaurant-themed gradient colors based on name hash
  static List<Color> _getRestaurantGradient(int hash) {
    final gradients = [
      [const Color(0xFFFF6B6B), const Color(0xFF4ECDC4)], // Red to Teal
      [const Color(0xFF4ECDC4), const Color(0xFF44A08D)], // Teal to Green
      [const Color(0xFFFF8E53), const Color(0xFFFF6B6B)], // Orange to Red
      [const Color(0xFF667eea), const Color(0xFF764ba2)], // Blue to Purple
      [const Color(0xFFf093fb), const Color(0xFFf5576c)], // Pink to Red
      [const Color(0xFF4facfe), const Color(0xFF00f2fe)], // Blue to Cyan
    ];
    return gradients[hash % gradients.length];
  }

  /// Get museum-themed gradient colors based on name hash
  static List<Color> _getMuseumGradient(int hash) {
    final gradients = [
      [const Color(0xFF8360c3), const Color(0xFF2ebf91)], // Purple to Green
      [const Color(0xFF667eea), const Color(0xFF764ba2)], // Blue to Purple
      [const Color(0xFFf093fb), const Color(0xFFf5576c)], // Pink to Red
      [const Color(0xFF4facfe), const Color(0xFF00f2fe)], // Blue to Cyan
      [const Color(0xFFfa709a), const Color(0xFFfee140)], // Pink to Yellow
      [const Color(0xFFa8edea), const Color(0xFFfed6e3)], // Mint to Pink
    ];
    return gradients[hash % gradients.length];
  }

  /// Get generic gradient colors based on name hash
  static List<Color> _getGenericGradient(int hash) {
    final gradients = [
      [const Color(0xFFbdc3c7), const Color(0xFF2c3e50)], // Gray to Dark
      [const Color(0xFF74b9ff), const Color(0xFF0984e3)], // Light Blue to Blue
      [const Color(0xFF6c5ce7), const Color(0xFFa29bfe)], // Purple to Light Purple
      [const Color(0xFF00b894), const Color(0xFF00cec9)], // Green to Cyan
    ];
    return gradients[hash % gradients.length];
  }

  /// Build decorative pattern for restaurant background
  static Widget _buildRestaurantPattern() {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.1,
        child: Stack(
          children: [
            // Utensils pattern
            const Positioned(
              top: 20,
              right: 20,
              child: Text('🍴', style: TextStyle(fontSize: 20)),
            ),
            const Positioned(
              bottom: 30,
              left: 30,
              child: Text('🥘', style: TextStyle(fontSize: 16)),
            ),
            const Positioned(
              top: 60,
              left: 20,
              child: Text('🍷', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  /// Build decorative pattern for museum background
  static Widget _buildMuseumPattern() {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.1,
        child: Stack(
          children: [
            // Cultural pattern
            const Positioned(
              top: 20,
              right: 20,
              child: Text('🎨', style: TextStyle(fontSize: 20)),
            ),
            const Positioned(
              bottom: 30,
              left: 30,
              child: Text('🏺', style: TextStyle(fontSize: 16)),
            ),
            const Positioned(
              top: 60,
              left: 20,
              child: Text('🖼️', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  /// Truncate place name to fit in the display
  static String _getTruncatedName(String name, int maxLength) {
    if (name.length <= maxLength) return name;
    return '${name.substring(0, maxLength - 3)}...';
  }

  /// Check if a place has a valid image URL
  static bool hasValidImage(String? imageUrl) {
    return imageUrl != null && 
           imageUrl.isNotEmpty && 
           (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));
  }

  /// Widget builder that shows default image when no valid image URL is provided
  static Widget buildPlaceImage({
    required String placeType,
    required String placeName,
    String? imageUrl,
    String? emoji,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
  }) {
    Widget imageWidget;
    
    if (hasValidImage(imageUrl)) {
      imageWidget = Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder ?? (context, error, stackTrace) {
          // Fallback to default image on network error
          return generateDefaultImage(
            placeType: placeType,
            placeName: placeName,
            emoji: emoji,
            width: width,
            height: height,
          );
        },
      );
    } else {
      imageWidget = generateDefaultImage(
        placeType: placeType,
        placeName: placeName,
        emoji: emoji,
        width: width,
        height: height,
      );
    }

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius,
        child: imageWidget,
      );
    }

    if (onTap != null) {
      imageWidget = GestureDetector(
        onTap: onTap,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}