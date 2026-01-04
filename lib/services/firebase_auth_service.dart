import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/worker_model.dart';
import '../models/admin_model.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  /// Verify phone number and send OTP
  Future<void> verifyPhoneNumber(String phoneNumber, Function(String) onCodeSent, Function(FirebaseAuthException) onError) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-retrieval or instant verification
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: onError,
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle timeout
        },
      );
    } catch (e) {
      throw Exception('فشل إرسال رمز التحقق: $e');
    }
  }

  /// Sign in with phone credential and verify password
  Future<WorkerModel?> loginWorker(String phoneNumber, String password, String verificationId, String smsCode) async {
    try {
      // Create phone credential
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Sign in with phone credential
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      // Verify password from Firestore
      final userDoc = await _firestore
          .collection('workers')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        await _auth.signOut();
        throw Exception('هذا الرقم غير مسجل كعامل. يرجى إنشاء حساب عامل أولاً.');
      }

      final data = userDoc.data()!;
      final storedPassword = data['password'];

      if (storedPassword != password) {
        await _auth.signOut();
        throw Exception('كلمة المرور غير صحيحة');
      }

      if (data['role'] != 'worker') {
        await _auth.signOut();
        throw Exception('هذا الحساب ليس حساب عامل');
      }

      await _firestore.collection('workers').doc(user.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return WorkerModel(
        uid: user.uid,
        name: data['name'],
        email: data['email'] ?? '',
        subscription: data['subscription'] ?? false,
        subscriptionActive: data['subscriptionActive'] ?? false,
        subscriptionPlan: data['subscriptionPlan'] ?? 'none',
        subscriptionStart:
            (data['subscriptionStart'] as Timestamp?)?.toDate() ??
            DateTime.now(),
        subscriptionEnd:
            (data['subscriptionEnd'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign in admin with phone credential and verify password
  Future<AdminModel?> loginAdmin(String phoneNumber, String password, String verificationId, String smsCode) async {
    try {
      // Create phone credential
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Sign in with phone credential
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      // Verify password from Firestore
      final userDoc = await _firestore
          .collection('admins')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        await _auth.signOut();
        throw Exception('هذا الرقم غير مسجل كمدير. يرجى إنشاء حساب مدير أولاً.');
      }

      final data = userDoc.data()!;
      final storedPassword = data['password'];

      if (storedPassword != password) {
        await _auth.signOut();
        throw Exception('كلمة المرور غير صحيحة');
      }

      if (data['role'] != 'admin') {
        await _auth.signOut();
        throw Exception('هذا الحساب ليس حساب مدير');
      }

      await _firestore.collection('admins').doc(user.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return AdminModel.fromJson({
        'id': user.uid,
        'name': data['name'],
        'email': data['email'] ?? '',
        'role': data['adminRole'] ?? 'AdminRole.admin',
        'isActive': data['isActive'] ?? true,
        'createdAt': (data['createdAt'] as Timestamp)
            .toDate()
            .toIso8601String(),
        'lastLogin': DateTime.now().toIso8601String(),
        'permissions': data['permissions'] ?? {},
      });
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Register worker with phone number and password
  Future<void> registerWorker({
    required String phoneNumber,
    required String password,
    required String name,
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      // Create phone credential
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Sign in with phone credential
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      await _firestore.collection('workers').doc(user.uid).set({
        'uid': user.uid,
        'phoneNumber': phoneNumber,
        'password': password, // Store password in Firestore
        'name': name,
        'role': 'worker',
        'subscription': false,
        'subscriptionActive': false,
        'subscriptionPlan': 'none',
        'subscriptionStart': Timestamp.fromDate(DateTime.now()),
        'subscriptionEnd': Timestamp.fromDate(DateTime.now()),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Register admin with phone number and password
  Future<void> registerAdmin({
    required String phoneNumber,
    required String password,
    required String name,
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      // Create phone credential
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Sign in with phone credential
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      await _firestore.collection('admins').doc(user.uid).set({
        'uid': user.uid,
        'phoneNumber': phoneNumber,
        'password': password, // Store password in Firestore
        'name': name,
        'role': 'admin',
        'adminRole': 'AdminRole.admin',
        'isActive': true,
        'permissions': {},
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }


  Future<void> logout() async {
    await _auth.signOut();
  }


  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'رقم الجوال غير صالح';
      case 'user-disabled':
        return 'هذا الحساب معطل';
      case 'user-not-found':
        return 'رقم الجوال غير مسجل';
      case 'session-expired':
        return 'انتهت جلسة رمز التحقق، يرجى إعادة المحاولة';
      case 'quota-exceeded':
        return 'تم تجاوز عدد محاولات التحقق، يرجى المحاولة لاحقاً';
      case 'network-request-failed':
        return 'تحقق من اتصال الإنترنت';
      default:
        return 'حدث خطأ: ${e.message}';
    }
  }
}
