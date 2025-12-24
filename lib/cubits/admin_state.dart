import 'package:equatable/equatable.dart';
import 'package:wenh/models/admin_model.dart';

abstract class AdminState extends Equatable {
  const AdminState();
  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {
  const AdminInitial();
}

class AdminLoading extends AdminState {
  const AdminLoading();
}

class AdminAuthenticated extends AdminState {
  final AdminModel admin;
  const AdminAuthenticated(this.admin);
  @override
  List<Object?> get props => [admin];
}

class AdminsLoaded extends AdminState {
  final List<AdminModel> admins;
  final AdminModel currentAdmin;
  const AdminsLoaded(this.admins, this.currentAdmin);
  @override
  List<Object?> get props => [admins, currentAdmin];
}

class AdminError extends AdminState {
  final String message;
  const AdminError(this.message);
  @override
  List<Object?> get props => [message];
}
