import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Quick fix for worker access issues
class QuickWorkerFix {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  /// Quick fix for worker login and access
  Future<void> quickFix() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('المستخدم غير مصرح له');
      }

      final userId = user.uid;
      debugPrint('[QuickWorkerFix] Starting quick fix for: $userId');

      // 1. Create users document if not exists
      await _createUserDocument(userId, user);

      // 2. Create worker document if not exists
      await _createWorkerDocument(userId, user);

      // 3. Test access to requests
      await _testRequestsAccess();

      debugPrint('[QuickWorkerFix] Quick fix completed successfully');
    } catch (e) {
      debugPrint('[QuickWorkerFix] Error: $e');
      throw Exception('فشل في الإصلاح السريع: ${e.toString()}');
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
        });
        debugPrint('[QuickWorkerFix] Created user document');
      }
    } catch (e) {
      debugPrint('[QuickWorkerFix] Error creating user document: $e');
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
          'createdAt': FieldValue.serverTimestamp(),
          'rating': 0.0,
          'totalJobs': 0,
          'completedJobs': 0,
        });
        debugPrint('[QuickWorkerFix] Created worker document');
      }
    } catch (e) {
      debugPrint('[QuickWorkerFix] Error creating worker document: $e');
    }
  }

  Future<void> _testRequestsAccess() async {
    try {
      // Test access to requests collection
      final requestsSnapshot = await _firestore
          .collection('requests')
          .limit(5)
          .get();

      debugPrint('[QuickWorkerFix] Successfully accessed ${requestsSnapshot.docs.length} requests');
    } catch (e) {
      debugPrint('[QuickWorkerFix] Error accessing requests: $e');
      rethrow;
    }
  }

  /// Get all requests for worker
  Stream<List<Map<String, dynamic>>> getRequests() async* {
    if (currentUserId == null) {
      throw Exception('المستخدم غير مصرح له');
    }

    try {
      // Ensure documents exist
      await quickFix();

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
        
        debugPrint('[QuickWorkerFix] Fetched ${requests.length} requests');
        yield requests;
      }
    } catch (e) {
      debugPrint('[QuickWorkerFix] Error getting requests: $e');
      throw Exception('فشل في جلب الطلبات: ${e.toString()}');
    }
  }

  /// Get worker's taken requests
  Stream<List<Map<String, dynamic>>> getMyRequests() async* {
    if (currentUserId == null) {
      throw Exception('المستخدم غير مصرح له');
    }

    try {
      // Ensure documents exist
      await quickFix();

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
        
        debugPrint('[QuickWorkerFix] Fetched ${requests.length} my requests');
        yield requests;
      }
    } catch (e) {
      debugPrint('[QuickWorkerFix] Error getting my requests: $e');
      throw Exception('فشل في جلب طلباتي: ${e.toString()}');
    }
  }

  /// Take a request
  Future<void> takeRequest(String requestId) async {
    if (currentUserId == null) {
      throw Exception('المستخدم غير مصرح له');
    }

    try {
      // Get worker name
      final workerDoc = await _firestore.collection('workers').doc(currentUserId).get();
      final workerData = workerDoc.data();
      final workerName = workerData?['name'] ?? 'عامل';

      await _firestore.collection('requests').doc(requestId).update({
        'status': 'taken',
        'takenBy': currentUserId,
        'takenByWorkerName': workerName,
        'takenAt': FieldValue.serverTimestamp(),
      });

      debugPrint('[QuickWorkerFix] Request taken: $requestId');
    } catch (e) {
      debugPrint('[QuickWorkerFix] Error taking request: $e');
      throw Exception('فشل في استلام الطلب: ${e.toString()}');
    }
  }

  /// Update request status
  Future<void> updateRequestStatus(String requestId, String status) async {
    if (currentUserId == null) {
      throw Exception('المستخدم غير مصرح له');
    }

    try {
      await _firestore.collection('requests').doc(requestId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('[QuickWorkerFix] Request status updated: $requestId -> $status');
    } catch (e) {
      debugPrint('[QuickWorkerFix] Error updating status: $e');
      throw Exception('فشل في تحديث الحالة: ${e.toString()}');
    }
  }
}
