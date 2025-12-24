import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wenh/models/request_model.dart';
import 'package:wenh/services/firebase_service.dart';
import 'request_state.dart';

class RequestCubit extends Cubit<RequestState> {
  RequestCubit() : super(const RequestInitial());

  StreamSubscription? _requestsSubscription;

  void getRequests() {
    emit(const RequestLoading());
    
    _requestsSubscription?.cancel();
    _requestsSubscription = LocalStorageService.getRequestsStream().listen(
      (requests) {
        emit(RequestLoaded(requests));
      },
      onError: (error) {
        emit(RequestError('فشل تحميل الطلبات: ${error.toString()}'));
      },
    );
  }

  Future<void> addRequest({
    required String type,
    required String area,
    required String description,
  }) async {
    try {
      final req = RequestModel.create(type: type, area: area, description: description);
      await LocalStorageService.addRequest(req);
    } catch (e) {
      emit(RequestError('فشل إضافة الطلب: ${e.toString()}'));
    }
  }

  Future<void> takeRequest({required String id, required String workerName}) async {
    try {
      await LocalStorageService.updateRequestStatus(
        id: id,
        status: 'taken',
        takenBy: workerName,
      );
    } catch (e) {
      emit(RequestError('فشل استلام الطلب: ${e.toString()}'));
    }
  }

  Future<void> updateStatus({
    required String id,
    required String status,
    String? takenBy,
  }) async {
    try {
      await LocalStorageService.updateRequestStatus(
        id: id,
        status: status,
        takenBy: takenBy,
      );
    } catch (e) {
      emit(RequestError('فشل تحديث حالة الطلب: ${e.toString()}'));
    }
  }

  Future<void> deleteRequest(String id) async {
    try {
      await LocalStorageService.deleteRequest(id);
    } catch (e) {
      emit(RequestError('فشل حذف الطلب: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _requestsSubscription?.cancel();
    return super.close();
  }
}
