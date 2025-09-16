// lib/utils/unicode_fixes.dart

/// Utility class to fix Unicode display issues in API data
/// Handles corrupted characters and provides fallbacks for proper display
class UnicodeFixes {
  
  /// Fix price range display issues
  static String fixPriceRange(String? priceRange) {
    if (priceRange == null || priceRange.isEmpty) return '€';
    
    // Replace common corrupted characters
    String fixed = priceRange
        .replaceAll('�', '€')  // Replace replacement character with Euro
        .replaceAll('??', '€€') // Replace double question marks
        .replaceAll('???', '€€€') // Replace triple question marks
        .replaceAll('????', '€€€€'); // Replace quad question marks
    
    // Handle specific known corrupted patterns
    final pricePatterns = {
      '10�': '10€',
      '8�': '8€',
      'Free': 'Free',
      '€€': '€€',
      '€€€': '€€€',
      '€€€€': '€€€€',
      '��': '€€',
      '���': '€€€',
    };
    
    pricePatterns.forEach((corrupted, clean) {
      fixed = fixed.replaceAll(corrupted, clean);
    });
    
    // If still contains replacement characters, provide fallback
    if (fixed.contains('�') || fixed.contains('??')) {
      // Try to guess based on length and content
      if (fixed.toLowerCase().contains('free')) return 'Free';
      if (fixed.contains('10')) return '10€';
      if (fixed.contains('8')) return '8€';
      if (fixed.contains('15')) return '15€';
      
      // Default fallbacks based on common patterns
      switch (fixed.length) {
        case 2:
          return '€€';
        case 3:
          return fixed.contains('1') ? '10€' : '€€€';
        case 4:
          return '€€€€';
        default:
          return '€';
      }
    }
    
    return fixed;
  }
  
  /// Fix emoji display issues
  static String fixEmoji(String? emoji) {
    if (emoji == null || emoji.isEmpty) return '📍';
    
    // Replace common corrupted emoji patterns
    final emojiPatterns = {
      '??': '🍽️',     // Restaurant default
      '???': '🏛️',    // Museum default  
      '????': '🍕',   // Pizza/Italian food
      '�': '📍',      // Generic location
    };
    
    String fixed = emoji;
    emojiPatterns.forEach((corrupted, clean) {
      fixed = fixed.replaceAll(corrupted, clean);
    });
    
    // If still contains replacement characters, provide type-based fallbacks
    if (fixed.contains('�') || fixed.contains('?')) {
      return '📍'; // Generic fallback
    }
    
    return fixed;
  }
  
  /// Get a proper emoji based on place type when API emoji is corrupted
  static String getPlaceTypeEmoji(String placeType, String? originalEmoji) {
    // First try to fix the original emoji
    String fixedEmoji = fixEmoji(originalEmoji);
    
    // If it's still corrupted, use type-based defaults
    if (fixedEmoji.contains('�') || fixedEmoji.contains('?') || fixedEmoji == '📍') {
      switch (placeType.toLowerCase()) {
        case 'restaurant':
          return '🍽️';
        case 'museum':
          return '🏛️';
        case 'park':
          return '🌳';
        case 'hotel':
          return '🏨';
        default:
          return '📍';
      }
    }
    
    return fixedEmoji;
  }
  
  /// Clean up any text that might have Unicode issues
  static String cleanText(String? text) {
    if (text == null) return '';
    
    return text
        .replaceAll('�', '') // Remove replacement characters
        .replaceAll('??', '') // Remove double question marks from encoding issues
        .trim();
  }
  
  /// Get a user-friendly price range display
  static String getPriceRangeDisplay(String? priceRange) {
    String cleaned = fixPriceRange(priceRange);
    
    // Add descriptions for better UX
    switch (cleaned) {
      case 'Free':
        return 'Free';
      case '€':
        return '€ Budget';
      case '€€':
        return '€€ Moderate';  
      case '€€€':
        return '€€€ Expensive';
      case '€€€€':
        return '€€€€ Luxury';
      default:
        // Handle specific prices like "10€", "8€"
        if (cleaned.contains('€') && cleaned.length <= 4) {
          return cleaned;
        }
        return cleaned.isEmpty ? '€' : cleaned;
    }
  }
  
  /// Check if a string contains corrupted Unicode characters
  static bool hasUnicodeIssues(String? text) {
    if (text == null) return false;
    return text.contains('�') || text.contains('??');
  }
}