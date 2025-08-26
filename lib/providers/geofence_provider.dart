import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/geofence_service.dart';

class GeofenceProvider with ChangeNotifier {
  final AppGeofenceService _geofenceService = AppGeofenceService();
  
  bool _isEnabled = false;
  bool _isInitialized = false;
  bool _isInitializing = false;
  String? _errorMessage;
  
  static const String _enabledKey = 'geofencing_enabled';

  bool get isEnabled => _isEnabled;
  bool get isInitialized => _isInitialized;
  bool get isInitializing => _isInitializing;
  String? get errorMessage => _errorMessage;
  int get activeGeofencesCount => _geofenceService.activeGeofencesCount;

  Future<void> initialize() async {
    if (_isInitialized || _isInitializing) return;
    
    _isInitializing = true;
    notifyListeners();

    try {
      // Load saved preference
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool(_enabledKey) ?? false;
      
      // Initialize service if enabled
      if (_isEnabled) {
        await _geofenceService.initialize();
        if (_geofenceService.isInitialized) {
          await _geofenceService.enableGeofencing();
        }
      }
      
      _isInitialized = true;
      _errorMessage = null;
      
    } catch (e) {
      _errorMessage = 'Failed to initialize geofencing: ${e.toString()}';
      _isEnabled = false;
      print('GeofenceProvider initialization error: $e');
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> setGeofencingEnabled(bool enabled) async {
    if (_isEnabled == enabled) return;
    
    try {
      if (enabled) {
        // Enable geofencing
        if (!_geofenceService.isInitialized) {
          await _geofenceService.initialize();
        }
        
        if (_geofenceService.isInitialized) {
          await _geofenceService.enableGeofencing();
          _isEnabled = true;
        } else {
          throw Exception('Failed to initialize geofence service');
        }
      } else {
        // Disable geofencing
        await _geofenceService.disableGeofencing();
        _isEnabled = false;
      }
      
      // Save preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_enabledKey, _isEnabled);
      
      _errorMessage = null;
      notifyListeners();
      
    } catch (e) {
      _errorMessage = 'Failed to ${enabled ? 'enable' : 'disable'} geofencing: ${e.toString()}';
      print('GeofenceProvider toggle error: $e');
      notifyListeners();
    }
  }

  Future<void> refreshGeofences() async {
    if (!_isEnabled || !_geofenceService.isInitialized) return;
    
    try {
      // Disable and re-enable to refresh all geofences
      await _geofenceService.disableGeofencing();
      await _geofenceService.enableGeofencing();
      
      _errorMessage = null;
      notifyListeners();
      
    } catch (e) {
      _errorMessage = 'Failed to refresh geofences: ${e.toString()}';
      print('GeofenceProvider refresh error: $e');
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _geofenceService.dispose();
    super.dispose();
  }
}