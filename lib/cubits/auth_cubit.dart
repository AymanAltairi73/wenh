import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/worker_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/auth_storage_service.dart';
import '../services/firestore_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthInitial());

  final FirebaseAuthService _authService = FirebaseAuthService();
  final AuthStorageService _storageService = AuthStorageService();
  WorkerModel? current;

  /// Check authentication state on app startup
  Future<void> checkAuthState() async {
    try {
      final shouldAutoLogin = await _storageService.shouldAutoLogin();
      final currentUser = FirebaseAuth.instance.currentUser;

      if (shouldAutoLogin && currentUser != null) {
        // User is authenticated and Remember Me is enabled
        final userType = await _storageService.getUserType();

        if (userType == 'worker') {
          // Fetch worker data from Firestore
          try {
            final doc = await FirebaseFirestore.instance
                .collection('workers')
                .doc(currentUser.uid)
                .get();

            if (doc.exists) {
              final worker = WorkerModel.fromMap(doc.data()!);
              current = worker;
              emit(Authenticated(worker));
              return;
            }
          } catch (e) {
            debugPrint('[AuthCubit] Error fetching worker data: $e');
          }
        }
      }

      emit(const AuthInitial());
    } catch (e) {
      debugPrint('[AuthCubit] checkAuthState error: $e');
      emit(const AuthInitial());
    }
  }

  /// Update worker subscription
  Future<void> updateSubscription(String planType) async {
    if (current == null) return;

    emit(const AuthLoading());
    try {
      final service = FirestoreService();
      await service.updateWorkerSubscription(current!.uid, planType);

      // Refresh user data
      await checkAuthState();
    } catch (e) {
      debugPrint('[AuthCubit] updateSubscription error: $e');
      emit(AuthError(e.toString()));
      if (current != null) emit(Authenticated(current!));
    }
  }

  /// Verify phone number and send OTP
  Future<void> verifyPhoneNumber(String phoneNumber) async {
    emit(const AuthLoading());
    try {
      await _authService.verifyPhoneNumber(
        phoneNumber,
        (verificationId) {
          emit(OtpSent(verificationId));
        },
        (error) {
          emit(AuthError(_handleAuthException(error)));
          emit(const AuthInitial());
        },
      );
    } catch (e) {
      debugPrint('[AuthCubit] verifyPhoneNumber error: $e');
      emit(AuthError(e.toString()));
      emit(const AuthInitial());
    }
  }

  /// Login with phone number, password, and OTP
  Future<void> loginWithPhone(
    String phoneNumber,
    String password,
    String verificationId,
    String smsCode, {
    bool rememberMe = false,
  }) async {
    emit(const AuthLoading());
    try {
      final worker = await _authService.loginWorker(
        phoneNumber,
        password,
        verificationId,
        smsCode,
      );
      if (worker != null) {
        current = worker;

        // Save Remember Me preference
        await _storageService.setRememberMe(
          value: rememberMe,
          userType: 'worker',
          email: phoneNumber, // Store phone number instead of email
        );

        emit(Authenticated(worker));
      }
    } catch (e, stackTrace) {
      debugPrint('[AuthCubit] loginWithPhone error: $e');
      debugPrint('[AuthCubit] stackTrace: $stackTrace');
      emit(AuthError(e.toString()));
      emit(const AuthInitial());
    }
  }


  /// Register worker with phone number and password
  Future<void> registerWithPhone({
    required String phoneNumber,
    required String password,
    required String name,
    required String verificationId,
    required String smsCode,
  }) async {
    emit(const AuthLoading());
    try {
      await _authService.registerWorker(
        phoneNumber: phoneNumber,
        password: password,
        name: name,
        verificationId: verificationId,
        smsCode: smsCode,
      );
      // Auto-login after registration
      await loginWithPhone(phoneNumber, password, verificationId, smsCode);
    } catch (e, stackTrace) {
      debugPrint('[AuthCubit] registerWithPhone error: $e');
      debugPrint('[AuthCubit] stackTrace: $stackTrace');
      emit(AuthError(e.toString()));
      emit(const AuthInitial());
    }
  }

  /// Handle Firebase Auth exceptions
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

  Future<void> logout() async {
    await _authService.logout();
    await _storageService.clearAll(); // Clear Remember Me preference
    current = null;
    emit(const AuthInitial());
  }
}
