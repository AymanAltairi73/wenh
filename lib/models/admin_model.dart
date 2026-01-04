import 'package:equatable/equatable.dart';

enum AdminRole {
  superAdmin,
  admin,
  moderator,
}

class AdminModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final AdminRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final Map<String, bool> permissions;

  const AdminModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.isActive,
    required this.createdAt,
    this.lastLogin,
    required this.permissions,
  });

  bool hasPermission(String permission) {
    if (role == AdminRole.superAdmin) return true;
    return permissions[permission] ?? false;
  }

  String get roleDisplayName {
    switch (role) {
      case AdminRole.superAdmin:
        return 'مدير عام';
      case AdminRole.admin:
        return 'مدير';
      case AdminRole.moderator:
        return 'مشرف';
    }
  }

  AdminModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    AdminRole? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLogin,
    Map<String, bool>? permissions,
  }) {
    return AdminModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      permissions: permissions ?? this.permissions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.toString(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'permissions': permissions,
    };
  }

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String? ?? '',
      role: AdminRole.values.firstWhere(
        (e) => e.toString() == json['role'],
        orElse: () => AdminRole.moderator,
      ),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : null,
      permissions: Map<String, bool>.from(json['permissions'] as Map),
    );
  }

  static Map<String, bool> getDefaultPermissions(AdminRole role) {
    switch (role) {
      case AdminRole.superAdmin:
        return {
          'manage_admins': true,
          'manage_requests': true,
          'manage_workers': true,
          'view_analytics': true,
          'manage_settings': true,
          'delete_data': true,
        };
      case AdminRole.admin:
        return {
          'manage_admins': false,
          'manage_requests': true,
          'manage_workers': true,
          'view_analytics': true,
          'manage_settings': false,
          'delete_data': false,
        };
      case AdminRole.moderator:
        return {
          'manage_admins': false,
          'manage_requests': true,
          'manage_workers': false,
          'view_analytics': true,
          'manage_settings': false,
          'delete_data': false,
        };
    }
  }

  @override
  List<Object?> get props => [id, name, email, phone, role, isActive, createdAt, lastLogin, permissions];
}
