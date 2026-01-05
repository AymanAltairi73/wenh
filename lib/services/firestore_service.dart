import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/request_model.dart';
import '../models/worker_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Stream<List<RequestModel>> getRequests({
    String? status,
    String? area,
    int limit = 50,
  }) {
    try {
      // Ensure user is authenticated
      if (_auth.currentUser == null) {
        throw Exception('يجب تسجيل الدخول لجلب الطلبات');
      }

      Query query = _firestore.collection('requests');

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      if (area != null) {
        query = query.where('area', isEqualTo: area);
      }

      query = query.orderBy('createdAt', descending: true).limit(limit);

      return query.snapshots().map((snapshot) {
        // Handle empty result gracefully
        if (snapshot.docs.isEmpty) {
          return <RequestModel>[];
        }
        
        final requests = <RequestModel>[];
        for (final doc in snapshot.docs) {
          try {
            requests.add(RequestModel.fromFirestore(doc));
          } catch (e) {
            debugPrint('[FirestoreService] Error parsing request: $e');
            // Skip invalid documents but continue processing others
          }
        }
        return requests;
      }).handleError((error) {
        throw _handleFirestoreError(error);
      });
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  Future<RequestModel?> getRequestById(String requestId) async {
    try {
      final doc = await _firestore.collection('requests').doc(requestId).get();

      if (!doc.exists) return null;

      return RequestModel.fromFirestore(doc);
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  Stream<List<RequestModel>> getMyTakenRequests() {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      return _firestore
          .collection('requests')
          .where('takenBy', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => RequestModel.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  Future<String> createRequest(RequestModel request) async {
    try {
      // Ensure user is authenticated
      if (_auth.currentUser == null) {
        throw Exception('يجب تسجيل الدخول لإنشاء طلب');
      }

      // Create request with additional security fields
      final requestData = request.toFirestore();
      requestData['createdBy'] = _auth.currentUser!.uid;
      requestData['createdAt'] = FieldValue.serverTimestamp();
      requestData['status'] = 'new';

      final docRef = await _firestore
          .collection('requests')
          .add(requestData);
      
      debugPrint('[FirestoreService] Request created successfully: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('[FirestoreService] Error creating request: $e');
      throw _handleFirestoreError(e);
    }
  }

  Future<void> takeRequest(String requestId) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _firestore.collection('requests').doc(requestId).update({
        'status': 'taken',
        'takenBy': currentUserId,
        'takenAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  Future<void> updateRequestStatus(
    String requestId,
    String newStatus, {
    String? cancelReason,
  }) async {
    try {
      final updateData = {
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (newStatus == 'completed') {
        updateData['completedAt'] = FieldValue.serverTimestamp();
      } else if (newStatus == 'cancelled') {
        updateData['cancelledAt'] = FieldValue.serverTimestamp();
        if (cancelReason != null) {
          updateData['cancelReason'] = cancelReason;
        }
      }

      await _firestore.collection('requests').doc(requestId).update(updateData);
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  Future<void> deleteRequest(String requestId) async {
    try {
      await _firestore.collection('requests').doc(requestId).delete();
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  // --- Worker Subscription Functions ---

  Future<void> updateWorkerSubscription(
    String workerId,
    String planType,
  ) async {
    try {
      final now = DateTime.now();
      final duration = planType == 'weekly'
          ? const Duration(days: 7)
          : const Duration(days: 30);
      final end = now.add(duration);

      await _firestore.collection('workers').doc(workerId).update({
        'subscriptionPlan': planType,
        'subscriptionStart': Timestamp.fromDate(now),
        'subscriptionEnd': Timestamp.fromDate(end),
        'subscriptionActive': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  // --- Admin Management Functions ---

  Stream<List<WorkerModel>> getAllWorkers() {
    try {
      return _firestore.collection('workers').snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => WorkerModel.fromMap(doc.data()))
            .toList();
      });
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  Future<void> updateWorkerStatus(String workerId, bool isActive) async {
    try {
      await _firestore.collection('workers').doc(workerId).update({
        'subscriptionActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  Future<Map<String, dynamic>> fetchRevenueStats() async {
    try {
      final workers = await _firestore.collection('workers').get();
      int weeklyCount = 0;
      int monthlyCount = 0;

      for (var doc in workers.docs) {
        final data = doc.data();
        if (data['subscriptionActive'] == true) {
          if (data['subscriptionPlan'] == 'weekly') weeklyCount++;
          if (data['subscriptionPlan'] == 'monthly') monthlyCount++;
        }
      }

      // Average prices for calculation
      const weeklyPrice = 7500; // 5-10k range
      const monthlyPrice = 20000; // 15-25k range

      return {
        'totalRevenue':
            (weeklyCount * weeklyPrice) + (monthlyCount * monthlyPrice),
        'weeklyCount': weeklyCount,
        'monthlyCount': monthlyCount,
        'weeklyRevenue': weeklyCount * weeklyPrice,
        'monthlyRevenue': monthlyCount * monthlyPrice,
      };
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  Future<void> addToFavorites(String requestId) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _firestore.collection('favorites').add({
        'userId': currentUserId,
        'requestId': requestId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  Stream<List<String>> getFavoriteRequestIds() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    try {
      return _firestore
          .collection('favorites')
          .where('userId', isEqualTo: currentUserId)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => doc.data()['requestId'] as String)
                .toList();
          });
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  Future<void> removeFromFavorites(String requestId) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final querySnapshot = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: currentUserId)
          .where('requestId', isEqualTo: requestId)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  Future<void> saveDraft(String draftId, Map<String, dynamic> draftData) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _firestore.collection('drafts').doc(draftId).set({
        ...draftData,
        'userId': currentUserId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  Future<Map<String, dynamic>?> getDraft(String draftId) async {
    if (currentUserId == null) {
      return null;
    }

    try {
      final doc = await _firestore.collection('drafts').doc(draftId).get();

      if (!doc.exists) return null;

      final data = doc.data();
      if (data?['userId'] != currentUserId) return null;

      return data;
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  Future<void> deleteDraft(String draftId) async {
    try {
      await _firestore.collection('drafts').doc(draftId).delete();
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? relatedRequestId,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'relatedRequestId': relatedRequestId,
      });
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  Stream<List<Map<String, dynamic>>> getNotifications() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    try {
      return _firestore
          .collection('notifications')
          .where('userId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return {'id': doc.id, ...doc.data()};
            }).toList();
          });
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _firestore.collection('users').doc(currentUserId).update(updates);
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  String _handleFirestoreError(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'ليس لديك صلاحية للوصول إلى هذه البيانات';
        case 'not-found':
          return 'البيانات المطلوبة غير موجودة';
        case 'already-exists':
          return 'البيانات موجودة بالفعل';
        case 'resource-exhausted':
          return 'تم تجاوز الحد المسموح من الطلبات';
        case 'failed-precondition':
          return 'الفهرس المطلوب غير موجود';
        case 'aborted':
          return 'تم إلغاء العملية';
        case 'unavailable':
          return 'الخدمة غير متاحة حالياً';
        case 'unauthenticated':
          return 'يجب تسجيل الدخول أولاً';
        default:
          return 'حدث خطأ: ${error.message}';
      }
    }
    return 'حدث خطأ غير متوقع';
  }
}
