// lib/providers/visits_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/visit.dart';

class VisitsProvider extends ChangeNotifier {
  List<Visit> _visits = [];
  
  List<Visit> get visits => _visits;
  
  VisitsProvider() {
    _loadVisits();
  }
  
  // Get visits for a specific place
  List<Visit> getVisitsForPlace(String placeId) {
    return _visits.where((visit) => visit.placeId == placeId).toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Newest first
  }
  
  // Add a new visit
  Future<void> addVisit(Visit visit) async {
    _visits.add(visit);
    await _saveVisits();
    notifyListeners();
  }
  
  // Update an existing visit
  Future<void> updateVisit(Visit updatedVisit) async {
    final index = _visits.indexWhere((visit) => visit.id == updatedVisit.id);
    if (index != -1) {
      _visits[index] = updatedVisit;
      await _saveVisits();
      notifyListeners();
    }
  }
  
  // Delete a visit
  Future<void> deleteVisit(String visitId) async {
    _visits.removeWhere((visit) => visit.id == visitId);
    await _saveVisits();
    notifyListeners();
  }
  
  // Check if a place has been visited
  bool hasVisited(String placeId) {
    return _visits.any((visit) => visit.placeId == placeId);
  }
  
  // Get visit count for a place
  int getVisitCount(String placeId) {
    return _visits.where((visit) => visit.placeId == placeId).length;
  }
  
  // Get last visit date for a place
  DateTime? getLastVisitDate(String placeId) {
    final placeVisits = getVisitsForPlace(placeId);
    return placeVisits.isNotEmpty ? placeVisits.first.date : null;
  }
  
  // Get average rating for a place
  double? getAverageRating(String placeId) {
    final placeVisits = getVisitsForPlace(placeId);
    final ratedVisits = placeVisits.where((visit) => visit.overallRating != null);
    if (ratedVisits.isEmpty) return null;
    
    final totalRating = ratedVisits.fold<double>(0, (sum, visit) => sum + visit.overallRating!);
    return totalRating / ratedVisits.length;
  }
  
  // Load visits from SharedPreferences
  Future<void> _loadVisits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final visitsJson = prefs.getString('visits') ?? '[]';
      final List<dynamic> visitsList = json.decode(visitsJson);
      
      _visits = visitsList
          .map((visitData) => Visit.fromJson(visitData as Map<String, dynamic>))
          .toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading visits: $e');
      _visits = [];
    }
  }
  
  // Save visits to SharedPreferences
  Future<void> _saveVisits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final visitsJson = json.encode(_visits.map((visit) => visit.toJson()).toList());
      await prefs.setString('visits', visitsJson);
    } catch (e) {
      debugPrint('Error saving visits: $e');
    }
  }
  
  // Clear all visits (for testing/reset)
  Future<void> clearAllVisits() async {
    _visits.clear();
    await _saveVisits();
    notifyListeners();
  }
  
  // Get statistics
  Map<String, dynamic> getStatistics() {
    return {
      'totalVisits': _visits.length,
      'uniquePlaces': _visits.map((v) => v.placeId).toSet().length,
      'totalCost': _visits
          .where((v) => v.totalCost != null)
          .fold<double>(0, (sum, v) => sum + v.totalCost!),
      'averageRating': _visits
          .where((v) => v.overallRating != null)
          .isNotEmpty 
          ? _visits
              .where((v) => v.overallRating != null)
              .fold<double>(0, (sum, v) => sum + v.overallRating!) / 
              _visits.where((v) => v.overallRating != null).length
          : null,
    };
  }
}