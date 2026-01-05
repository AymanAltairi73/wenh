import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/request_model.dart';
import '../services/firestore_service.dart';
import 'request_state.dart';

class RequestCubit extends Cubit<RequestState> {
  final FirestoreService _firestoreService;
  FirestoreService get firestoreService => _firestoreService;
  StreamSubscription? _requestsSubscription;

  RequestCubit({FirestoreService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService(),
      super(const RequestInitial());

  void getRequests({String? status, String? area}) {
    emit(const RequestLoading());

    try {
      _requestsSubscription?.cancel();
      _requestsSubscription = _firestoreService
          .getRequests(status: status, area: area)
          .listen(
            (requests) {
              emit(RequestLoaded(requests));
            },
            onError: (error, stackTrace) {
              debugPrint('[RequestCubit] getRequests error: $error');
              debugPrint('[RequestCubit] stackTrace: $stackTrace');
              emit(RequestError(_getErrorMessage(error)));
            },
          );
    } catch (e, stackTrace) {
      debugPrint('[RequestCubit] getRequests error: $e');
      debugPrint('[RequestCubit] stackTrace: $stackTrace');
      emit(RequestError(_getErrorMessage(e)));
    }
  }

  Future<void> addRequest({
    required String type,
    required String area,
    required String description,
  }) async {
    try {
      final request = RequestModel(
        id: '',
        type: type,
        area: area,
        description: description,
        status: 'new',
        timestamp: DateTime.now(),
        createdBy: 'anonymous',
      );

      await _firestoreService.createRequest(request);
    } catch (e, stackTrace) {
      debugPrint('[RequestCubit] addRequest error: $e');
      debugPrint('[RequestCubit] stackTrace: $stackTrace');
      emit(RequestError(_getErrorMessage(e)));
    }
  }

  Future<void> takeRequest({
    required String id,
    required String workerName,
    required bool isSubscribed,
  }) async {
    if (!isSubscribed) {
      emit(const RequestError('يجب أن يكون لديك اشتراك نشط لاستلام الطلبات'));
      return;
    }
    try {
      await _firestoreService.takeRequest(id);
    } catch (e, stackTrace) {
      debugPrint('[RequestCubit] takeRequest error: $e');
      debugPrint('[RequestCubit] stackTrace: $stackTrace');
      emit(RequestError(_getErrorMessage(e)));
    }
  }

  Future<void> updateStatus({
    required String id,
    required String status,
    String? cancelReason,
  }) async {
    try {
      await _firestoreService.updateRequestStatus(
        id,
        status,
        cancelReason: cancelReason,
      );
    } catch (e, stackTrace) {
      debugPrint('[RequestCubit] updateStatus error: $e');
      debugPrint('[RequestCubit] stackTrace: $stackTrace');
      emit(RequestError(_getErrorMessage(e)));
    }
  }

  Future<void> deleteRequest(String id) async {
    try {
      await _firestoreService.deleteRequest(id);
    } catch (e, stackTrace) {
      debugPrint('[RequestCubit] deleteRequest error: $e');
      debugPrint('[RequestCubit] stackTrace: $stackTrace');
      emit(RequestError(_getErrorMessage(e)));
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is String) {
      return error;
    }

    final errorString = error.toString().toLowerCase();

    if (errorString.contains('permission')) {
      return 'ليس لديك صلاحية للوصول إلى هذه البيانات';
    } else if (errorString.contains('network')) {
      return 'تحقق من اتصالك بالإنترنت';
    } else if (errorString.contains('not found')) {
      return 'البيانات المطلوبة غير موجودة';
    } else if (errorString.contains('timeout')) {
      return 'انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى';
    } else {
      return 'حدث خطأ غير متوقع: ${error.toString()}';
    }
  }

  @override
  Future<void> close() {
    _requestsSubscription?.cancel();
    return super.close();
  }
}
