import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Quick fix for admin login issues
class AdminLoginFix {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fix admin login by creating required documents
  Future<void> fixAdminLogin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('المستخدم غير مصرح له');
      }

      final userId = user.uid;
      debugPrint('[AdminLoginFix] Fixing admin login for: $userId');

      // 1. Create users document
      await _createUserDocument(userId, user);

      // 2. Create admin document
      await _createAdminDocument(userId, user);

      debugPrint('[AdminLoginFix] Admin login fixed successfully');
    } catch (e) {
      debugPrint('[AdminLoginFix] Error: $e');
      throw Exception('فشل في إصلاح تسجيل دخول المدير: ${e.toString()}');
    }
  }

  Future<void> _createUserDocument(String userId, User user) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        await _firestore.collection('users').doc(userId).set({
          'uid': userId,
          'email': user.email ?? '',
          'name': user.displayName ?? 'مدير',
          'role': 'admin',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        debugPrint('[AdminLoginFix] Created user document for admin');
      }
    } catch (e) {
      debugPrint('[AdminLoginFix] Error creating user document: $e');
      rethrow;
    }
  }

  Future<void> _createAdminDocument(String userId, User user) async {
    try {
      final adminDoc = await _firestore.collection('admins').doc(userId).get();
      
      if (!adminDoc.exists) {
        await _firestore.collection('admins').doc(userId).set({
          'uid': userId,
          'name': user.displayName ?? 'مدير',
          'email': user.email ?? '',
          'permissions': ['full_access'],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        debugPrint('[AdminLoginFix] Created admin document');
      }
    } catch (e) {
      debugPrint('[AdminLoginFix] Error creating admin document: $e');
      rethrow;
    }
  }

  /// Check if admin documents exist
  Future<bool> isAdminDocumentsExist() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final adminDoc = await _firestore.collection('admins').doc(user.uid).get();

      return userDoc.exists && adminDoc.exists;
    } catch (e) {
      debugPrint('[AdminLoginFix] Error checking documents: $e');
      return false;
    }
  }
}
