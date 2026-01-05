import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wenh/core/theme/app_colors.dart';
import '../models/worker_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/auth_storage_service.dart';
import '../services/firestore_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthInitial());

  final FirebaseAuthService _authService = FirebaseAuthService();
  final AuthStorageService _storageService = AuthStorageService();
  final FirestoreService _firestoreService = FirestoreService();
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
              _firestoreService.setCurrentUserId(worker.uid); // Set in FirestoreService
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

  /// Show success message for login
  void _showLoginSuccess(BuildContext context, String userType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          userType == 'worker' 
            ? 'تم تسجيل الدخول بنجاح'
            : 'تم تسجيل الدخول بنجاح',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show success message for registration
  void _showRegistrationSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'تم إنشاء الحساب بنجاح',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
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

  /// Login with phone number and password only
  Future<void> loginWithPhone(
    String phoneNumber,
    String password, {
    bool rememberMe = false,
    required BuildContext context,
  }) async {
    emit(const AuthLoading());
    try {
      // Ensure no existing session conflicts
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.signOut();
      }

      final worker = await _authService.loginWorker(
        phoneNumber,
        password,
      );
      
      if (worker != null) {
        current = worker;
        _firestoreService.setCurrentUserId(worker.uid); // Set in FirestoreService

        // Save Remember Me preference
        await _storageService.setRememberMe(
          value: rememberMe,
          userType: 'worker',
          email: phoneNumber, // Store phone number instead of email
        );

        // Show success message after successful authentication
        _showLoginSuccess(context, 'worker');

        emit(Authenticated(worker));
      } else {
        emit(const AuthError('فشل تسجيل الدخول'));
      }
    } catch (e) {
      debugPrint('[AuthCubit] loginWithPhone error: $e');
      emit(AuthError(e.toString()));
      emit(const AuthInitial());
    }
  }

  /// Register worker with phone number and password only
  Future<void> registerWithPhone({
    required String phoneNumber,
    required String password,
    required String name,
    required BuildContext context,
  }) async {
    emit(const AuthLoading());
    try {
      // Ensure no existing session conflicts
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.signOut();
      }

      await _authService.registerWorker(
        phoneNumber: phoneNumber,
        password: password,
        name: name,
      );
      
      // Auto-login after registration
      await loginWithPhone(phoneNumber, password, context: context);
      
      // Show registration success message
      _showRegistrationSuccess(context);
      
    } catch (e, stackTrace) {
      debugPrint('[AuthCubit] registerWithPhone error: $e');
      debugPrint('[AuthCubit] stackTrace: $stackTrace');
      emit(AuthError(e.toString()));
      emit(const AuthInitial());
    }
  }


  Future<void> logout() async {
    await _authService.logout();
    await _storageService.clearAll(); // Clear Remember Me preference
    current = null;
    _firestoreService.clearCurrentUserId(); // Clear from FirestoreService
    emit(const AuthInitial());
  }
}
