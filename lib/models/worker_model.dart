import 'package:equatable/equatable.dart';

class WorkerModel extends Equatable {
  final String name;
  final String email;
  final bool subscription; // active or not
  final DateTime subscriptionEnd;

  const WorkerModel({
    required this.name,
    required this.email,
    required this.subscription,
    required this.subscriptionEnd,
  });

  bool get isSubscriptionActive => subscription && subscriptionEnd.isAfter(DateTime.now());

  @override
  List<Object?> get props => [name, email, subscription, subscriptionEnd];

  static WorkerModel mock() {
    return WorkerModel(
      name: 'Mock Worker',
      email: 'worker@wenh.com',
      subscription: true,
      subscriptionEnd: DateTime.now().add(const Duration(days: 7)),
    );
  }
}
