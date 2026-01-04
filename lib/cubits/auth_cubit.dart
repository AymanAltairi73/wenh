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
        // First, check user role from users collection
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();

          if (userDoc.exists) {
            final userData = userDoc.data()!;
            final role = userData['role'] as String?;
            
            if (role == 'worker') {
              // Fetch worker data from workers collection
              final workerDoc = await FirebaseFirestore.instance
                  .collection('workers')
                  .doc(currentUser.uid)
                  .get();

              if (workerDoc.exists) {
                final worker = WorkerModel.fromMap(workerDoc.data()!);
                current = worker;
                emit(Authenticated(worker));
                return;
              }
            } else if (role == 'admin') {
              // Handle admin user
              final adminDoc = await FirebaseFirestore.instance
                  .collection('admins')
                  .doc(currentUser.uid)
                  .get();

              if (adminDoc.exists) {
                final adminData = adminDoc.data()!;
                final worker = WorkerModel(
                  uid: currentUser.uid,
                  name: adminData['name'] ?? 'Admin',
                  email: adminData['email'] ?? currentUser.email ?? '',
                  subscription: true,
                  subscriptionActive: true,
                  subscriptionPlan: 'admin',
                  subscriptionStart: DateTime.now(),
                  subscriptionEnd: DateTime.now().add(const Duration(days: 365)),
                );
                current = worker;
                emit(Authenticated(worker));
                return;
              }
            } else if (role == 'customer') {
              // Handle customer user
              final customerData = userData;
              final worker = WorkerModel(
                uid: currentUser.uid,
                name: customerData['name'] ?? 'Customer',
                email: customerData['email'] ?? currentUser.email ?? '',
                subscription: false,
                subscriptionActive: false,
                subscriptionPlan: 'customer',
                subscriptionStart: DateTime.now(),
                subscriptionEnd: DateTime.now().add(const Duration(days: 365)),
              );
              current = worker;
              emit(Authenticated(worker));
              return;
            }
          }
        } catch (e) {
          debugPrint('[AuthCubit] Error checking user role: $e');
        }

        // Fallback to old logic for backward compatibility
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
    try {
      emit(const AuthLoading());
      
      // Clear all cached data
      await _storageService.clearAll();
      await _authService.logout();
      
      // Clear current user
      current = null;
      
      // Clear Firestore cache
      try {
        await FirebaseFirestore.instance.clearPersistence();
      } catch (e) {
        debugPrint('[AuthCubit] Error clearing Firestore cache: $e');
      }
      
      // Emit initial state
      emit(const AuthInitial());
      
      debugPrint('[AuthCubit] User logged out successfully');
    } catch (e) {
      debugPrint('[AuthCubit] Logout error: $e');
      // Still emit initial state even if there's an error
      emit(const AuthInitial());
    }
  }
}
