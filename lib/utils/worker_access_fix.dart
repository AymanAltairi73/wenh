import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Worker access fix for requests
class WorkerAccessFix {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;
  bool get isAuthenticated => _auth.currentUser != null;

  /// Fix worker access by creating required documents
  Future<void> fixWorkerAccess() async {
    try {
      if (!isAuthenticated || currentUserId == null) {
        throw Exception('المستخدم غير مصرح له');
      }

      final userId = currentUserId!;
      final user = _auth.currentUser!;
      debugPrint('[WorkerAccessFix] Fixing worker access for: $userId');

      // 1. Create users document
      await _createUserDocument(userId, user);

      // 2. Create worker document
      await _createWorkerDocument(userId, user);

      debugPrint('[WorkerAccessFix] Worker access fixed successfully');
    } catch (e) {
      debugPrint('[WorkerAccessFix] Error: $e');
      throw Exception('فشل في إصلاح وصول العامل: ${e.toString()}');
    }
  }

  Future<void> _createUserDocument(String userId, User user) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        await _firestore.collection('users').doc(userId).set({
          'uid': userId,
          'email': user.email ?? '',
          'name': user.displayName ?? 'عامل',
          'role': 'worker',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        debugPrint('[WorkerAccessFix] Created user document for worker');
      }
    } catch (e) {
      debugPrint('[WorkerAccessFix] Error creating user document: $e');
      rethrow;
    }
  }

  Future<void> _createWorkerDocument(String userId, User user) async {
    try {
      final workerDoc = await _firestore.collection('workers').doc(userId).get();
      
      if (!workerDoc.exists) {
        await _firestore.collection('workers').doc(userId).set({
          'uid': userId,
          'name': user.displayName ?? 'عامل',
          'email': user.email ?? '',
          'subscription': false,
          'subscriptionActive': false,
          'subscriptionPlan': 'none',
          'subscriptionStart': null,
          'subscriptionEnd': null,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'rating': 0.0,
          'totalJobs': 0,
          'completedJobs': 0,
        });
        debugPrint('[WorkerAccessFix] Created worker document');
      }
    } catch (e) {
      debugPrint('[WorkerAccessFix] Error creating worker document: $e');
      rethrow;
    }
  }

  /// Check if worker documents exist
  Future<bool> isWorkerDocumentsExist() async {
    try {
      if (!isAuthenticated) return false;

      final userDoc = await _firestore.collection('users').doc(currentUserId).get();
      final workerDoc = await _firestore.collection('workers').doc(currentUserId).get();

      return userDoc.exists && workerDoc.exists;
    } catch (e) {
      debugPrint('[WorkerAccessFix] Error checking documents: $e');
      return false;
    }
  }

  /// Get worker's requests with proper error handling
  Stream<List<Map<String, dynamic>>> getWorkerRequests() async* {
    if (!isAuthenticated) {
      throw Exception('المستخدم غير مصرح له');
    }

    try {
      // First, ensure worker documents exist
      final documentsExist = await isWorkerDocumentsExist();
      if (!documentsExist) {
        await fixWorkerAccess();
      }

      // Get all requests (worker can see all requests)
      final requestsStream = _firestore
          .collection('requests')
          .orderBy('createdAt', descending: true)
          .snapshots();

      await for (final snapshot in requestsStream) {
        final requests = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                })
            .toList();
        
        debugPrint('[WorkerAccessFix] Fetched ${requests.length} requests');
        yield requests;
      }
    } catch (e) {
      debugPrint('[WorkerAccessFix] Error getting requests: $e');
      throw Exception('فشل في جلب الطلبات: ${e.toString()}');
    }
  }

  /// Get worker's taken requests
  Stream<List<Map<String, dynamic>>> getWorkerTakenRequests() async* {
    if (!isAuthenticated) {
      throw Exception('المستخدم غير مصرح له');
    }

    try {
      // Ensure worker documents exist
      final documentsExist = await isWorkerDocumentsExist();
      if (!documentsExist) {
        await fixWorkerAccess();
      }

      // Get requests taken by this worker
      final requestsStream = _firestore
          .collection('requests')
          .where('takenBy', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .snapshots();

      await for (final snapshot in requestsStream) {
        final requests = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                })
            .toList();
        
        debugPrint('[WorkerAccessFix] Fetched ${requests.length} taken requests');
        yield requests;
      }
    } catch (e) {
      debugPrint('[WorkerAccessFix] Error getting taken requests: $e');
      throw Exception('فشل في جلب الطلبات المستلمة: ${e.toString()}');
    }
  }

  /// Take a request
  Future<void> takeRequest(String requestId) async {
    if (!isAuthenticated) {
      throw Exception('المستخدم غير مصرح له');
    }

    try {
      // Ensure worker documents exist
      final documentsExist = await isWorkerDocumentsExist();
      if (!documentsExist) {
        await fixWorkerAccess();
      }

      // Get worker name
      final workerDoc = await _firestore.collection('workers').doc(currentUserId).get();
      final workerData = workerDoc.data();
      final workerName = workerData?['name'] ?? 'عامل';

      // Update request
      await _firestore.collection('requests').doc(requestId).update({
        'status': 'taken',
        'takenBy': currentUserId,
        'takenByWorkerName': workerName,
        'takenAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('[WorkerAccessFix] Request taken: $requestId');
    } catch (e) {
      debugPrint('[WorkerAccessFix] Error taking request: $e');
      throw Exception('فشل في استلام الطلب: ${e.toString()}');
    }
  }

  /// Update request status
  Future<void> updateRequestStatus(String requestId, String status) async {
    if (!isAuthenticated) {
      throw Exception('المستخدم غير مصرح له');
    }

    try {
      // Ensure worker documents exist
      final documentsExist = await isWorkerDocumentsExist();
      if (!documentsExist) {
        await fixWorkerAccess();
      }

      await _firestore.collection('requests').doc(requestId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('[WorkerAccessFix] Request status updated: $requestId -> $status');
    } catch (e) {
      debugPrint('[WorkerAccessFix] Error updating status: $e');
      throw Exception('فشل في تحديث حالة الطلب: ${e.toString()}');
    }
  }
}
