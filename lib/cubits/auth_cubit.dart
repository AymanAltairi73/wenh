import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wenh/models/worker_model.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthInitial());

  WorkerModel? current;

  Future<void> login(String email, String password) async {
    emit(const AuthLoading());
    await Future.delayed(const Duration(milliseconds: 400));
    if (email.trim() == 'worker@wenh.com' && password == '123456') {
      current = WorkerModel(
        name: 'عامل تجريبي',
        email: email.trim(),
        subscription: true,
        subscriptionEnd: DateTime.now().add(const Duration(days: 7)),
      );
      emit(Authenticated(current!));
    } else {
      emit(const AuthError('البريد الإلكتروني أو كلمة المرور غير صحيحة'));
      emit(const AuthInitial());
    }
  }

  void logout() {
    current = null;
    emit(const AuthInitial());
  }
}
