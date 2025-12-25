import 'package:equatable/equatable.dart';

class FavoriteRequestModel extends Equatable {
  final String id;
  final String category;
  final String subType;
  final String area;
  final String description;
  final String? priority;
  final double? budget;
  final String? preferredTime;
  final String? locationLatitude;
  final String? locationLongitude;
  final DateTime createdAt;
  final DateTime savedAt;

  const FavoriteRequestModel({
    required this.id,
    required this.category,
    required this.subType,
    required this.area,
    required this.description,
    this.priority,
    this.budget,
    this.preferredTime,
    this.locationLatitude,
    this.locationLongitude,
    required this.createdAt,
    required this.savedAt,
  });

  FavoriteRequestModel copyWith({
    String? id,
    String? category,
    String? subType,
    String? area,
    String? description,
    String? priority,
    double? budget,
    String? preferredTime,
    String? locationLatitude,
    String? locationLongitude,
    DateTime? createdAt,
    DateTime? savedAt,
  }) {
    return FavoriteRequestModel(
      id: id ?? this.id,
      category: category ?? this.category,
      subType: subType ?? this.subType,
      area: area ?? this.area,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      budget: budget ?? this.budget,
      preferredTime: preferredTime ?? this.preferredTime,
      locationLatitude: locationLatitude ?? this.locationLatitude,
      locationLongitude: locationLongitude ?? this.locationLongitude,
      createdAt: createdAt ?? this.createdAt,
      savedAt: savedAt ?? this.savedAt,
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
      'locationLatitude': locationLatitude,
      'locationLongitude': locationLongitude,
      'createdAt': createdAt.toIso8601String(),
      'savedAt': savedAt.toIso8601String(),
    };
  }

  factory FavoriteRequestModel.fromJson(Map<String, dynamic> json) {
    return FavoriteRequestModel(
      id: json['id'] as String,
      category: json['category'] as String,
      subType: json['subType'] as String,
      area: json['area'] as String,
      description: json['description'] as String,
      priority: json['priority'] as String?,
      budget: json['budget'] as double?,
      preferredTime: json['preferredTime'] as String?,
      locationLatitude: json['locationLatitude'] as String?,
      locationLongitude: json['locationLongitude'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }

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
        locationLatitude,
        locationLongitude,
        createdAt,
        savedAt,
      ];
}
