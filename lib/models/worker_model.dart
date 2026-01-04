import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerModel extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final bool subscription; // legacy: maybe keep for compatibility or replace
  final bool subscriptionActive;
  final String subscriptionPlan; // 'weekly' | 'monthly' | 'none'
  final DateTime subscriptionStart;
  final DateTime subscriptionEnd;

  const WorkerModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.subscription,
    required this.subscriptionActive,
    required this.subscriptionPlan,
    required this.subscriptionStart,
    required this.subscriptionEnd,
  });

  factory WorkerModel.fromMap(Map<String, dynamic> map) {
    return WorkerModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      subscription: map['subscription'] ?? false,
      subscriptionActive: map['subscriptionActive'] ?? false,
      subscriptionPlan: map['subscriptionPlan'] ?? 'none',
      subscriptionStart:
          (map['subscriptionStart'] as dynamic)?.toDate() ?? DateTime.now(),
      subscriptionEnd:
          (map['subscriptionEnd'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'subscription': subscription,
      'subscriptionActive': subscriptionActive,
      'subscriptionPlan': subscriptionPlan,
      'subscriptionStart': Timestamp.fromDate(subscriptionStart),
      'subscriptionEnd': Timestamp.fromDate(subscriptionEnd),
    };
  }

  bool get isSubscriptionActive =>
      subscriptionActive && subscriptionEnd.isAfter(DateTime.now());

  @override
  List<Object?> get props => [
    uid,
    name,
    email,
    phone,
    subscription,
    subscriptionActive,
    subscriptionPlan,
    subscriptionStart,
    subscriptionEnd,
  ];
}
