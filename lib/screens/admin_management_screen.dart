import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wenh/cubits/admin_cubit.dart';
import 'package:wenh/cubits/admin_state.dart';
import 'package:wenh/core/theme/app_colors.dart';
import 'package:wenh/core/theme/app_icons.dart';
import 'package:wenh/models/admin_model.dart';
import 'package:wenh/widgets/professional_dialog.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المديرين'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: BlocBuilder<AdminCubit, AdminState>(
          builder: (context, state) {
            if (state is AdminsLoaded) {
              final admins = state.admins;
              final currentAdmin = state.currentAdmin;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: admins.length,
                itemBuilder: (context, index) {
                  final admin = admins[index];
                  final isCurrent = admin.id == currentAdmin.id;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [AppColors.cardShadowLight],
                      border: isCurrent
                          ? Border.all(color: AppColors.primary, width: 2)
                          : null,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: _getRoleGradient(admin.role),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getRoleIcon(admin.role),
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              admin.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'أنت',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            admin.email,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getRoleColor(admin.role).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  admin.roleDisplayName,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _getRoleColor(admin.role),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: admin.isActive
                                      ? AppColors.success.withOpacity(0.1)
                                      : AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  admin.isActive ? 'نشط' : 'غير نشط',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: admin.isActive
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: !isCurrent && currentAdmin.hasPermission('manage_admins')
                          ? PopupMenuButton(
                              icon: const Icon(AppIcons.moreVert),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  onTap: () => _toggleAdminStatus(admin),
                                  child: Row(
                                    children: [
                                      Icon(
                                        admin.isActive
                                            ? AppIcons.visibilityOff
                                            : AppIcons.visibility,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(admin.isActive ? 'تعطيل' : 'تفعيل'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  onTap: () => _deleteAdmin(admin),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        AppIcons.delete,
                                        size: 20,
                                        color: AppColors.error,
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'حذف',
                                        style: TextStyle(color: AppColors.error),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                  );
                },
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
      floatingActionButton: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state is AdminsLoaded && state.currentAdmin.hasPermission('manage_admins')) {
            return FloatingActionButton.extended(
              onPressed: _showAddAdminDialog,
              icon: const Icon(AppIcons.add),
              label: const Text('إضافة مدير'),
              backgroundColor: AppColors.primary,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  IconData _getRoleIcon(AdminRole role) {
    switch (role) {
      case AdminRole.superAdmin:
        return AppIcons.superAdmin;
      case AdminRole.admin:
        return AppIcons.admin;
      case AdminRole.moderator:
        return AppIcons.moderator;
    }
  }

  Color _getRoleColor(AdminRole role) {
    switch (role) {
      case AdminRole.superAdmin:
        return AppColors.accent;
      case AdminRole.admin:
        return AppColors.primary;
      case AdminRole.moderator:
        return AppColors.secondary;
    }
  }

  LinearGradient _getRoleGradient(AdminRole role) {
    switch (role) {
      case AdminRole.superAdmin:
        return AppColors.accentGradient;
      case AdminRole.admin:
        return AppColors.primaryGradient;
      case AdminRole.moderator:
        return AppColors.secondaryGradient;
    }
  }

  Future<void> _toggleAdminStatus(AdminModel admin) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('هذه الميزة غير متاحة حالياً')),
    );
  }

  Future<void> _deleteAdmin(AdminModel admin) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('هذه الميزة غير متاحة حالياً')),
    );
  }

  Future<void> _showAddAdminDialog() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    AdminRole selectedRole = AdminRole.moderator;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'إضافة مدير جديد',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'الاسم',
                    prefixIcon: const Icon(AppIcons.profile),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    prefixIcon: const Icon(AppIcons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    prefixIcon: const Icon(Icons.lock_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<AdminRole>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    labelText: 'الدور',
                    prefixIcon: const Icon(AppIcons.admin),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: AdminRole.values.map((role) {
                    String label = '';
                    switch (role) {
                      case AdminRole.superAdmin:
                        label = 'مدير عام';
                        break;
                      case AdminRole.admin:
                        label = 'مدير';
                        break;
                      case AdminRole.moderator:
                        label = 'مشرف';
                        break;
                    }
                    return DropdownMenuItem(
                      value: role,
                      child: Text(label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedRole = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('إلغاء'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'إضافة',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (result == true && mounted) {
      if (nameController.text.isEmpty ||
          emailController.text.isEmpty ||
          passwordController.text.isEmpty) {
        await ProfessionalDialog.showError(
          context: context,
          title: 'خطأ',
          message: 'يرجى ملء جميع الحقول',
        );
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('هذه الميزة غير متاحة حالياً')),
        );
      }
    }
  }
}
