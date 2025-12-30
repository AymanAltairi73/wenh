import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/worker_model.dart';
import '../models/admin_model.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  Future<WorkerModel?> loginWorker(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await _firestore
          .collection('workers')
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

      await _firestore.collection('workers').doc(credential.user!.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return WorkerModel(
        uid: credential.user!.uid,
        name: data['name'],
        email: data['email'],
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

  Future<AdminModel?> loginAdmin(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await _firestore
          .collection('admins')
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

      await _firestore.collection('admins').doc(credential.user!.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return AdminModel.fromJson({
        'id': credential.user!.uid,
        'name': data['name'],
        'email': data['email'],
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

      await _firestore.collection('workers').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'email': email,
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

  Future<WorkerModel?> loginWorkerWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('تم إلغاء تسجيل الدخول');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      final userDoc = await _firestore
          .collection('workers')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        await _firestore.collection('workers').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'name': user.displayName ?? 'مستخدم',
          'role': 'worker',
          'subscription': false,
          'subscriptionActive': false,
          'subscriptionPlan': 'none',
          'subscriptionStart': Timestamp.fromDate(DateTime.now()),
          'subscriptionEnd': Timestamp.fromDate(DateTime.now()),
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });

        return WorkerModel(
          uid: user.uid,
          name: user.displayName ?? 'مستخدم',
          email: user.email!,
          subscription: false,
          subscriptionActive: false,
          subscriptionPlan: 'none',
          subscriptionStart: DateTime.now(),
          subscriptionEnd: DateTime.now(),
        );
      }

      final data = userDoc.data()!;

      if (data['role'] != 'worker') {
        await _auth.signOut();
        await _googleSignIn.signOut();
        throw Exception('هذا الحساب ليس حساب عامل');
      }

      await _firestore.collection('workers').doc(user.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return WorkerModel(
        uid: user.uid,
        name: data['name'],
        email: data['email'],
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
      if (e is FirebaseAuthException) {
        throw _handleAuthException(e);
      }
      rethrow;
    }
  }

  Future<AdminModel?> loginAdminWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('تم إلغاء تسجيل الدخول');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      final userDoc = await _firestore.collection('admins').doc(user.uid).get();

      if (!userDoc.exists) {
        await _auth.signOut();
        await _googleSignIn.signOut();
        throw Exception('المستخدم غير موجود. يجب إنشاء حساب مدير أولاً');
      }

      final data = userDoc.data()!;

      if (data['role'] != 'admin') {
        await _auth.signOut();
        await _googleSignIn.signOut();
        throw Exception('هذا الحساب ليس حساب مدير');
      }

      await _firestore.collection('admins').doc(user.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return AdminModel.fromJson({
        'id': user.uid,
        'name': data['name'],
        'email': data['email'],
        'role': data['adminRole'] ?? 'AdminRole.admin',
        'isActive': data['isActive'] ?? true,
        'createdAt': (data['createdAt'] as Timestamp)
            .toDate()
            .toIso8601String(),
        'lastLogin': DateTime.now().toIso8601String(),
        'permissions': data['permissions'] ?? {},
      });
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw _handleAuthException(e);
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
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
