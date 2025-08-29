import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  
  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;

  AuthProvider({AuthService? authService}) 
      : _authService = authService ?? MockAuthService();

  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated && _user != null;
  bool get isLoading => _state == AuthState.loading;

  Future<void> initialize() async {
    _setState(AuthState.loading);
    
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _user = user;
        _setState(AuthState.authenticated);
      } else {
        // Auto-login for testing purposes
        final testUser = await _authService.signInWithEmail('user@web.com', '123456');
        if (testUser != null) {
          _user = testUser;
          _setState(AuthState.authenticated);
        } else {
          _setState(AuthState.unauthenticated);
        }
      }
    } catch (e) {
      _setError('Failed to initialize authentication: ${e.toString()}');
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _setState(AuthState.loading);
    
    try {
      final user = await _authService.signInWithEmail(email, password);
      if (user != null) {
        _user = user;
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError('Sign in failed');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> signUpWithEmail(String email, String password, String displayName) async {
    _setState(AuthState.loading);
    
    try {
      final user = await _authService.signUpWithEmail(email, password, displayName);
      if (user != null) {
        _user = user;
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError('Sign up failed');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _setState(AuthState.loading);
    
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        _user = user;
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setState(AuthState.unauthenticated);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> signInWithApple() async {
    _setState(AuthState.loading);
    
    try {
      final user = await _authService.signInWithApple();
      if (user != null) {
        _user = user;
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setState(AuthState.unauthenticated);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    _setState(AuthState.loading);
    
    try {
      await _authService.signOut();
      _user = null;
      _setState(AuthState.unauthenticated);
    } catch (e) {
      _setError('Sign out failed: ${e.toString()}');
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _setState(_user != null ? AuthState.authenticated : AuthState.unauthenticated);
    }
  }

  void _setState(AuthState newState) {
    _state = newState;
    if (newState != AuthState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _setState(AuthState.error);
  }
}