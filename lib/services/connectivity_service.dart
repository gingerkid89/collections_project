// lib/services/connectivity_service.dart

import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class ConnectivityService {
  static ConnectivityService? _instance;
  static ConnectivityService get instance => _instance ??= ConnectivityService._();

  ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  final StreamController<ConnectivityStatus> _connectivityController =
      StreamController<ConnectivityStatus>.broadcast();

  ConnectivityStatus _currentStatus = ConnectivityStatus.unknown;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  /// Stream to listen for connectivity changes
  Stream<ConnectivityStatus> get connectivityStream => _connectivityController.stream;

  /// Current connectivity status
  ConnectivityStatus get currentStatus => _currentStatus;

  /// Check if device is currently online
  bool get isOnline => _currentStatus == ConnectivityStatus.online;

  /// Check if device is currently offline
  bool get isOffline => _currentStatus == ConnectivityStatus.offline;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    try {
      // Check initial connectivity
      await _updateConnectivityStatus();

      // Listen for connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
        _updateConnectivityStatus();
      });

      if (AppConfig.enableDetailedLogging) {
        print('🌐 ConnectivityService initialized - Status: $_currentStatus');
      }
    } catch (e) {
      print('❌ ConnectivityService initialization failed: $e');
      _currentStatus = ConnectivityStatus.offline;
    }
  }

  /// Update connectivity status with internet reachability test
  Future<void> _updateConnectivityStatus() async {
    try {
      final ConnectivityResult connectivityResult = await _connectivity.checkConnectivity();

      if (connectivityResult == ConnectivityResult.none) {
        _setStatus(ConnectivityStatus.offline);
        return;
      }

      // Test actual internet connectivity
      final bool hasInternet = await _testInternetConnection();

      if (hasInternet) {
        _setStatus(ConnectivityStatus.online);
      } else {
        _setStatus(ConnectivityStatus.limited);
      }
    } catch (e) {
      if (AppConfig.enableDetailedLogging) {
        print('⚠️ Connectivity check failed: $e');
      }
      _setStatus(ConnectivityStatus.offline);
    }
  }

  /// Test actual internet connectivity by trying to reach our API
  Future<bool> _testInternetConnection() async {
    try {
      // For web platform or local development, assume connectivity is available
      if (kIsWeb || AppConfig.apiBaseUrl.contains('localhost') || AppConfig.apiBaseUrl.contains('10.0.2.2')) {
        if (AppConfig.enableDetailedLogging) {
          print('🌐 Web platform or local development detected, assuming connectivity');
        }
        return true;
      }

      // For mobile platforms, try DNS lookup
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // For production, try to reach the actual API
        final socket = await Socket.connect(
          AppConfig.apiBaseUrl.replaceAll(RegExp(r'https?://'), '').split('/')[0],
          443, // HTTPS port
          timeout: const Duration(seconds: 5),
        );
        socket.destroy();
        return true;
      }
      return false;
    } catch (e) {
      if (AppConfig.enableDetailedLogging) {
        print('🔍 Internet test failed: $e');
      }
      return false;
    }
  }

  /// Set connectivity status and notify listeners
  void _setStatus(ConnectivityStatus status) {
    if (_currentStatus != status) {
      final oldStatus = _currentStatus;
      _currentStatus = status;

      if (AppConfig.enableDetailedLogging) {
        print('🌐 Connectivity changed: $oldStatus → $status');
      }

      _connectivityController.add(status);
    }
  }

  /// Force connectivity check
  Future<ConnectivityStatus> checkConnectivity() async {
    await _updateConnectivityStatus();
    return _currentStatus;
  }

  /// Get connectivity details
  Future<Map<String, dynamic>> getConnectivityDetails() async {
    try {
      final ConnectivityResult result = await _connectivity.checkConnectivity();
      final bool hasInternet = await _testInternetConnection();

      return {
        'type': result.toString().split('.').last,
        'hasInternet': hasInternet,
        'status': _currentStatus.toString().split('.').last,
        'apiReachable': hasInternet,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'type': 'unknown',
        'hasInternet': false,
        'status': 'offline',
        'apiReachable': false,
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Wait for internet connection (useful for retry logic)
  Future<void> waitForConnection({Duration timeout = const Duration(seconds: 30)}) async {
    if (isOnline) return;

    final completer = Completer<void>();
    late StreamSubscription subscription;

    subscription = connectivityStream.listen((status) {
      if (status == ConnectivityStatus.online) {
        subscription.cancel();
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });

    // Set timeout
    Timer(timeout, () {
      subscription.cancel();
      if (!completer.isCompleted) {
        completer.completeError(TimeoutException('Connection timeout', timeout));
      }
    });

    return completer.future;
  }

  /// Dispose connectivity service
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController.close();

    if (AppConfig.enableDetailedLogging) {
      print('🌐 ConnectivityService disposed');
    }
  }
}

/// Connectivity status enum
enum ConnectivityStatus {
  online,     // Full internet connectivity
  limited,    // Network available but no internet
  offline,    // No network connection
  unknown,    // Status not yet determined
}

/// Extension to get user-friendly status descriptions
extension ConnectivityStatusExtension on ConnectivityStatus {
  String get description {
    switch (this) {
      case ConnectivityStatus.online:
        return 'Online';
      case ConnectivityStatus.limited:
        return 'Limited Connection';
      case ConnectivityStatus.offline:
        return 'Offline';
      case ConnectivityStatus.unknown:
        return 'Checking Connection...';
    }
  }

  String get emoji {
    switch (this) {
      case ConnectivityStatus.online:
        return '🟢';
      case ConnectivityStatus.limited:
        return '🟡';
      case ConnectivityStatus.offline:
        return '🔴';
      case ConnectivityStatus.unknown:
        return '⚪';
    }
  }
}