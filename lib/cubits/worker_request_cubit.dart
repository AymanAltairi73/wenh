import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/request_model.dart';
import '../utils/worker_access_fix.dart';
import 'request_state.dart';

/// Enhanced Request Cubit with worker access fix
class WorkerRequestCubit extends Cubit<RequestState> {
  final WorkerAccessFix _workerAccessFix;
  StreamSubscription? _requestsSubscription;

  WorkerRequestCubit({WorkerAccessFix? workerAccessFix})
      : _workerAccessFix = workerAccessFix ?? WorkerAccessFix(),
        super(const RequestInitial());

  /// Get all available requests for workers
  void getAvailableRequests({String? status, String? area}) {
    emit(const RequestLoading());

    try {
      _requestsSubscription?.cancel();
      
      // Use worker access fix to get requests
      _requestsSubscription = _workerAccessFix
          .getWorkerRequests()
          .listen(
            (requests) {
              // Convert to RequestModel objects
              final requestModels = requests
                  .map((data) => _mapToRequestModel(data))
                  .where((model) => model != null)
                  .cast<RequestModel>()
                  .toList();
              
              emit(RequestLoaded(requestModels));
            },
            onError: (error, stackTrace) {
              debugPrint('[WorkerRequestCubit] getAvailableRequests error: $error');
              debugPrint('[WorkerRequestCubit] stackTrace: $stackTrace');
              emit(RequestError(_getErrorMessage(error)));
            },
          );
    } catch (e, stackTrace) {
      debugPrint('[WorkerRequestCubit] getAvailableRequests error: $e');
      debugPrint('[WorkerRequestCubit] stackTrace: $stackTrace');
      emit(RequestError(_getErrorMessage(e)));
    }
  }

  /// Get worker's taken requests
  void getMyTakenRequests() {
    emit(const RequestLoading());

    try {
      _requestsSubscription?.cancel();
      
      _requestsSubscription = _workerAccessFix
          .getWorkerTakenRequests()
          .listen(
            (requests) {
              // Convert to RequestModel objects
              final requestModels = requests
                  .map((data) => _mapToRequestModel(data))
                  .where((model) => model != null)
                  .cast<RequestModel>()
                  .toList();
              
              emit(RequestLoaded(requestModels));
            },
            onError: (error, stackTrace) {
              debugPrint('[WorkerRequestCubit] getMyTakenRequests error: $error');
              debugPrint('[WorkerRequestCubit] stackTrace: $stackTrace');
              emit(RequestError(_getErrorMessage(error)));
            },
          );
    } catch (e, stackTrace) {
      debugPrint('[WorkerRequestCubit] getMyTakenRequests error: $e');
      debugPrint('[WorkerRequestCubit] stackTrace: $stackTrace');
      emit(RequestError(_getErrorMessage(e)));
    }
  }

  /// Take a request
  Future<void> takeRequest(String requestId) async {
    try {
      emit(const RequestLoading());
      
      await _workerAccessFix.takeRequest(requestId);
      
      // Refresh the requests list
      getMyTakenRequests();
    } catch (e) {
      debugPrint('[WorkerRequestCubit] takeRequest error: $e');
      emit(RequestError(_getErrorMessage(e)));
    }
  }

  /// Update request status
  Future<void> updateRequestStatus(String requestId, String status) async {
    try {
      emit(const RequestLoading());
      
      await _workerAccessFix.updateRequestStatus(requestId, status);
      
      // Refresh the requests list
      getMyTakenRequests();
    } catch (e) {
      debugPrint('[WorkerRequestCubit] updateRequestStatus error: $e');
      emit(RequestError(_getErrorMessage(e)));
    }
  }

  /// Fix worker access and refresh
  Future<void> fixWorkerAccessAndRefresh() async {
    try {
      emit(const RequestLoading());
      
      await _workerAccessFix.fixWorkerAccess();
      
      // Refresh the requests list
      getAvailableRequests();
    } catch (e) {
      debugPrint('[WorkerRequestCubit] fixWorkerAccessAndRefresh error: $e');
      emit(RequestError(_getErrorMessage(e)));
    }
  }

  /// Map Firestore data to RequestModel
  RequestModel? _mapToRequestModel(Map<String, dynamic> data) {
    try {
      return RequestModel(
        id: data['id'] as String? ?? '',
        type: data['type'] as String? ?? '',
        area: data['area'] as String? ?? '',
        description: data['description'] as String? ?? '',
        status: data['status'] as String? ?? 'new',
        takenBy: data['takenBy'] as String?,
        timestamp: data['timestamp'] != null 
            ? (data['timestamp'] as Timestamp).toDate()
            : DateTime.now(),
        createdBy: data['createdBy'] as String? ?? 'anonymous',
      );
    } catch (e) {
      debugPrint('[WorkerRequestCubit] Error mapping request: $e');
      return null;
    }
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('permission-denied')) {
      return 'ليس لديك صلاحية للوصول إلى هذه البيانات. يتم إصلاح المشكلة...';
    } else if (error.toString().contains('not-found')) {
      return 'البيانات المطلوبة غير موجودة';
    } else if (error.toString().contains('unauthenticated')) {
      return 'المستخدم غير مصرح له. يرجى تسجيل الدخول';
    } else if (error.toString().contains('unavailable')) {
      return 'الخدمة غير متاحة حالياً. يرجى المحاولة لاحقاً';
    } else {
      return 'حدث خطأ: ${error.toString()}';
    }
  }

  @override
  Future<void> close() {
    _requestsSubscription?.cancel();
    return super.close();
  }
}
