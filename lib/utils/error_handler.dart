import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      return _handleAuthError(error);
    } else if (error is FirebaseException) {
      return _handleFirestoreError(error);
    } else if (error is NetworkException) {
      return 'تحقق من اتصال الإنترنت';
    } else {
      return 'حدث خطأ غير متوقع';
    }
  }
  
  static String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'البريد الإلكتروني غير مسجل';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'user-disabled':
        return 'هذا الحساب معطل';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً (6 أحرف على الأقل)';
      case 'network-request-failed':
        return 'تحقق من اتصال الإنترنت';
      case 'too-many-requests':
        return 'تم تجاوز عدد المحاولات، حاول لاحقاً';
      case 'operation-not-allowed':
        return 'هذه العملية غير مسموحة';
      case 'invalid-credential':
        return 'بيانات الاعتماد غير صحيحة';
      default:
        return 'خطأ في المصادقة: ${e.message}';
    }
  }
  
  static String _handleFirestoreError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'ليس لديك صلاحية للوصول إلى هذه البيانات';
      case 'not-found':
        return 'البيانات المطلوبة غير موجودة';
      case 'already-exists':
        return 'البيانات موجودة بالفعل';
      case 'resource-exhausted':
        return 'تم تجاوز الحد المسموح من الطلبات';
      case 'failed-precondition':
        return 'الشرط المسبق للعملية غير متحقق';
      case 'aborted':
        return 'تم إلغاء العملية بسبب تعارض';
      case 'unavailable':
        return 'الخدمة غير متاحة حالياً، حاول لاحقاً';
      case 'unauthenticated':
        return 'يجب تسجيل الدخول أولاً';
      case 'deadline-exceeded':
        return 'انتهت مهلة العملية';
      default:
        return 'خطأ في قاعدة البيانات: ${e.message}';
    }
  }
  
  static void showErrorSnackbar(BuildContext context, dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(getErrorMessage(error)),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'حسناً',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
  
  static void showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}
