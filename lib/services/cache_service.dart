// lib/services/cache_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../config/app_config.dart';

class CacheService {
  static const String _placesBoxName = 'places_cache';
  static const String _collectionsBoxName = 'collections_cache';
  static const String _visitsBoxName = 'visits_cache';
  static const String _metadataBoxName = 'cache_metadata';
  static const String _imagesBoxName = 'images_cache';

  static const Duration _defaultCacheExpiry = Duration(hours: 6);
  static const Duration _longCacheExpiry = Duration(days: 1);
  static const Duration _shortCacheExpiry = Duration(minutes: 30);

  late Box<String> _placesBox;
  late Box<String> _collectionsBox;
  late Box<String> _visitsBox;
  late Box<String> _metadataBox;
  late Box<Uint8List> _imagesBox;

  static CacheService? _instance;
  static CacheService get instance => _instance ??= CacheService._();

  CacheService._();

  /// Initialize the cache service
  Future<void> initialize() async {
    try {
      await Hive.initFlutter();

      _placesBox = await Hive.openBox<String>(_placesBoxName);
      _collectionsBox = await Hive.openBox<String>(_collectionsBoxName);
      _visitsBox = await Hive.openBox<String>(_visitsBoxName);
      _metadataBox = await Hive.openBox<String>(_metadataBoxName);
      _imagesBox = await Hive.openBox<Uint8List>(_imagesBoxName);

      if (AppConfig.enableDetailedLogging) {
        print('✅ CacheService initialized successfully');
        print('📊 Cache stats: '
            'Places: ${_placesBox.length}, '
            'Collections: ${_collectionsBox.length}, '
            'Visits: ${_visitsBox.length}');
      }
    } catch (e) {
      print('❌ CacheService initialization failed: $e');
    }
  }

  /// Cache places data
  Future<void> cachePlaces(List<Map<String, dynamic>> places, {String? key}) async {
    try {
      final cacheKey = key ?? 'all_places';
      final data = {
        'data': places,
        'timestamp': DateTime.now().toIso8601String(),
        'expiry': DateTime.now().add(_defaultCacheExpiry).toIso8601String(),
      };

      await _placesBox.put(cacheKey, jsonEncode(data));

      if (AppConfig.enableDetailedLogging) {
        print('💾 Cached ${places.length} places with key: $cacheKey');
      }
    } catch (e) {
      print('❌ Failed to cache places: $e');
    }
  }

  /// Get cached places data
  Future<List<Map<String, dynamic>>?> getCachedPlaces({String? key}) async {
    try {
      final cacheKey = key ?? 'all_places';
      final cachedData = _placesBox.get(cacheKey);

      if (cachedData == null) return null;

      final data = jsonDecode(cachedData) as Map<String, dynamic>;
      final expiry = DateTime.parse(data['expiry']);

      if (DateTime.now().isAfter(expiry)) {
        await _placesBox.delete(cacheKey);
        if (AppConfig.enableDetailedLogging) {
          print('🗑️ Expired cache removed for key: $cacheKey');
        }
        return null;
      }

      final places = List<Map<String, dynamic>>.from(data['data']);

      if (AppConfig.enableDetailedLogging) {
        print('📖 Retrieved ${places.length} cached places with key: $cacheKey');
      }

      return places;
    } catch (e) {
      print('❌ Failed to get cached places: $e');
      return null;
    }
  }

  /// Cache collections data
  Future<void> cacheCollections(List<Map<String, dynamic>> collections) async {
    try {
      final data = {
        'data': collections,
        'timestamp': DateTime.now().toIso8601String(),
        'expiry': DateTime.now().add(_longCacheExpiry).toIso8601String(),
      };

      await _collectionsBox.put('all_collections', jsonEncode(data));

      if (AppConfig.enableDetailedLogging) {
        print('💾 Cached ${collections.length} collections');
      }
    } catch (e) {
      print('❌ Failed to cache collections: $e');
    }
  }

  /// Get cached collections data
  Future<List<Map<String, dynamic>>?> getCachedCollections() async {
    try {
      final cachedData = _collectionsBox.get('all_collections');

      if (cachedData == null) return null;

      final data = jsonDecode(cachedData) as Map<String, dynamic>;
      final expiry = DateTime.parse(data['expiry']);

      if (DateTime.now().isAfter(expiry)) {
        await _collectionsBox.delete('all_collections');
        if (AppConfig.enableDetailedLogging) {
          print('🗑️ Expired collections cache removed');
        }
        return null;
      }

      final collections = List<Map<String, dynamic>>.from(data['data']);

      if (AppConfig.enableDetailedLogging) {
        print('📖 Retrieved ${collections.length} cached collections');
      }

      return collections;
    } catch (e) {
      print('❌ Failed to get cached collections: $e');
      return null;
    }
  }

