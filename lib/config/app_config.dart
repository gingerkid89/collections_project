// lib/config/app_config.dart

import 'package:flutter/foundation.dart';

enum Environment {
  development,
  staging,
  production,
}

class AppConfig {
  static const String _currentEnvironment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');

  static Environment get environment {
    switch (_currentEnvironment.toLowerCase()) {
      case 'production':
        return Environment.production;
      case 'staging':
        return Environment.staging;
      case 'development':
      default:
        return Environment.development;
    }
  }

  // API Configuration
  static String get apiBaseUrl {
    switch (environment) {
      case Environment.development:
        // Use different URLs based on platform
        if (kIsWeb) {
          // Web can use localhost
          return 'http://localhost:3001/api/v1';
        } else {
          // Android emulator needs 10.0.2.2, iOS simulator can use localhost
          if (defaultTargetPlatform == TargetPlatform.android) {
            return 'http://10.0.2.2:3001/api/v1';
          } else {
            return 'http://localhost:3001/api/v1';
          }
        }
      case Environment.staging:
        return 'https://collections-api-production.up.railway.app/api/v1'; // Use production API for staging
      case Environment.production:
        return 'https://collections-api-production.up.railway.app/api/v1';
    }
  }

  // API Timeout Configuration
  static Duration get apiTimeout {
    switch (environment) {
      case Environment.development:
        return const Duration(seconds: 30); // Local development
      case Environment.staging:
        return const Duration(seconds: 60); // Railway with potential cold starts
      case Environment.production:
        return const Duration(seconds: 60); // Railway production with potential cold starts
    }
  }

  // Debug Configuration
  static bool get isDebugMode {
    switch (environment) {
      case Environment.development:
        return true;
      case Environment.staging:
        return true;
      case Environment.production:
        return false;
    }
  }

  // Logging Configuration
  static bool get enableDetailedLogging {
    switch (environment) {
      case Environment.development:
        return true;
      case Environment.staging:
        return true;
      case Environment.production:
        return false;
    }
  }

  // Feature Flags
  static bool get enableExperimentalFeatures {
    switch (environment) {
      case Environment.development:
        return true;
      case Environment.staging:
        return true;
      case Environment.production:
        return false;
    }
  }

  // Analytics Configuration
  static bool get enableAnalytics {
    switch (environment) {
      case Environment.development:
        return false;
      case Environment.staging:
        return false;
      case Environment.production:
        return true;
    }
  }

  // Authentication Configuration
  static String get authServiceType {
    switch (environment) {
      case Environment.development:
        return 'mock'; // Use MockAuthService
      case Environment.staging:
        return 'production'; // Use ProductionAuthService
      case Environment.production:
        return 'production'; // Use ProductionAuthService
    }
  }

  // Database Configuration
  static bool get enableOfflineMode {
    switch (environment) {
      case Environment.development:
        return true;
      case Environment.staging:
        return true;
      case Environment.production:
        return true;
    }
  }

  // Rate Limiting Configuration
  static int get maxApiRequestsPerMinute {
    switch (environment) {
      case Environment.development:
        return 1000; // No limits for development
      case Environment.staging:
        return 100;
      case Environment.production:
        return 60;
    }
  }

  // App Display Configuration
  static String get appDisplayName {
    switch (environment) {
      case Environment.development:
        return 'Collections (Dev)';
      case Environment.staging:
        return 'Collections (Staging)';
      case Environment.production:
        return 'Collections';
    }
  }

  // Environment Info for Debug
  static Map<String, dynamic> get environmentInfo => {
    'environment': _currentEnvironment,
    'apiBaseUrl': apiBaseUrl,
    'isDebugMode': isDebugMode,
    'enableDetailedLogging': enableDetailedLogging,
    'authServiceType': authServiceType,
    'apiTimeout': '${apiTimeout.inSeconds}s',
    'maxApiRequestsPerMinute': maxApiRequestsPerMinute,
  };

  // Helper method to check current environment
  static bool get isDevelopment => environment == Environment.development;
  static bool get isStaging => environment == Environment.staging;
  static bool get isProduction => environment == Environment.production;

  // Version and Build Configuration
  static String get versionSuffix {
    switch (environment) {
      case Environment.development:
        return '-dev';
      case Environment.staging:
        return '-staging';
      case Environment.production:
        return '';
    }
  }
}