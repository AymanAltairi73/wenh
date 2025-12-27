import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/worker_model.dart';
import '../models/admin_model.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<WorkerModel?> loginWorker(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        await _auth.signOut();
        throw Exception('المستخدم غير موجود');
      }

      final data = userDoc.data()!;

      if (data['role'] != 'worker') {
        await _auth.signOut();
        throw Exception('هذا الحساب ليس حساب عامل');
      }

      await _firestore.collection('users').doc(credential.user!.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return WorkerModel(
        uid: credential.user!.uid,
        name: data['name'],
        email: data['email'],
        subscription: data['subscription'] ?? false,
        subscriptionEnd: (data['subscriptionEnd'] as Timestamp).toDate(),
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<AdminModel?> loginAdmin(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        await _auth.signOut();
        throw Exception('المستخدم غير موجود');
      }

      final data = userDoc.data()!;

      if (data['role'] != 'admin') {
        await _auth.signOut();
        throw Exception('هذا الحساب ليس حساب مدير');
      }

      await _firestore.collection('users').doc(credential.user!.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return AdminModel.fromJson({
        'id': credential.user!.uid,
        'name': data['name'],
        'email': data['email'],
        'role': data['adminRole'] ?? 'AdminRole.admin',
        'isActive': data['isActive'] ?? true,
        'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
        'lastLogin': DateTime.now().toIso8601String(),
        'permissions': data['permissions'] ?? {},
      });
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> registerWorker({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'email': email,
        'name': name,
        'role': 'worker',
        'subscription': false,
        'subscriptionEnd': Timestamp.fromDate(DateTime.now()),
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
      case 'user-not-found':
        return 'البريد الإلكتروني غير مسجل';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'user-disabled':
        return 'هذا الحساب معطل';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      case 'network-request-failed':
        return 'تحقق من اتصال الإنترنت';
      default:
        return 'حدث خطأ: ${e.message}';
    }
  }
}
