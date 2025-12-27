import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/request_model.dart';
import 'request_state.dart';

class RequestCubit extends Cubit<RequestState> {
  RequestCubit() : super(const RequestInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _requestsSubscription;

  void getRequests() {
    emit(const RequestLoading());
    
    _requestsSubscription?.cancel();
    _requestsSubscription = _firestore
        .collection('requests')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        final requests = snapshot.docs
            .map((doc) => RequestModel.fromFirestore(doc))
            .toList();
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
      final request = RequestModel(
        id: '',
        type: type,
        area: area,
        description: description,
        status: 'new',
      );
      await _firestore.collection('requests').add(request.toFirestore());
    } catch (e) {
      emit(RequestError('فشل إضافة الطلب: ${e.toString()}'));
    }
  }

  Future<void> takeRequest({
    required String id,
    required String workerName,
  }) async {
    try {
      await _firestore.collection('requests').doc(id).update({
        'status': 'taken',
        'takenBy': workerName,
        'takenAt': FieldValue.serverTimestamp(),
      });
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
      final updateData = <String, dynamic>{'status': status};
      if (takenBy != null) {
        updateData['takenBy'] = takenBy;
      }
      if (status == 'completed') {
        updateData['completedAt'] = FieldValue.serverTimestamp();
      }
      await _firestore.collection('requests').doc(id).update(updateData);
    } catch (e) {
      emit(RequestError('فشل تحديث حالة الطلب: ${e.toString()}'));
    }
  }

  Future<void> deleteRequest(String id) async {
    try {
      await _firestore.collection('requests').doc(id).delete();
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
