import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wenh/cubits/admin_cubit.dart';
import 'package:wenh/cubits/admin_state.dart';
import 'package:wenh/core/theme/app_colors.dart';
import 'package:wenh/core/theme/app_icons.dart';
import 'package:wenh/widgets/professional_dialog.dart';
import 'package:intl/intl.dart';

class EnhancedAdminProfile extends StatelessWidget {
  const EnhancedAdminProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: BlocBuilder<AdminCubit, AdminState>(
            builder: (context, state) {
              if (state is AdminAuthenticated) {
                final admin = state.admin;
                return CustomScrollView(
                  slivers: [
                    _buildAppBar(context, admin.name),
                    SliverToBoxAdapter(child: _buildProfileHeader(admin)),
                    SliverToBoxAdapter(child: _buildPermissionsCard(admin)),
                    SliverToBoxAdapter(child: _buildAccountInfo(admin)),
                    SliverToBoxAdapter(child: _buildQuickActions(context)),
                  ],
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String name) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      actions: [
        IconButton(
          onPressed: () => _showLogoutDialog(context),
          icon: const Icon(AppIcons.logout),
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildProfileHeader(admin) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [AppColors.cardShadowHeavy],
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(
              AppIcons.admin,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            admin.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            admin.email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getRoleIcon(admin.role),
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  admin.roleDisplayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsCard(admin) {
    final permissions = admin.permissions.entries.where((e) => e.value).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppColors.cardShadowLight],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  AppIcons.check,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'الصلاحيات',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...permissions.map((permission) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(
                    AppIcons.check,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getPermissionLabel(permission.key),
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAccountInfo(admin) {
    final dateFormat = DateFormat('yyyy/MM/dd - HH:mm', 'ar');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppColors.cardShadowLight],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  AppIcons.info,
                  color: AppColors.info,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'معلومات الحساب',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'تاريخ الإنشاء',
            dateFormat.format(admin.createdAt),
            AppIcons.calendar,
          ),
          const SizedBox(height: 12),
          if (admin.lastLogin != null)
            _buildInfoRow(
              'آخر تسجيل دخول',
              dateFormat.format(admin.lastLogin!),
              AppIcons.time,
            ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'حالة الحساب',
            admin.isActive ? 'نشط' : 'غير نشط',
            admin.isActive ? AppIcons.check : AppIcons.close,
            valueColor: admin.isActive ? AppColors.success : AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppColors.cardShadowLight],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إجراءات سريعة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            'لوحة التحكم',
            AppIcons.dashboard,
            AppColors.primary,
            () => Navigator.pop(context),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            'إدارة المديرين',
            AppIcons.admin,
            AppColors.secondary,
            () => Navigator.pushNamed(context, '/admin-management'),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            'الإعدادات',
            AppIcons.settings,
            AppColors.info,
            () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            Icon(AppIcons.arrowForward, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  IconData _getRoleIcon(role) {
    switch (role.toString()) {
      case 'AdminRole.superAdmin':
        return AppIcons.superAdmin;
      case 'AdminRole.admin':
        return AppIcons.admin;
      default:
        return AppIcons.moderator;
    }
  }

  String _getPermissionLabel(String key) {
    switch (key) {
      case 'manage_admins':
        return 'إدارة المديرين';
      case 'manage_requests':
        return 'إدارة الطلبات';
      case 'manage_workers':
        return 'إدارة العمال';
      case 'view_analytics':
        return 'عرض الإحصائيات';
      case 'manage_settings':
        return 'إدارة الإعدادات';
      case 'delete_data':
        return 'حذف البيانات';
      default:
        return key;
    }
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final result = await ProfessionalDialog.showConfirm(
      context: context,
      title: 'تسجيل الخروج',
      message: 'هل أنت متأكد من تسجيل الخروج؟',
      confirmText: 'تسجيل الخروج',
      cancelText: 'إلغاء',
    );

    if (result == true && context.mounted) {
      context.read<AdminCubit>().logout();
      Navigator.of(context).pushNamedAndRemoveUntil('/role', (route) => false);
    }
  }
}
