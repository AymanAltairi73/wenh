import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel extends Equatable {
  final String id;
  final String type;
  final String area;
  final String description;
  final String status; // 'new' or 'taken'
  final String? takenBy;

  const RequestModel({
    required this.id,
    required this.type,
    required this.area,
    required this.description,
    required this.status,
    this.takenBy,
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
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'area': area,
      'description': description,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': 'anonymous',
      'takenBy': takenBy,
    };
  }

  RequestModel copyWith({
    String? id,
    String? type,
    String? area,
    String? description,
    String? status,
    String? takenBy,
  }) {
    return RequestModel(
      id: id ?? this.id,
      type: type ?? this.type,
      area: area ?? this.area,
      description: description ?? this.description,
      status: status ?? this.status,
      takenBy: takenBy ?? this.takenBy,
    );
  }

  @override
  List<Object?> get props => [id, type, area, description, status, takenBy];
}
