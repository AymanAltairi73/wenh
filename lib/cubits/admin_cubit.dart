import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/auth_storage_service.dart';
import '../services/firestore_service.dart';
import '../core/theme/app_colors.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final FirestoreService _firestoreService;

  AdminCubit({FirestoreService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService(),
      super(const AdminInitial());

  final FirebaseAuthService _authService = FirebaseAuthService();
  final AuthStorageService _storageService = AuthStorageService();
  AdminModel? currentAdmin;
  String? currentUserId;

  // Track if success message has been shown to prevent duplicates
  bool _hasShownSuccessMessage = false;

  /// Reset success message flag (call when navigating to login screens)
  void resetSuccessMessageFlag() {
    _hasShownSuccessMessage = false;
  }

  /// Show success message for admin authentication (login or registration)
  void showAuthSuccess(BuildContext context) {
    if (_hasShownSuccessMessage) return; // Prevent duplicate messages

    _hasShownSuccessMessage = true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'تم تسجيل الدخول بنجاح',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Check admin auth state on startup
  Future<void> checkAuthState() async {
    try {
      final shouldAutoLogin = await _storageService.shouldAutoLogin();
      final currentUser = FirebaseAuth.instance.currentUser;
      final userType = await _storageService.getUserType();

      if (shouldAutoLogin && userType == 'admin') {
        final savedPhone = await _storageService
            .getUserEmail(); // Reads stored phone

        if (savedPhone != null) {
          // 1. Ensure Firebase Auth session exists for RLS
          if (FirebaseAuth.instance.currentUser == null) {
            await FirebaseAuth.instance.signInAnonymously();
          }

          // 2. Fetch admin data by PHONE, not by anonymous UID
          final snapshot = await FirebaseFirestore.instance
              .collection('admins')
              .where('phone', isEqualTo: savedPhone)
              .limit(1)
              .get();

          if (snapshot.docs.isNotEmpty) {
            final doc = snapshot.docs.first;
            final admin = AdminModel.fromJson(doc.data());

            if (admin.isActive) {
              currentAdmin = admin;
              currentUserId = admin.id;
              _firestoreService.setCurrentUserId(admin.id);
              emit(AdminAuthenticated(admin));
              return;
            }
          }
        }
      }
      emit(const AdminInitial());
    } catch (e) {
      debugPrint('[AdminCubit] checkAuthState error: $e');
      emit(const AdminInitial());
    }
  }

  /// Login admin with phone number and password only
  Future<void> loginWithPhone(
    String phoneNumber,
    String password, {
    bool rememberMe = false,
  }) async {
    emit(const AdminLoading());
    try {
      // Ensure no existing session conflicts
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.signOut();
      }

      final admin = await _authService.loginAdmin(phoneNumber, password);

      if (admin != null && admin.isActive) {
        currentAdmin = admin;
        currentUserId = admin.id; // Set currentUserId for FirestoreService
        _firestoreService.setCurrentUserId(admin.id); // Set in FirestoreService

        // Save Remember Me preference
        await _storageService.setRememberMe(
          value: rememberMe,
          userType: 'admin',
          email: phoneNumber, // Store phone number instead of email
        );

        emit(AdminAuthenticated(admin));
      } else {
        emit(const AdminError('فشل تسجيل الدخول'));
      }
    } catch (e) {
      debugPrint('[AdminCubit] loginWithPhone error: $e');
      emit(AdminError(e.toString()));
      emit(const AdminInitial());
    }
  }

  /// Register admin with phone number and password only
  Future<void> registerWithPhone({
    required String phoneNumber,
    required String password,
    required String name,
  }) async {
    emit(const AdminLoading());
    try {
      // Ensure no existing session conflicts
      // if (FirebaseAuth.instance.currentUser != null) {
      //   await FirebaseAuth.instance.signOut();
      // }

      await _authService.registerAdmin(
        phoneNumber: phoneNumber,
        password: password,
        name: name,
      );

      // Auto-login after registration
      await loginWithPhone(phoneNumber, password);
    } catch (e, stackTrace) {
      debugPrint('[AdminCubit] registerWithPhone error: $e');
      debugPrint('[AdminCubit] stackTrace: $stackTrace');
      emit(AdminError(e.toString()));
      emit(const AdminInitial());
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    await _storageService.clearAll();
    currentAdmin = null;
    currentUserId = null;
    _firestoreService.clearCurrentUserId(); // Clear from FirestoreService
    emit(const AdminInitial());
  }
}
