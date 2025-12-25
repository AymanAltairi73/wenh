import 'package:equatable/equatable.dart';

class RequestDraftModel extends Equatable {
  final String id;
  final String? category;
  final String? subType;
  final String? area;
  final String? description;
  final String? priority;
  final double? budget;
  final String? preferredTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RequestDraftModel({
    required this.id,
    this.category,
    this.subType,
    this.area,
    this.description,
    this.priority,
    this.budget,
    this.preferredTime,
    required this.createdAt,
    required this.updatedAt,
  });

  RequestDraftModel copyWith({
    String? id,
    String? category,
    String? subType,
    String? area,
    String? description,
    String? priority,
    double? budget,
    String? preferredTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RequestDraftModel(
      id: id ?? this.id,
      category: category ?? this.category,
      subType: subType ?? this.subType,
      area: area ?? this.area,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      budget: budget ?? this.budget,
      preferredTime: preferredTime ?? this.preferredTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'subType': subType,
      'area': area,
      'description': description,
      'priority': priority,
      'budget': budget,
      'preferredTime': preferredTime,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory RequestDraftModel.fromJson(Map<String, dynamic> json) {
    return RequestDraftModel(
      id: json['id'] as String,
      category: json['category'] as String?,
      subType: json['subType'] as String?,
      area: json['area'] as String?,
      description: json['description'] as String?,
      priority: json['priority'] as String?,
      budget: json['budget'] as double?,
      preferredTime: json['preferredTime'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  bool get isEmpty =>
      category == null &&
      subType == null &&
      area == null &&
      description == null &&
      priority == null &&
      budget == null &&
      preferredTime == null;

  @override
  List<Object?> get props => [
        id,
        category,
        subType,
        area,
        description,
        priority,
        budget,
        preferredTime,
        createdAt,
        updatedAt,
      ];
}
