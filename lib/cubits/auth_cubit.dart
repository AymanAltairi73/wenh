import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/worker_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/auth_storage_service.dart';
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
        // Add other user types (admin, customer) here if needed
      }

      // Not authenticated or Remember Me disabled
      emit(const AuthInitial());
    } catch (e) {
      debugPrint('[AuthCubit] checkAuthState error: $e');
      emit(const AuthInitial());
    }
  }

  /// Login with email and password
  Future<void> login(
    String email,
    String password, {
    bool rememberMe = false,
    String userType = 'worker',
  }) async {
    emit(const AuthLoading());
    try {
      final worker = await _authService.loginWorker(email, password);
      if (worker != null) {
        current = worker;

        // Save Remember Me preference
        await _storageService.setRememberMe(
          value: rememberMe,
          userType: userType,
          email: email,
        );

        emit(Authenticated(worker));
      }
    } catch (e, stackTrace) {
      debugPrint('[AuthCubit] login error: $e');
      debugPrint('[AuthCubit] stackTrace: $stackTrace');
      emit(AuthError(e.toString()));
      emit(const AuthInitial());
    }
  }

  Future<void> loginWithGoogle() async {
    emit(const AuthLoading());
    try {
      final worker = await _authService.loginWorkerWithGoogle();
      if (worker != null) {
        current = worker;
        emit(Authenticated(worker));
      }
    } catch (e, stackTrace) {
      debugPrint('[AuthCubit] loginWithGoogle error: $e');
      debugPrint('[AuthCubit] stackTrace: $stackTrace');
      emit(AuthError(e.toString()));
      emit(const AuthInitial());
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    emit(const AuthLoading());
    try {
      await _authService.registerWorker(
        email: email,
        password: password,
        name: name,
      );
      await login(email, password);
    } catch (e, stackTrace) {
      debugPrint('[AuthCubit] register error: $e');
      debugPrint('[AuthCubit] stackTrace: $stackTrace');
      emit(AuthError(e.toString()));
      emit(const AuthInitial());
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    await _storageService.clearAll(); // Clear Remember Me preference
    current = null;
    emit(const AuthInitial());
  }
}
