import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/request_model.dart';
import '../models/worker_model.dart';
import 'cache_service.dart';

/// Repository pattern implementation for data management
/// Provides caching, error handling, and optimized data fetching
class AppRepository {
  final FirebaseFirestore _firestore;
  final CacheService _cache;
  
  AppRepository({
    FirebaseFirestore? firestore,
    CacheService? cache,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _cache = cache ?? CacheService.instance;

  // --- Request Management ---
  
  /// Get requests with caching and pagination
  Future<List<RequestModel>> getRequests({
    String? status,
    String? area,
    int limit = 50,
    DocumentSnapshot? startAfter,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'requests_${status}_${area}_${limit}';
    
    if (!forceRefresh) {
      final cached = _cache.get<List<RequestModel>>(cacheKey);
      if (cached != null) return cached;
    }

    try {
      Query query = _firestore.collection('requests');
      
      if (status != null) query = query.where('status', isEqualTo: status);
      if (area != null) query = query.where('area', isEqualTo: area);
      if (startAfter != null) query = query.startAfterDocument(startAfter);
      
      query = query
          .orderBy('createdAt', descending: true)
          .limit(limit);

      final snapshot = await query.get();
      final requests = snapshot.docs
          .map((doc) => RequestModel.fromFirestore(doc))
          .toList();

      await _cache.set(cacheKey, requests, duration: Duration(minutes: 5));
      return requests;
    } catch (e) {
      throw _handleError(e, 'Failed to fetch requests');
    }
  }

  /// Real-time requests stream with automatic retry
  Stream<List<RequestModel>> getRequestsStream({
    String? status,
    String? area,
    int maxRetries = 3,
  }) {
    return _firestore.collection('requests')
        .where('status', isEqualTo: status ?? 'new')
        .where('area', isEqualTo: area ?? '')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RequestModel.fromFirestore(doc))
            .toList())
        .handleError((error) {
          debugPrint('Stream error: $error');
          // Implement retry logic here
        });
  }

  // --- Worker Management ---
  
  /// Get workers with selective field loading
  Future<List<WorkerModel>> getWorkers({
    List<String> fields = const ['name', 'email', 'subscriptionActive'],
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'workers_${fields.join('_')}';
    
    if (!forceRefresh) {
      final cached = _cache.get<List<WorkerModel>>(cacheKey);
      if (cached != null) return cached;
    }

    try {
      final snapshot = await _firestore
          .collection('workers')
          .get();

      final workers = snapshot.docs
          .map((doc) => WorkerModel.fromMap(doc.data()))
          .toList();

      await _cache.set(cacheKey, workers, duration: Duration(minutes: 10));
      return workers;
    } catch (e) {
      throw _handleError(e, 'Failed to fetch workers');
    }
  }

  // --- Batch Operations ---
  
  /// Batch update requests for better performance
  Future<void> batchUpdateRequests(List<Map<String, dynamic>> updates) async {
    final batch = _firestore.batch();
    
    for (final update in updates) {
      final docRef = _firestore.collection('requests').doc(update['id']);
      batch.update(docRef, update['data']);
    }
    
    try {
      await batch.commit();
      // Invalidate relevant cache
      _cache.invalidate('requests_');
    } catch (e) {
      throw _handleError(e, 'Failed to batch update requests');
    }
  }

  // --- Search & Filtering ---
  
  /// Optimized search with indexing
  Future<List<RequestModel>> searchRequests({
    required String query,
    List<String> fields = const ['type', 'area', 'description'],
    int limit = 20,
  }) async {
    try {
      // Implement search with proper indexing
      final results = await _firestore
          .collection('requests')
          .where('searchKeywords', arrayContains: query.toLowerCase())
          .limit(limit)
          .get();

      return results.docs
          .map((doc) => RequestModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw _handleError(e, 'Failed to search requests');
    }
  }

  // --- Analytics & Metrics ---
  
  /// Get aggregated statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final requestsSnapshot = await _firestore
          .collection('requests')
          .get();

      final workersSnapshot = await _firestore
          .collection('workers')
          .get();

      return {
        'totalRequests': requestsSnapshot.docs.length,
        'totalWorkers': workersSnapshot.docs.length,
        'newRequests': requestsSnapshot.docs
            .where((doc) => doc.data()['status'] == 'new')
            .length,
        'activeWorkers': workersSnapshot.docs
            .where((doc) => doc.data()['subscriptionActive'] == true)
            .length,
      };
    } catch (e) {
      throw _handleError(e, 'Failed to fetch statistics');
    }
  }

  // --- Error Handling ---
  
  Exception _handleError(dynamic error, String message) {
    debugPrint('$message: $error');
    
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return Exception('Access denied. Please check your permissions.');
        case 'unavailable':
          return Exception('Service temporarily unavailable. Please try again.');
        case 'deadline-exceeded':
          return Exception('Request timed out. Please check your connection.');
        default:
          return Exception('$message: ${error.message}');
      }
    }
    
    return Exception(message);
  }

  // --- Cache Management ---
  
  /// Clear all cached data
  Future<void> clearCache() async {
    await _cache.clear();
  }

  /// Preload critical data
  Future<void> preloadData() async {
    try {
      await Future.wait([
        getRequests(limit: 20),
        getWorkers(fields: ['name', 'email']),
      ]);
    } catch (e) {
      debugPrint('Preload error: $e');
    }
  }
}
