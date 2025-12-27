import 'package:equatable/equatable.dart';

class WorkerModel extends Equatable {
  final String uid;
  final String name;
  final String email;
  final bool subscription; // active or not
  final DateTime subscriptionEnd;

  const WorkerModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.subscription,
    required this.subscriptionEnd,
  });

  bool get isSubscriptionActive => subscription && subscriptionEnd.isAfter(DateTime.now());

  @override
  List<Object?> get props => [uid, name, email, subscription, subscriptionEnd];
}
