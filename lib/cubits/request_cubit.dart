import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wenh/models/request_model.dart';
import 'request_state.dart';

class RequestCubit extends Cubit<RequestState> {
  RequestCubit() : super(const RequestInitial()) {
    _requests.addAll([
      RequestModel.create(type: '🏗 البناء والتشطيبات - نجّار', area: 'بغداد', description: 'تفصيل وتركيب أبواب داخلية'),
      RequestModel.create(type: '⚡ الكهرباء والطاقة - كهربائي', area: 'أربيل', description: 'تمديدات كهربائية لغرفة مع تركيب إنارة'),
      RequestModel.create(type: '🚿 الماء والتبريد - سبّاك', area: 'البصرة', description: 'تصليح تسريب في حمام وتبديل سيفون'),
    ]);
  }

  final List<RequestModel> _requests = [];

  void getRequests() {
    emit(const RequestLoading());
    emit(RequestLoaded(List.unmodifiable(_requests)));
  }

  void addRequest({required String type, required String area, required String description}) {
    final req = RequestModel.create(type: type, area: area, description: description);
    _requests.add(req);
    emit(RequestLoaded(List.unmodifiable(_requests)));
  }

  void takeRequest({required String id, required String workerName}) {
    final idx = _requests.indexWhere((r) => r.id == id);
    if (idx == -1) {
      emit(const RequestError('Request not found'));
      emit(RequestLoaded(List.unmodifiable(_requests)));
      return;
    }
    final current = _requests[idx];
    if (current.status == 'taken') {
      emit(RequestLoaded(List.unmodifiable(_requests)));
      return;
    }
    _requests[idx] = current.copyWith(status: 'taken', takenBy: workerName);
    emit(RequestLoaded(List.unmodifiable(_requests)));
  }

  void updateStatus({required String id, required String status, String? takenBy}) {
    final idx = _requests.indexWhere((r) => r.id == id);
    if (idx == -1) return;
    final current = _requests[idx];
    _requests[idx] = current.copyWith(status: status, takenBy: takenBy ?? current.takenBy);
    emit(RequestLoaded(List.unmodifiable(_requests)));
  }
}
