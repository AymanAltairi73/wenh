import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/worker_model.dart';
import '../models/admin_model.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  /// Verify phone number and send OTP
  Future<void> verifyPhoneNumber(
    String phoneNumber,
    Function(String) onCodeSent,
    Function(FirebaseAuthException) onError,
  ) async {
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

  /// Sign in worker with phone number and password only
  Future<WorkerModel?> loginWorker(String phoneNumber, String password) async {
    try {
      // Find worker by phone number in Firestore
      final workersSnapshot = await _firestore
          .collection('workers')
          .where('phone', isEqualTo: phoneNumber)
          .get();

      if (workersSnapshot.docs.isEmpty) {
        throw Exception(
          'هذا الرقم غير مسجل كعامل. يرجى إنشاء حساب عامل أولاً.',
        );
      }

      final workerDoc = workersSnapshot.docs.first;
      final data = workerDoc.data();
      final storedPassword = data['password'];

      if (storedPassword != password) {
        throw Exception('كلمة المرور غير صحيحة');
      }

      // Create a custom session without Firebase Auth
      // We'll use the worker's UID as the session identifier
      final workerUid = workerDoc.id;

      // Update last login
      await _firestore.collection('workers').doc(workerUid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return WorkerModel(
        uid: workerUid,
        name: data['name'],
        email: data['email'] ?? '',
        phone: data['phone'] ?? phoneNumber,
        subscription: data['subscription'] ?? false,
        subscriptionActive: data['subscriptionActive'] ?? false,
        subscriptionPlan: data['subscriptionPlan'] ?? 'none',
        subscriptionStart:
            (data['subscriptionStart'] as Timestamp?)?.toDate() ??
            DateTime.now(),
        subscriptionEnd:
            (data['subscriptionEnd'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e) {
      if (e is Exception) throw e;
      throw Exception('فشل تسجيل الدخول: $e');
    }
  }

  /// Sign in admin with phone number and password only
  Future<AdminModel?> loginAdmin(String phoneNumber, String password) async {
    try {
      // Find admin by phone number in Firestore
      final adminsSnapshot = await _firestore
          .collection('admins')
          .where('phone', isEqualTo: phoneNumber)
          .get();

      if (adminsSnapshot.docs.isEmpty) {
        throw Exception(
          'هذا الرقم غير مسجل كمدير. يرجى إنشاء حساب مدير أولاً.',
        );
      }

      final adminDoc = adminsSnapshot.docs.first;
      final data = adminDoc.data();
      final storedPassword = data['password'];

      if (storedPassword != password) {
        throw Exception('كلمة المرور غير صحيحة');
      }

      // Create a custom session without Firebase Auth
      // We'll use the admin's UID as the session identifier
      final adminUid = adminDoc.id;

      // Ensure Firebase Auth session exists for Firestore security rules
      // We use "Shadow Auth": creating a Firebase User with a synthetic email
      // based on the phone number. This satisfies valid auth requirements.
      await _ensureShadowAuth(phoneNumber, password);

      // Update last login
      await _firestore.collection('admins').doc(adminUid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return AdminModel(
        id: adminUid,
        name: data['name'],
        email: data['email'] ?? '',
        phone: data['phone'] ?? phoneNumber,
        role: AdminRole.admin, // Default role
        isActive: data['isActive'] ?? true,
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        permissions: Map<String, bool>.from(data['permissions'] ?? {}),
      );
    } catch (e) {
      if (e is Exception) throw e;
      throw Exception('فشل تسجيل الدخول: $e');
    }
  }

  /// Register worker with phone number and password only
  Future<void> registerWorker({
    required String phoneNumber,
    required String password,
    required String name,
  }) async {
    try {
      // Check if phone number already exists
      final existingWorker = await _firestore
          .collection('workers')
          .where('phone', isEqualTo: phoneNumber)
          .get();

      if (existingWorker.docs.isNotEmpty) {
        throw Exception('رقم الجوال هذا مسجل بالفعل');
      }

      // Generate a unique ID for the worker
      final workerRef = _firestore.collection('workers').doc();
      final workerUid = workerRef.id;

      // Create worker document
      await workerRef.set({
        'uid': workerUid,
        'phone': phoneNumber,
        'password': password, // Store password in Firestore
        'name': name,
        'email': '',
        'role': 'worker',
        'subscription': false,
        'subscriptionActive': false,
        'subscriptionPlan': 'none',
        'subscriptionStart': Timestamp.fromDate(DateTime.now()),
        'subscriptionEnd': Timestamp.fromDate(DateTime.now()),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (e is Exception) throw e;
      throw Exception('فشل إنشاء الحساب: $e');
    }
  }

  /// Register admin with phone number and password only
  Future<void> registerAdmin({
    required String phoneNumber,
    required String password,
    required String name,
  }) async {
    try {
      // Check if phone number already exists
      final existingAdmin = await _firestore
          .collection('admins')
          .where('phone', isEqualTo: phoneNumber)
          .get();

      if (existingAdmin.docs.isNotEmpty) {
        throw Exception('رقم الجوال هذا مسجل بالفعل');
      }

      // Generate a unique ID for the admin
      final adminRef = _firestore.collection('admins').doc();
      final adminUid = adminRef.id;

      // Create admin document
      await adminRef.set({
        'uid': adminUid,
        'phone': phoneNumber,
        'password': password, // Store password in Firestore
        'name': name,
        'email': '',
        'role': 'admin',
        'adminRole': 'AdminRole.admin',
        'isActive': true,
        'permissions': {},
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (e is Exception) throw e;
      throw Exception('فشل إنشاء الحساب: $e');
    }
  }

  /// Helper to ensure a valid Firebase Auth session exists using "Shadow Auth"
  /// Creates or signs in a user with email: admin_<phone>@wenh.com
  Future<void> _ensureShadowAuth(String phone, String password) async {
    // Sanitize phone for email use (remove +, spaces, etc if needed, though usually just appending is fine)
    // We'll just strip the '+' for the email local part to be safe/clean
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    final shadowEmail = 'admin_$cleanPhone@wenh.com';

    if (_auth.currentUser != null) {
      if (_auth.currentUser!.email == shadowEmail) {
        debugPrint(
          '[FirebaseAuthService] Shadow auth already active for $shadowEmail',
        );
        return;
      } else {
        debugPrint(
          '[FirebaseAuthService] Different user logged in (${_auth.currentUser!.email}). Signing out...',
        );
        await _auth.signOut();
      }
    }

    try {
      debugPrint(
        '[FirebaseAuthService] Attempting shadow login for $shadowEmail...',
      );
      await _auth.signInWithEmailAndPassword(
        email: shadowEmail,
        password: password, // Use same password as custom auth
      );
      debugPrint('[FirebaseAuthService] Shadow login successful');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        debugPrint('[FirebaseAuthService] Shadow user not found. Creating...');
        try {
          await _auth.createUserWithEmailAndPassword(
            email: shadowEmail,
            password: password,
          );
          debugPrint(
            '[FirebaseAuthService] Shadow account created successfully',
          );
        } catch (createError) {
          debugPrint(
            '[FirebaseAuthService] Failed to create shadow account: $createError',
          );
          // Re-throw if we can't create the user, as write permissions will likely fail
          throw Exception('فشل إنشاء جلسة أمان (Shadow Auth)');
        }
      } else {
        debugPrint('[FirebaseAuthService] Shadow login failed: ${e.message}');
        // Allow to proceed? Maybe, but risky for permissions.
        // Let's rethrow to be safe, ensuring consistency.
        throw Exception('فشل تسجيل الدخول الأمني: ${e.message}');
      }
    } catch (e) {
      debugPrint('[FirebaseAuthService] Unexpected error in shadow auth: $e');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
