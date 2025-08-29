// lib/providers/visits_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/visit.dart';
import '../services/api_service.dart';

class VisitsProvider extends ChangeNotifier {
  List<Visit> _visits = [];
  bool _isLoading = false;
  String? _error;
  
  List<Visit> get visits => _visits;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  VisitsProvider() {
    _initializeVisits();
  }

  Future<void> _initializeVisits() async {
    await _loadVisitsFromApi();
  }

  Future<void> _loadVisitsFromApi() async {
    _setLoading(true);
    try {
      _visits = await ApiService.getVisits();
      _clearError();
      debugPrint('VisitsProvider: Loaded ${_visits.length} visits from API');
    } catch (e) {
      _setError('Failed to load visits: $e');
      debugPrint('Error loading visits from API: $e');
      // Fallback to local storage
      await _loadVisitsFromLocal();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadVisitsFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final visitsJson = prefs.getString('visits') ?? '[]';
      final List<dynamic> visitsList = json.decode(visitsJson);
      
      _visits = visitsList
          .map((visitData) => Visit.fromJson(visitData as Map<String, dynamic>))
          .toList();
      
      debugPrint('VisitsProvider: Loaded ${_visits.length} visits from local storage');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading visits from local storage: $e');
      _visits = [];
    }
  }
  
  // Get visits for a specific place
  List<Visit> getVisitsForPlace(String placeId) {
    return _visits.where((visit) => visit.placeId == placeId).toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Newest first
  }
  
  // Add a new visit
  Future<void> addVisit(Visit visit) async {
    _setLoading(true);
    try {
      // Create visit via API
      final createdVisit = await ApiService.createVisit(visit);
      _visits.add(createdVisit);
      
      // Also save locally as backup
      await _saveVisitsToLocal();
      _clearError();
      debugPrint('VisitsProvider: Added new visit via API');
    } catch (e) {
      _setError('Failed to create visit: $e');
      debugPrint('Error creating visit via API: $e');
      // Fallback to local only
      _visits.add(visit);
      await _saveVisitsToLocal();
    } finally {
      _setLoading(false);
    }
    notifyListeners();
  }
  
  // Update an existing visit
  Future<void> updateVisit(Visit updatedVisit) async {
    final index = _visits.indexWhere((visit) => visit.id == updatedVisit.id);
    if (index != -1) {
      _visits[index] = updatedVisit;
      await _saveVisitsToLocal();
      notifyListeners();
    }
  }
  
  // Delete a visit
  Future<void> deleteVisit(String visitId) async {
    _visits.removeWhere((visit) => visit.id == visitId);
    await _saveVisitsToLocal();
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
  
  // Refresh visits from API
  Future<void> refreshVisits() async {
    await _loadVisitsFromApi();
  }
  
  // Save visits to local storage (backup)
  Future<void> _saveVisitsToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final visitsJson = json.encode(_visits.map((visit) => visit.toJson()).toList());
      await prefs.setString('visits', visitsJson);
    } catch (e) {
      debugPrint('Error saving visits to local storage: $e');
    }
  }
  
  // Clear all visits (for testing/reset)
  Future<void> clearAllVisits() async {
    _visits.clear();
    await _saveVisitsToLocal();
    notifyListeners();
  }
  
  // Retry loading data after error
  Future<void> retry() async {
    _clearError();
    await _loadVisitsFromApi();
  }
  
  // Helper methods for loading state management
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    notifyListeners();
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