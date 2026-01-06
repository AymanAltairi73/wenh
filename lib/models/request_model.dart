import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel extends Equatable {
  final String id;
  final String type;
  final String area;
  final String description;
  final String status; // 'new', 'taken', 'completed'
  final String? takenBy;
  final DateTime timestamp;
  final String createdBy; // 'anonymous' or worker_id

  // Location fields for map integration
  final double? latitude;
  final double? longitude;
  final String? address; // Human-readable address

  const RequestModel({
    required this.id,
    required this.type,
    required this.area,
    required this.description,
    required this.status,
    this.takenBy,
    required this.timestamp,
    this.createdBy = 'anonymous',
    this.latitude,
    this.longitude,
    this.address,
  });

  factory RequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RequestModel(
      id: doc.id,
      type: data['type'] ?? '',
      area: data['area'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'new',
      takenBy: data['takenBy'],
      timestamp: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      createdBy: data['createdBy'] ?? 'anonymous',
      latitude: data['latitude'] as double?,
      longitude: data['longitude'] as double?,
      address: data['address'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'area': area,
      'description': description,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
      'createdBy': createdBy,
      'takenBy': takenBy,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }

  RequestModel copyWith({
    String? id,
    String? type,
    String? area,
    String? description,
    String? status,
    String? takenBy,
    DateTime? timestamp,
    String? createdBy,
    double? latitude,
    double? longitude,
    String? address,
  }) {
    return RequestModel(
      id: id ?? this.id,
      type: type ?? this.type,
      area: area ?? this.area,
      description: description ?? this.description,
      status: status ?? this.status,
      takenBy: takenBy ?? this.takenBy,
      timestamp: timestamp ?? this.timestamp,
      createdBy: createdBy ?? this.createdBy,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    area,
    description,
    status,
    takenBy,
    timestamp,
    createdBy,
    latitude,
    longitude,
    address,
  ];
}
