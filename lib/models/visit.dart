// lib/models/visit.dart

import 'visit_activity.dart';

class Visit {
  final String id;
  final DateTime date;
  final String placeId;
  final String placeType; // 'restaurant', 'museum', 'park'
  final double? overallRating; // 1.0 - 5.0
  final String? notes;
  final Duration? duration;
  final double? totalCost;
  final List<VisitActivity> activities;
  final Map<String, dynamic> metadata; // Place-specific data

  const Visit({
    required this.id,
    required this.date,
    required this.placeId,
    required this.placeType,
    this.overallRating,
    this.notes,
    this.duration,
    this.totalCost,
    this.activities = const [],
    this.metadata = const {},
  });

  // Factory constructor for creating visits
  factory Visit.create({
    required DateTime date,
    required String placeId,
    required String placeType,
    double? overallRating,
    String? notes,
    Duration? duration,
    double? totalCost,
    List<VisitActivity>? activities,
    Map<String, dynamic>? metadata,
  }) {
    return Visit(
      id: _generateId(),
      date: date,
      placeId: placeId,
      placeType: placeType,
      overallRating: overallRating,
      notes: notes,
      duration: duration,
      totalCost: totalCost,
      activities: activities ?? [],
      metadata: metadata ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'placeId': placeId,
      'placeType': placeType,
      'overallRating': overallRating,
      'notes': notes,
      'duration': duration?.inMinutes,
      'totalCost': totalCost,
      'activities': activities.map((activity) => activity.toJson()).toList(),
      'metadata': metadata,
    };
  }

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'] ?? '',
      date: DateTime.parse(json['date']),
      placeId: json['placeId'] ?? '',
      placeType: json['placeType'] ?? '',
      overallRating: json['overallRating']?.toDouble(),
      notes: json['notes'],
      duration: json['duration'] != null 
          ? Duration(minutes: json['duration']) 
          : null,
      totalCost: json['totalCost']?.toDouble(),
      activities: (json['activities'] as List<dynamic>?)
          ?.map((activity) => VisitActivityFactory.fromJson(activity as Map<String, dynamic>))
          .toList() ?? [],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Visit copyWith({
    String? id,
    DateTime? date,
    String? placeId,
    String? placeType,
    double? overallRating,
    String? notes,
    Duration? duration,
    double? totalCost,
    List<VisitActivity>? activities,
    Map<String, dynamic>? metadata,
  }) {
    return Visit(
      id: id ?? this.id,
      date: date ?? this.date,
      placeId: placeId ?? this.placeId,
      placeType: placeType ?? this.placeType,
      overallRating: overallRating ?? this.overallRating,
      notes: notes ?? this.notes,
      duration: duration ?? this.duration,
      totalCost: totalCost ?? this.totalCost,
      activities: activities ?? this.activities,
      metadata: metadata ?? this.metadata,
    );
  }

  // Utility methods
  String get formattedDate {
    return '${date.day}.${date.month}.${date.year}';
  }

  String get formattedDuration {
    if (duration == null) return '';
    final hours = duration!.inHours;
    final minutes = duration!.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else {
      return '${minutes}min';
    }
  }

  String get formattedCost {
    if (totalCost == null) return '';
    return '€${totalCost!.toStringAsFixed(2)}';
  }

  bool get hasRating => overallRating != null && overallRating! > 0;

  // Rating validation
  static bool isValidRating(double? rating) {
    return rating != null && rating >= 1.0 && rating <= 5.0;
  }

  // Generate unique ID
  static String _generateId() {
    return 'visit_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(6)}';
  }

  static String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    var result = '';
    for (var i = 0; i < length; i++) {
      result += chars[(random + i) % chars.length];
    }
    return result;
  }
}