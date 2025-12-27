import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/admin_model.dart';
import '../services/firebase_auth_service.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  AdminCubit() : super(const AdminInitial());

  final FirebaseAuthService _authService = FirebaseAuthService();
  AdminModel? currentAdmin;

  Future<void> login(String email, String password) async {
    emit(const AdminLoading());
    try {
      final admin = await _authService.loginAdmin(email, password);
      if (admin != null && admin.isActive) {
        currentAdmin = admin;
        emit(AdminAuthenticated(admin));
      } else {
        emit(const AdminError('الحساب غير نشط أو غير موجود'));
        emit(const AdminInitial());
      }
    } catch (e) {
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
    } catch (e) {
      emit(AdminError(e.toString()));
      emit(const AdminInitial());
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    currentAdmin = null;
    emit(const AdminInitial());
  }
}
