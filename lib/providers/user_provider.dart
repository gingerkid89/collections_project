// lib/providers/user_provider.dart

import 'package:flutter/foundation.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get currentUserId => _currentUser?.id;

  // Mock authentication - in a real app, this would connect to Firebase Auth, etc.
  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Mock user data - in reality this would come from your auth service
      _currentUser = User(
        id: 'user_123', // This would come from the auth service
        name: 'Current User',
        email: email,
        avatarUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastActiveAt: DateTime.now(),
      );
      
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Mock sign up
  Future<void> signUp(String name, String email, String password) async {
    _setLoading(true);
    
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      
      _currentUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        avatarUrl: null,
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
      );
      
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Auto-login (simulate checking for stored auth tokens)
  Future<void> tryAutoLogin() async {
    _setLoading(true);
    
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      // In a real app, check for stored tokens, validate them, etc.
      // For now, just auto-login with a mock user
      _currentUser = User(
        id: 'user_123',
        name: 'Current User',
        email: 'user@example.com',
        avatarUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastActiveAt: DateTime.now(),
      );
      
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      // Auto-login failed, user needs to sign in manually
      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? name,
    String? email,
    String? avatarUrl,
  }) async {
    if (_currentUser == null) return;
    
    _setLoading(true);
    
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      _currentUser = _currentUser!.copyWith(
        name: name,
        email: email,
        avatarUrl: avatarUrl,
        lastActiveAt: DateTime.now(),
      );
      
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Helper method to update loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Check if a visit belongs to the current user
  bool isCurrentUserVisit(String visitUserId) {
    return _currentUser?.id == visitUserId;
  }

  // Get display name for current user
  String get displayName {
    return _currentUser?.name ?? 'User';
  }

  // Get user initials for avatar fallback
  String get initials {
    final name = _currentUser?.name ?? '';
    final parts = name.split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'.toUpperCase();
  }
}