import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final double? latitude;
  final double? longitude;
  final DateTime? lastLocationUpdate;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.latitude,
    this.longitude,
    this.lastLocationUpdate,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      lastLocationUpdate: map['lastLocationUpdate'] != null
          ? (map['lastLocationUpdate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (lastLocationUpdate != null)
        'lastLocationUpdate': Timestamp.fromDate(lastLocationUpdate!),
    };
  }

  @override
  List<Object?> get props => [
    uid,
    name,
    email,
    phone,
    latitude,
    longitude,
    lastLocationUpdate,
  ];
}
