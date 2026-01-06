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
  final double? latitude;
  final double? longitude;
  final DateTime? lastLocationUpdate;

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
    this.latitude,
    this.longitude,
    this.lastLocationUpdate,
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
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      lastLocationUpdate: map['lastLocationUpdate'] != null
          ? (map['lastLocationUpdate'] as Timestamp).toDate()
          : null,
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
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (lastLocationUpdate != null)
        'lastLocationUpdate': Timestamp.fromDate(lastLocationUpdate!),
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
    latitude,
    longitude,
    lastLocationUpdate,
  ];
}
