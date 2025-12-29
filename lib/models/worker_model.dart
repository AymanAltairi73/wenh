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

  factory WorkerModel.fromMap(Map<String, dynamic> map) {
    return WorkerModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      subscription: map['subscription'] ?? false,
      subscriptionEnd:
          (map['subscriptionEnd'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'subscription': subscription,
      'subscriptionEnd': subscriptionEnd,
    };
  }

  bool get isSubscriptionActive =>
      subscription && subscriptionEnd.isAfter(DateTime.now());

  @override
  List<Object?> get props => [uid, name, email, subscription, subscriptionEnd];
}