  /// Cache visits data
  Future<void> cacheVisits(List<Map<String, dynamic>> visits, {String? userId}) async {
    try {
      final cacheKey = 'visits_${userId ?? 'default'}';
      final data = {
        'data': visits,
        'timestamp': DateTime.now().toIso8601String(),
        'expiry': DateTime.now().add(_shortCacheExpiry).toIso8601String(),
      };

      await _visitsBox.put(cacheKey, jsonEncode(data));

      if (AppConfig.enableDetailedLogging) {
        print('💾 Cached ${visits.length} visits for user: ${userId ?? 'default'}');
      }
    } catch (e) {
      print('❌ Failed to cache visits: $e');
    }
  }

  /// Get cached visits data
  Future<List<Map<String, dynamic>>?> getCachedVisits({String? userId}) async {
    try {
      final cacheKey = 'visits_${userId ?? 'default'}';
      final cachedData = _visitsBox.get(cacheKey);

      if (cachedData == null) return null;

      final data = jsonDecode(cachedData) as Map<String, dynamic>;
      final expiry = DateTime.parse(data['expiry']);

      if (DateTime.now().isAfter(expiry)) {
        await _visitsBox.delete(cacheKey);
        if (AppConfig.enableDetailedLogging) {
          print('🗑️ Expired visits cache removed for user: ${userId ?? 'default'}');
        }
        return null;
      }

      final visits = List<Map<String, dynamic>>.from(data['data']);

      if (AppConfig.enableDetailedLogging) {
        print('📖 Retrieved ${visits.length} cached visits for user: ${userId ?? 'default'}');
      }

      return visits;
    } catch (e) {
      print('❌ Failed to get cached visits: $e');
      return null;
    }
  }

  /// Cache image data
  Future<void> cacheImage(String url, Uint8List imageData) async {
    try {
      final data = {
        'data': imageData,
        'timestamp': DateTime.now().toIso8601String(),
        'expiry': DateTime.now().add(_longCacheExpiry).toIso8601String(),
      };

      await _imagesBox.put(url, imageData);
      await _metadataBox.put('image_$url', jsonEncode({
        'timestamp': data['timestamp'],
        'expiry': data['expiry'],
      }));

      if (AppConfig.enableDetailedLogging) {
        print('🖼️ Cached image: $url (${imageData.length} bytes)');
      }
    } catch (e) {
      print('❌ Failed to cache image: $e');
    }
  }

  /// Get cached image data
  Future<Uint8List?> getCachedImage(String url) async {
    try {
      final metadataJson = _metadataBox.get('image_$url');
      if (metadataJson == null) return null;

      final metadata = jsonDecode(metadataJson) as Map<String, dynamic>;
      final expiry = DateTime.parse(metadata['expiry']);

      if (DateTime.now().isAfter(expiry)) {
        await _imagesBox.delete(url);
        await _metadataBox.delete('image_$url');
        if (AppConfig.enableDetailedLogging) {
          print('🗑️ Expired image cache removed: $url');
        }
        return null;
      }

      final imageData = _imagesBox.get(url);

      if (AppConfig.enableDetailedLogging && imageData != null) {
        print('🖼️ Retrieved cached image: $url (${imageData.length} bytes)');
      }

      return imageData;
    } catch (e) {
      print('❌ Failed to get cached image: $e');
      return null;
    }
  }

  /// Cache arbitrary data with custom expiry
  Future<void> cacheData(String key, Map<String, dynamic> data, {Duration? expiry}) async {
    try {
      final cacheData = {
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
        'expiry': DateTime.now().add(expiry ?? _defaultCacheExpiry).toIso8601String(),
      };

      await _metadataBox.put(key, jsonEncode(cacheData));

      if (AppConfig.enableDetailedLogging) {
        print('💾 Cached data with key: $key');
      }
    } catch (e) {
      print('❌ Failed to cache data: $e');
    }
  }

  /// Get cached arbitrary data
  Future<Map<String, dynamic>?> getCachedData(String key) async {
    try {
      final cachedData = _metadataBox.get(key);

      if (cachedData == null) return null;

      final data = jsonDecode(cachedData) as Map<String, dynamic>;
      final expiry = DateTime.parse(data['expiry']);

      if (DateTime.now().isAfter(expiry)) {
        await _metadataBox.delete(key);
        if (AppConfig.enableDetailedLogging) {
          print('🗑️ Expired cache removed for key: $key');
        }
        return null;
      }

      if (AppConfig.enableDetailedLogging) {
        print('📖 Retrieved cached data with key: $key');
      }

      return data['data'] as Map<String, dynamic>;
    } catch (e) {
      print('❌ Failed to get cached data: $e');
      return null;
    }
  }

