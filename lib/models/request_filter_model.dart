import 'package:equatable/equatable.dart';

class RequestFilterModel extends Equatable {
  final String? category;
  final String? area;
  final double? minBudget;
  final double? maxBudget;
  final double? maxDistance;
  final String? priority;
  final String searchQuery;

  const RequestFilterModel({
    this.category,
    this.area,
    this.minBudget,
    this.maxBudget,
    this.maxDistance,
    this.priority,
    this.searchQuery = '',
  });

  RequestFilterModel copyWith({
    String? category,
    String? area,
    double? minBudget,
    double? maxBudget,
    double? maxDistance,
    String? priority,
    String? searchQuery,
  }) {
    return RequestFilterModel(
      category: category ?? this.category,
      area: area ?? this.area,
      minBudget: minBudget ?? this.minBudget,
      maxBudget: maxBudget ?? this.maxBudget,
      maxDistance: maxDistance ?? this.maxDistance,
      priority: priority ?? this.priority,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  RequestFilterModel clearCategory() {
    return RequestFilterModel(
      area: area,
      minBudget: minBudget,
      maxBudget: maxBudget,
      maxDistance: maxDistance,
      priority: priority,
      searchQuery: searchQuery,
    );
  }

  RequestFilterModel clearArea() {
    return RequestFilterModel(
      category: category,
      minBudget: minBudget,
      maxBudget: maxBudget,
      maxDistance: maxDistance,
      priority: priority,
      searchQuery: searchQuery,
    );
  }

  RequestFilterModel clearBudget() {
    return RequestFilterModel(
      category: category,
      area: area,
      maxDistance: maxDistance,
      priority: priority,
      searchQuery: searchQuery,
    );
  }

  RequestFilterModel clearDistance() {
    return RequestFilterModel(
      category: category,
      area: area,
      minBudget: minBudget,
      maxBudget: maxBudget,
      priority: priority,
      searchQuery: searchQuery,
    );
  }

  RequestFilterModel clearPriority() {
    return RequestFilterModel(
      category: category,
      area: area,
      minBudget: minBudget,
      maxBudget: maxBudget,
      maxDistance: maxDistance,
      searchQuery: searchQuery,
    );
  }

  RequestFilterModel clearAll() {
    return const RequestFilterModel();
  }

  bool get isEmpty {
    return category == null &&
        area == null &&
        minBudget == null &&
        maxBudget == null &&
        maxDistance == null &&
        priority == null &&
        searchQuery.isEmpty;
  }

  int get activeFiltersCount {
    int count = 0;
    if (category != null) count++;
    if (area != null) count++;
    if (minBudget != null || maxBudget != null) count++;
    if (maxDistance != null) count++;
    if (priority != null) count++;
    if (searchQuery.isNotEmpty) count++;
    return count;
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'area': area,
      'minBudget': minBudget,
      'maxBudget': maxBudget,
      'maxDistance': maxDistance,
      'priority': priority,
      'searchQuery': searchQuery,
    };
  }

  factory RequestFilterModel.fromJson(Map<String, dynamic> json) {
    return RequestFilterModel(
      category: json['category'] as String?,
      area: json['area'] as String?,
      minBudget: json['minBudget'] as double?,
      maxBudget: json['maxBudget'] as double?,
      maxDistance: json['maxDistance'] as double?,
      priority: json['priority'] as String?,
      searchQuery: json['searchQuery'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [
        category,
        area,
        minBudget,
        maxBudget,
        maxDistance,
        priority,
        searchQuery,
      ];
}
