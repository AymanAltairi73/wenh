import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/auth_storage_service.dart';
import '../services/firestore_service.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  AdminCubit() : super(const AdminInitial());

  final FirebaseAuthService _authService = FirebaseAuthService();
  final AuthStorageService _storageService = AuthStorageService();
  final FirestoreService _firestoreService = FirestoreService();
  AdminModel? currentAdmin;
  String? currentUserId;

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
            currentUserId = admin.id; // Set currentUserId for FirestoreService
            _firestoreService.setCurrentUserId(admin.id); // Set in FirestoreService
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

      final admin = await _authService.loginAdmin(
        phoneNumber,
        password,
      );
      
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
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.signOut();
      }

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
