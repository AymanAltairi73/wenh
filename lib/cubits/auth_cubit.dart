import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/worker_model.dart';
import '../services/firebase_auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthInitial());

  final FirebaseAuthService _authService = FirebaseAuthService();
  WorkerModel? current;

  Future<void> login(String email, String password) async {
    emit(const AuthLoading());
    try {
      final worker = await _authService.loginWorker(email, password);
      if (worker != null) {
        current = worker;
        emit(Authenticated(worker));
      }
    } catch (e) {
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
    } catch (e) {
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
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(const AuthInitial());
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    current = null;
    emit(const AuthInitial());
  }
}
