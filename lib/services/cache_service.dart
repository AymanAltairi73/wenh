import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// In-memory and persistent cache service
/// Provides intelligent caching with TTL and size limits
class CacheService {
  static CacheService? _instance;
  static CacheService get instance => _instance ??= CacheService._();
  
  CacheService._() : _prefs = null;

  final SharedPreferences? _prefs;
  final Map<String, CacheItem> _memoryCache = {};
  final Map<String, Timer?> _timers = {};
  
  static const int _maxMemoryItems = 100;
  static const Duration _defaultTtl = Duration(minutes: 5);

  /// Get cached item
  T? get<T>(String key) {
    // Check memory cache first
    final memoryItem = _memoryCache[key];
    if (memoryItem != null && !memoryItem.isExpired) {
      return memoryItem.data as T?;
    }

    // Check persistent cache
    final persistentItem = _getPersistentItem(key);
    if (persistentItem != null) {
      // Move to memory cache for faster access
      _memoryCache[key] = persistentItem;
      return persistentItem.data as T?;
    }

    return null;
  }

  /// Set cached item with TTL
  Future<void> set<T>(
    String key, 
    T data, {
    Duration? duration,
    bool persistent = false,
  }) async {
    final ttl = duration ?? _defaultTtl;
    final item = CacheItem<T>(
      data: data,
      expiry: DateTime.now().add(ttl),
      persistent: persistent,
    );

    // Store in memory cache
    _memoryCache[key] = item;
    _manageMemorySize();

    // Set expiry timer
    _timers[key]?.cancel();
    _timers[key] = Timer(ttl, () => remove(key));

    // Store in persistent cache if requested
    if (persistent && _prefs != null) {
      await _setPersistentItem(key, item);
    }
  }

  /// Remove cached item
  void remove(String key) {
    _memoryCache.remove(key);
    _timers[key]?.cancel();
    _timers.remove(key);
    _prefs?.remove(key);
  }

  /// Clear all cached items
  Future<void> clear() async {
    _memoryCache.clear();
    for (final timer in _timers.values) {
      timer?.cancel();
    }
    _timers.clear();
    await _prefs?.clear();
  }

  /// Invalidate items by pattern
  void invalidate(String pattern) {
    final keysToRemove = _memoryCache.keys
        .where((key) => key.contains(pattern))
        .toList();

    for (final key in keysToRemove) {
      remove(key);
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    return {
      'memoryItems': _memoryCache.length,
      'activeTimers': _timers.length,
      'maxMemoryItems': _maxMemoryItems,
    };
  }

  // --- Private Methods ---

  void _manageMemorySize() {
    if (_memoryCache.length <= _maxMemoryItems) return;

    // Remove oldest items
    final sortedItems = _memoryCache.entries.toList()
      ..sort((a, b) => a.value.expiry.compareTo(b.value.expiry));

    final itemsToRemove = sortedItems.take(_memoryCache.length - _maxMemoryItems);
    for (final entry in itemsToRemove) {
      remove(entry.key);
    }
  }

  CacheItem? _getPersistentItem(String key) {
    try {
      final json = _prefs?.getString(key);
      if (json == null) return null;

      final data = jsonDecode(json);
      final item = CacheItem.fromJson(data);
      
      return item.isExpired ? null : item;
    } catch (e) {
      debugPrint('Cache error reading persistent item: $e');
      return null;
    }
  }

  Future<void> _setPersistentItem(String key, CacheItem item) async {
    try {
      final json = jsonEncode(item.toJson());
      await _prefs?.setString(key, json);
    } catch (e) {
      debugPrint('Cache error writing persistent item: $e');
    }
  }
}

/// Cache item with TTL support
class CacheItem<T> {
  final T data;
  final DateTime expiry;
  final bool persistent;

  CacheItem({
    required this.data,
    required this.expiry,
    this.persistent = false,
  });

  bool get isExpired => DateTime.now().isAfter(expiry);

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'expiry': expiry.toIso8601String(),
      'persistent': persistent,
    };
  }

  factory CacheItem.fromJson(Map<String, dynamic> json) {
    return CacheItem(
      data: json['data'],
      expiry: DateTime.parse(json['expiry']),
      persistent: json['persistent'] ?? false,
    );
  }
}
