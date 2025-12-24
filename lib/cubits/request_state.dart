import 'package:equatable/equatable.dart';
import 'package:wenh/models/request_model.dart';

abstract class RequestState extends Equatable {
  const RequestState();
  @override
  List<Object?> get props => [];
}

class RequestInitial extends RequestState {
  const RequestInitial();
}

class RequestLoading extends RequestState {
  const RequestLoading();
}

class RequestLoaded extends RequestState {
  final List<RequestModel> requests;
  const RequestLoaded(this.requests);
  @override
  List<Object?> get props => [requests];
}

class RequestError extends RequestState {
  final String message;
  const RequestError(this.message);
  @override
  List<Object?> get props => [message];
}
