import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/auth_storage_service.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  AdminCubit() : super(const AdminInitial());

  final FirebaseAuthService _authService = FirebaseAuthService();
  final AuthStorageService _storageService = AuthStorageService();
  AdminModel? currentAdmin;

  /// Check admin auth state on startup
  Future<void> checkAuthState() async {
    try {
      final shouldAutoLogin = await _storageService.shouldAutoLogin();
      final currentUser = FirebaseAuth.instance.currentUser;
      final userType = await _storageService.getUserType();

      if (shouldAutoLogin && currentUser != null && userType == 'admin') {
        // Fetch admin data from Firestore
        final doc = await FirebaseFirestore.instance
            .collection('admins')
            .doc(currentUser.uid)
            .get();

        if (doc.exists) {
          final admin = AdminModel.fromJson(doc.data()!);
          if (admin.isActive) {
            currentAdmin = admin;
            emit(AdminAuthenticated(admin));
            return;
          }
        }
      }
      emit(const AdminInitial());
    } catch (e) {
      debugPrint('[AdminCubit] checkAuthState error: $e');
      emit(const AdminInitial());
    }
  }

  /// Verify phone number and send OTP for admin
  Future<void> verifyPhoneNumber(String phoneNumber) async {
    emit(const AdminLoading());
    try {
      await _authService.verifyPhoneNumber(
        phoneNumber,
        (verificationId) {
          emit(AdminOtpSent(verificationId));
        },
        (error) {
          emit(AdminError(_handleAuthException(error)));
          emit(const AdminInitial());
        },
      );
    } catch (e) {
      debugPrint('[AdminCubit] verifyPhoneNumber error: $e');
      emit(AdminError(e.toString()));
      emit(const AdminInitial());
    }
  }

  /// Login admin with phone number, password, and OTP
  Future<void> loginWithPhone(
    String phoneNumber,
    String password,
    String verificationId,
    String smsCode, {
    bool rememberMe = false,
  }) async {
    emit(const AdminLoading());
    try {
      final admin = await _authService.loginAdmin(
        phoneNumber,
        password,
        verificationId,
        smsCode,
      );
      if (admin != null && admin.isActive) {
        currentAdmin = admin;

        // Save Remember Me preference
        await _storageService.setRememberMe(
          value: rememberMe,
          userType: 'admin',
          email: phoneNumber, // Store phone number instead of email
        );

        emit(AdminAuthenticated(admin));
      } else {
        emit(const AdminError('الحساب غير نشط أو غير موجود'));
        emit(const AdminInitial());
      }
    } catch (e, stackTrace) {
      debugPrint('[AdminCubit] loginWithPhone error: $e');
      debugPrint('[AdminCubit] stackTrace: $stackTrace');
      emit(AdminError(e.toString()));
      emit(const AdminInitial());
    }
  }


  /// Register admin with phone number and password
  Future<void> registerWithPhone({
    required String phoneNumber,
    required String password,
    required String name,
    required String verificationId,
    required String smsCode,
  }) async {
    emit(const AdminLoading());
    try {
      await _authService.registerAdmin(
        phoneNumber: phoneNumber,
        password: password,
        name: name,
        verificationId: verificationId,
        smsCode: smsCode,
      );
      // Auto-login after registration
      await loginWithPhone(phoneNumber, password, verificationId, smsCode);
    } catch (e, stackTrace) {
      debugPrint('[AdminCubit] registerWithPhone error: $e');
      debugPrint('[AdminCubit] stackTrace: $stackTrace');
      emit(AdminError(e.toString()));
      emit(const AdminInitial());
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
    await _storageService.clearAll();
    currentAdmin = null;
    emit(const AdminInitial());
  }
}
