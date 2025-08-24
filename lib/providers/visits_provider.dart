// lib/providers/visits_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/visit.dart';
import '../services/api_simulation.dart';

class VisitsProvider extends ChangeNotifier {
  List<Visit> _visits = [];
  
  List<Visit> get visits => _visits;
  
  VisitsProvider() {
    _initializeVisits();
  }

  Future<void> _initializeVisits() async {
    await _loadVisits();
    await _loadDummyDataIfNeeded();
  }

  Future<void> _loadDummyDataIfNeeded() async {
    final apiSimulation = ApiSimulation();
    
    if (!(await apiSimulation.isDummyDataInitialized())) {
      final dummyVisits = await apiSimulation.fetchPersonalVisits();
      
      for (final visit in dummyVisits) {
        _visits.add(visit);
      }
      
      await _saveVisits();
      notifyListeners();
      
      debugPrint('VisitsProvider: Loaded ${dummyVisits.length} dummy visits');
    }
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
  
  // Reset dummy data and reload (for development)
  Future<void> resetAndReloadDummyData() async {
    final apiSimulation = ApiSimulation();
    
    // Clear existing data
    _visits.clear();
    await _saveVisits();
    
    // Reset dummy data flag
    await apiSimulation.resetDummyData();
    
    // Reload dummy data
    await _loadDummyDataIfNeeded();
  }
  
  // User ownership and permission methods
  
  // Get visits owned by a specific user
  List<Visit> getUserVisits(String userId) {
    return _visits.where((visit) => visit.userId == userId).toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Newest first
  }
  
  // Get public visits by other users
  List<Visit> getPublicVisitsFromOtherUsers(String currentUserId) {
    return _visits
        .where((visit) => visit.userId != currentUserId && visit.isPublic)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Newest first
  }
  
  // Check if a user can edit a visit
  bool canEditVisit(String visitId, String userId) {
    final visit = _visits.firstWhere(
      (v) => v.id == visitId,
      orElse: () => throw Exception('Visit not found'),
    );
    return visit.userId == userId;
  }
  
  // Check if a user can delete a visit
  bool canDeleteVisit(String visitId, String userId) {
    return canEditVisit(visitId, userId); // Same logic as edit
  }
  
  // Update a visit with ownership check
  Future<bool> updateVisitWithPermissionCheck(Visit updatedVisit, String currentUserId) async {
    if (!canEditVisit(updatedVisit.id, currentUserId)) {
      return false; // Permission denied
    }
    
    await updateVisit(updatedVisit);
    return true;
  }
  
  // Delete a visit with ownership check
  Future<bool> deleteVisitWithPermissionCheck(String visitId, String currentUserId) async {
    if (!canDeleteVisit(visitId, currentUserId)) {
      return false; // Permission denied
    }
    
    await deleteVisit(visitId);
    return true;
  }
  
  // Get visit by ID with ownership info
  Visit? getVisitById(String visitId) {
    try {
      return _visits.firstWhere((visit) => visit.id == visitId);
    } catch (e) {
      return null;
    }
  }
  
  // Get visits for a place with ownership filtering
  List<Visit> getVisitsForPlaceWithOwnership(String placeId, String currentUserId, {bool includePrivate = true}) {
    return _visits.where((visit) {
      if (visit.placeId != placeId) return false;
      
      // Always include user's own visits
      if (visit.userId == currentUserId) return true;
      
      // Include public visits from other users
      if (visit.isPublic) return true;
      
      // Exclude private visits from other users
      return false;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Newest first
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
  
  // Get user-specific statistics
  Map<String, dynamic> getUserStatistics(String userId) {
    final userVisits = getUserVisits(userId);
    return {
      'totalVisits': userVisits.length,
      'uniquePlaces': userVisits.map((v) => v.placeId).toSet().length,
      'totalCost': userVisits
          .where((v) => v.totalCost != null)
          .fold<double>(0, (sum, v) => sum + v.totalCost!),
      'averageRating': userVisits
          .where((v) => v.overallRating != null)
          .isNotEmpty 
          ? userVisits
              .where((v) => v.overallRating != null)
              .fold<double>(0, (sum, v) => sum + v.overallRating!) / 
              userVisits.where((v) => v.overallRating != null).length
          : null,
    };
  }
}