import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wenh/models/admin_model.dart';
import 'package:wenh/services/firebase_service.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  AdminCubit() : super(const AdminInitial());

  AdminModel? currentAdmin;
  StreamSubscription? _adminSubscription;

  Future<void> login(String email, String password) async {
    emit(const AdminLoading());
    try {
      final admin = await LocalStorageService.loginAdmin(email, password);
      if (admin != null && admin.isActive) {
        currentAdmin = admin;
        emit(AdminAuthenticated(admin));
      } else {
        emit(const AdminError('الحساب غير نشط أو غير موجود'));
        emit(const AdminInitial());
      }
    } catch (e) {
      String errorMessage = 'حدث خطأ أثناء تسجيل الدخول';
      if (e.toString().contains('user-not-found')) {
        errorMessage = 'البريد الإلكتروني غير مسجل';
      } else if (e.toString().contains('wrong-password')) {
        errorMessage = 'كلمة المرور غير صحيحة';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'البريد الإلكتروني غير صالح';
      } else if (e.toString().contains('network-request-failed')) {
        errorMessage = 'تحقق من اتصال الإنترنت';
      }
      emit(AdminError(errorMessage));
      emit(const AdminInitial());
    }
  }

  Future<void> createDemoAdmin(String email, String password) async {
    emit(const AdminLoading());
    try {
      await LocalStorageService.createDemoAdmin(email, password);
      await login(email, password);
    } catch (e) {
      String errorMessage = 'فشل إنشاء الحساب التجريبي';
      if (e.toString().contains('email-already-in-use')) {
        errorMessage = 'البريد الإلكتروني مستخدم بالفعل';
      }
      emit(AdminError(errorMessage));
      emit(const AdminInitial());
    }
  }

  Future<void> logout() async {
    await LocalStorageService.logout();
    currentAdmin = null;
    _adminSubscription?.cancel();
    emit(const AdminInitial());
  }

  void loadAdmins() {
    _adminSubscription?.cancel();
    _adminSubscription = LocalStorageService.getAdminsStream().listen(
      (admins) {
        if (state is AdminAuthenticated) {
          emit(AdminsLoaded(admins, (state as AdminAuthenticated).admin));
        }
      },
      onError: (error) {
        emit(AdminError('فشل تحميل قائمة المديرين: ${error.toString()}'));
      },
    );
  }

  Future<void> updateAdmin(AdminModel admin) async {
    try {
      await LocalStorageService.updateAdmin(admin);
      if (currentAdmin?.id == admin.id) {
        currentAdmin = admin;
        emit(AdminAuthenticated(admin));
      }
    } catch (e) {
      emit(AdminError('فشل تحديث بيانات المدير: ${e.toString()}'));
    }
  }

  Future<void> deleteAdmin(String id) async {
    try {
      if (currentAdmin?.id == id) {
        emit(const AdminError('لا يمكنك حذف حسابك الخاص'));
        return;
      }
      await LocalStorageService.deleteAdmin(id);
    } catch (e) {
      emit(AdminError('فشل حذف المدير: ${e.toString()}'));
    }
  }

  Future<void> createAdmin({
    required String email,
    required String password,
    required String name,
    required AdminRole role,
  }) async {
    try {
      if (currentAdmin == null || !currentAdmin!.hasPermission('manage_admins')) {
        emit(const AdminError('ليس لديك صلاحية لإضافة مديرين'));
        return;
      }

      await LocalStorageService.createAdmin(
        email: email,
        password: password,
        name: name,
        role: role,
      );
    } catch (e) {
      String errorMessage = 'فشل إنشاء المدير';
      if (e.toString().contains('email-already-in-use')) {
        errorMessage = 'البريد الإلكتروني مستخدم بالفعل';
      } else if (e.toString().contains('weak-password')) {
        errorMessage = 'كلمة المرور ضعيفة جداً';
      }
      emit(AdminError(errorMessage));
    }
  }

  @override
  Future<void> close() {
    _adminSubscription?.cancel();
    return super.close();
  }
}
