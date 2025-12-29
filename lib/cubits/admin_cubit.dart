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

  Future<void> login(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    emit(const AdminLoading());
    try {
      final admin = await _authService.loginAdmin(email, password);
      if (admin != null && admin.isActive) {
        currentAdmin = admin;

        // Save Remember Me preference
        await _storageService.setRememberMe(
          value: rememberMe,
          userType: 'admin',
          email: email,
        );

        emit(AdminAuthenticated(admin));
      } else {
        emit(const AdminError('الحساب غير نشط أو غير موجود'));
        emit(const AdminInitial());
      }
    } catch (e, stackTrace) {
      debugPrint('[AdminCubit] login error: $e');
      debugPrint('[AdminCubit] stackTrace: $stackTrace');
      emit(AdminError(e.toString()));
      emit(const AdminInitial());
    }
  }

  Future<void> loginWithGoogle() async {
    emit(const AdminLoading());
    try {
      final admin = await _authService.loginAdminWithGoogle();
      if (admin != null && admin.isActive) {
        currentAdmin = admin;
        emit(AdminAuthenticated(admin));
      } else {
        emit(const AdminError('الحساب غير نشط أو غير موجود'));
        emit(const AdminInitial());
      }
    } catch (e, stackTrace) {
      debugPrint('[AdminCubit] loginWithGoogle error: $e');
      debugPrint('[AdminCubit] stackTrace: $stackTrace');
      emit(AdminError(e.toString()));
      emit(const AdminInitial());
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    await _storageService.clearAll();
    currentAdmin = null;
    emit(const AdminInitial());
  }
}
