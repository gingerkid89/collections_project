// lib/services/duplicate_detection_service.dart

import '../models/place.dart';

class PlaceCreationData {
  final String name;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? website;
  final String type; // 'restaurant', 'museum', etc.

  const PlaceCreationData({
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
    this.phone,
    this.website,
    required this.type,
  });
}

class DuplicateMatch {
  final Place place;
  final double confidenceScore; // 0.0 - 1.0
  final List<DuplicateReason> reasons;
  final String explanation;

  const DuplicateMatch({
    required this.place,
    required this.confidenceScore,
    required this.reasons,
    required this.explanation,
  });
}

enum DuplicateReason {
  sameName,
  sameAddress,
  closeProximity,
  samePhone,
  sameWebsite,
  similarName,
  similarAddress,
}

class DuplicateDetectionService {
  // Thresholds for detection
  static const double _proximityThresholdMeters = 50.0;
  static const double _nameThreshold = 0.8; // Similarity threshold
  static const double _addressThreshold = 0.85;
  static const double _highConfidenceThreshold = 0.9;
  static const double _mediumConfidenceThreshold = 0.7;

  /// Find potential duplicates for a new place
  static Future<List<DuplicateMatch>> findSimilarPlaces(
    PlaceCreationData data,
    List<Place> existingPlaces,
  ) async {
    final matches = <DuplicateMatch>[];

    for (final existingPlace in existingPlaces) {
      // Skip if different type
      if (existingPlace.type.toLowerCase() != data.type.toLowerCase()) {
        continue;
      }

      final match = _analyzeDuplicate(data, existingPlace);
      if (match != null && match.confidenceScore > 0.5) {
        matches.add(match);
      }
    }

    // Sort by confidence score (highest first)
    matches.sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));
    
    return matches;
  }

  static DuplicateMatch? _analyzeDuplicate(PlaceCreationData data, Place existingPlace) {
    final reasons = <DuplicateReason>[];
    var score = 0.0;
    final explanationParts = <String>[];

    // Check name similarity
    final nameScore = _calculateStringSimilarity(
      data.name.toLowerCase(), 
      existingPlace.name.toLowerCase()
    );
    
    if (nameScore > 0.95) {
      reasons.add(DuplicateReason.sameName);
      score += 0.4;
      explanationParts.add('Same name');
    } else if (nameScore > _nameThreshold) {
      reasons.add(DuplicateReason.similarName);
      score += 0.2 * nameScore;
      explanationParts.add('Similar name (${(nameScore * 100).toInt()}% match)');
    }

    // Check address similarity
    final addressScore = _calculateStringSimilarity(
      data.address.toLowerCase(),
      existingPlace.info.address.toLowerCase()
    );
    
    if (addressScore > 0.95) {
      reasons.add(DuplicateReason.sameAddress);
      score += 0.4;
      explanationParts.add('Same address');
    } else if (addressScore > _addressThreshold) {
      reasons.add(DuplicateReason.similarAddress);
      score += 0.25 * addressScore;
      explanationParts.add('Similar address (${(addressScore * 100).toInt()}% match)');
    }

    // Check geographic proximity
    if (data.latitude != null && data.longitude != null) {
      // Note: In real implementation, you'd get coordinates from existing place
      // For now, we'll simulate this check
      final distance = _calculateMockDistance(data, existingPlace);
      if (distance <= _proximityThresholdMeters) {
        reasons.add(DuplicateReason.closeProximity);
        score += 0.3 * (1 - (distance / _proximityThresholdMeters));
        explanationParts.add('Within ${distance.toInt()}m radius');
      }
    }

    // Check phone number
    if (data.phone != null && 
        existingPlace.info.phone != null && 
        data.phone!.isNotEmpty) {
      final normalizedDataPhone = _normalizePhone(data.phone!);
      final normalizedExistingPhone = _normalizePhone(existingPlace.info.phone!);
      
      if (normalizedDataPhone == normalizedExistingPhone) {
        reasons.add(DuplicateReason.samePhone);
        score += 0.3;
        explanationParts.add('Same phone number');
      }
    }

    // Check website
    if (data.website != null && 
        existingPlace.info.website != null && 
        data.website!.isNotEmpty) {
      final normalizedDataWebsite = _normalizeWebsite(data.website!);
      final normalizedExistingWebsite = _normalizeWebsite(existingPlace.info.website!);
      
      if (normalizedDataWebsite == normalizedExistingWebsite) {
        reasons.add(DuplicateReason.sameWebsite);
        score += 0.25;
        explanationParts.add('Same website');
      }
    }

    // Boost score if multiple strong indicators
    if (reasons.length >= 2) {
      score += 0.1 * (reasons.length - 1);
    }

    // Cap the score at 1.0
    score = score.clamp(0.0, 1.0);

    if (score <= 0.5) return null;

    return DuplicateMatch(
      place: existingPlace,
      confidenceScore: score,
      reasons: reasons,
      explanation: explanationParts.join(', '),
    );
  }

  /// Calculate string similarity using Levenshtein distance
  static double _calculateStringSimilarity(String a, String b) {
    if (a == b) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;
    
    final distance = _levenshteinDistance(a, b);
    final maxLength = a.length > b.length ? a.length : b.length;
    
    return 1.0 - (distance / maxLength);
  }

  /// Calculate Levenshtein distance between two strings
  static int _levenshteinDistance(String a, String b) {
    final matrix = List.generate(
      a.length + 1, 
      (_) => List<int>.filled(b.length + 1, 0)
    );

    for (int i = 0; i <= a.length; i++) {
      matrix[i][0] = i;
    }

    for (int j = 0; j <= b.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,     // deletion
          matrix[i][j - 1] + 1,     // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[a.length][b.length];
  }

  /// Mock distance calculation (in real app, use actual coordinates)
  static double _calculateMockDistance(PlaceCreationData data, Place existingPlace) {
    // This is a simplified mock - in reality you'd use the haversine formula
    // with actual coordinates from both places
    final nameScore = _calculateStringSimilarity(data.name, existingPlace.name);
    final addressScore = _calculateStringSimilarity(data.address, existingPlace.info.address);
    
    // Mock: closer names and addresses = smaller distance
    final combinedScore = (nameScore + addressScore) / 2;
    return (1 - combinedScore) * 100; // Mock distance in meters
  }

  /// Normalize phone number for comparison
  static String _normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^\d]'), '');
  }

  /// Normalize website URL for comparison
  static String _normalizeWebsite(String website) {
    var normalized = website.toLowerCase();
    
    // Remove protocol
    normalized = normalized.replaceAll(RegExp(r'^https?://'), '');
    
    // Remove www.
    normalized = normalized.replaceAll(RegExp(r'^www\.'), '');
    
    // Remove trailing slash
    normalized = normalized.replaceAll(RegExp(r'/$'), '');
    
    return normalized;
  }

  /// Get confidence level description
  static String getConfidenceDescription(double score) {
    if (score >= _highConfidenceThreshold) {
      return 'Very likely the same place';
    } else if (score >= _mediumConfidenceThreshold) {
      return 'Possibly the same place';
    } else {
      return 'Might be similar';
    }
  }

  /// Get confidence color for UI
  static String getConfidenceColorHex(double score) {
    if (score >= _highConfidenceThreshold) {
      return '#EF4444'; // Red
    } else if (score >= _mediumConfidenceThreshold) {
      return '#F59E0B'; // Amber
    } else {
      return '#6B7280'; // Gray
    }
  }

  /// Check if user should be warned about potential duplicate
  static bool shouldWarnUser(List<DuplicateMatch> matches) {
    return matches.any((match) => match.confidenceScore >= _mediumConfidenceThreshold);
  }

  /// Get the most likely duplicate
  static DuplicateMatch? getMostLikelyDuplicate(List<DuplicateMatch> matches) {
    if (matches.isEmpty) return null;
    return matches.first; // Already sorted by confidence score
  }
}