  /// Clear all caches
  Future<void> clearAllCaches() async {
    try {
      await _placesBox.clear();
      await _collectionsBox.clear();
      await _visitsBox.clear();
      await _metadataBox.clear();
      await _imagesBox.clear();

      if (AppConfig.enableDetailedLogging) {
        print('🗑️ All caches cleared');
      }
    } catch (e) {
      print('❌ Failed to clear caches: $e');
    }
  }

  /// Clear expired caches
  Future<void> clearExpiredCaches() async {
    try {
      int removedCount = 0;

      // Clear expired places
      final placesKeys = _placesBox.keys.toList();
      for (final key in placesKeys) {
        final data = _placesBox.get(key);
        if (data != null) {
          try {
            final parsedData = jsonDecode(data) as Map<String, dynamic>;
            final expiry = DateTime.parse(parsedData['expiry']);
            if (DateTime.now().isAfter(expiry)) {
              await _placesBox.delete(key);
              removedCount++;
            }
          } catch (e) {
            await _placesBox.delete(key); // Remove corrupted data
            removedCount++;
          }
        }
      }

      // Clear expired collections
      final collectionsKeys = _collectionsBox.keys.toList();
      for (final key in collectionsKeys) {
        final data = _collectionsBox.get(key);
        if (data != null) {
          try {
            final parsedData = jsonDecode(data) as Map<String, dynamic>;
            final expiry = DateTime.parse(parsedData['expiry']);
            if (DateTime.now().isAfter(expiry)) {
              await _collectionsBox.delete(key);
              removedCount++;
            }
          } catch (e) {
            await _collectionsBox.delete(key);
            removedCount++;
          }
        }
      }

      // Clear expired visits
      final visitsKeys = _visitsBox.keys.toList();
      for (final key in visitsKeys) {
        final data = _visitsBox.get(key);
        if (data != null) {
          try {
            final parsedData = jsonDecode(data) as Map<String, dynamic>;
            final expiry = DateTime.parse(parsedData['expiry']);
            if (DateTime.now().isAfter(expiry)) {
              await _visitsBox.delete(key);
              removedCount++;
            }
          } catch (e) {
            await _visitsBox.delete(key);
            removedCount++;
          }
        }
      }

      // Clear expired images
      final imageMetadataKeys = _metadataBox.keys.where((key) => key.toString().startsWith('image_')).toList();
      for (final key in imageMetadataKeys) {
        final data = _metadataBox.get(key);
        if (data != null) {
          try {
            final parsedData = jsonDecode(data) as Map<String, dynamic>;
            final expiry = DateTime.parse(parsedData['expiry']);
            if (DateTime.now().isAfter(expiry)) {
              final imageKey = key.toString().substring(6); // Remove 'image_' prefix
              await _imagesBox.delete(imageKey);
              await _metadataBox.delete(key);
              removedCount++;
            }
          } catch (e) {
            await _metadataBox.delete(key);
            removedCount++;
          }
        }
      }

      if (AppConfig.enableDetailedLogging) {
        print('🗑️ Cleared $removedCount expired cache entries');
      }
    } catch (e) {
      print('❌ Failed to clear expired caches: $e');
    }
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      // Calculate total size (approximate)
      int totalEntries = _placesBox.length +
                        _collectionsBox.length +
                        _visitsBox.length +
                        _metadataBox.length +
                        _imagesBox.length;

      // Calculate image cache size
      int imageCacheSize = 0;
      for (final imageData in _imagesBox.values) {
        imageCacheSize += imageData.length;
      }

      return {
        'totalEntries': totalEntries,
        'placesCount': _placesBox.length,
        'collectionsCount': _collectionsBox.length,
        'visitsCount': _visitsBox.length,
        'imagesCount': _imagesBox.length,
        'imageCacheSizeMB': (imageCacheSize / (1024 * 1024)).toStringAsFixed(2),
        'lastCleanup': await _getLastCleanupTime(),
      };
    } catch (e) {
      print('❌ Failed to get cache stats: $e');
      return {};
    }
  }

  /// Schedule regular cache cleanup
  Future<void> scheduleCacheCleanup() async {
    final lastCleanup = await _getLastCleanupTime();
    final now = DateTime.now();

    // Clean up every 6 hours
    if (lastCleanup == null || now.difference(lastCleanup).inHours >= 6) {
      await clearExpiredCaches();
      await _setLastCleanupTime(now);
    }
  }

  Future<DateTime?> _getLastCleanupTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getString('last_cache_cleanup');
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }

  Future<void> _setLastCleanupTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_cache_cleanup', time.toIso8601String());
  }

  /// Close all boxes (call when app is disposed)
  Future<void> dispose() async {
    try {
      await _placesBox.close();
      await _collectionsBox.close();
      await _visitsBox.close();
      await _metadataBox.close();
      await _imagesBox.close();

      if (AppConfig.enableDetailedLogging) {
        print('📦 CacheService disposed');
      }
    } catch (e) {
      print('❌ Failed to dispose CacheService: $e');
    }
  }
}