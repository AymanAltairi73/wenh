import 'package:equatable/equatable.dart';

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

  static RequestModel create({
    required String type,
    required String area,
    required String description,
  }) {
    return RequestModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      area: area,
      description: description,
      status: 'new',
    );
  }

  @override
  List<Object?> get props => [id, type, area, description, status, takenBy];
}
