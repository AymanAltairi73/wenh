import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wenh/cubits/admin_cubit.dart';
import 'package:wenh/cubits/admin_state.dart';
import 'package:wenh/cubits/request_cubit.dart';
import 'package:wenh/cubits/request_state.dart';
import 'package:wenh/core/theme/app_colors.dart';
import 'package:wenh/core/theme/app_icons.dart';
import 'package:wenh/widgets/professional_dialog.dart';
import 'package:wenh/widgets/stat_card.dart';
import 'package:wenh/widgets/request_card.dart';

class EnhancedAdminDashboard extends StatefulWidget {
  const EnhancedAdminDashboard({super.key});

  @override
  State<EnhancedAdminDashboard> createState() => _EnhancedAdminDashboardState();
}

class _EnhancedAdminDashboardState extends State<EnhancedAdminDashboard> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    context.read<RequestCubit>().getRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<RequestCubit>().getRequests();
                  },
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: _buildAdminInfo()),
                      SliverToBoxAdapter(child: _buildStatistics()),
                      SliverToBoxAdapter(child: _buildFilterChips()),
                      _buildRequestsList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/admin-management'),
        icon: const Icon(AppIcons.admin),
        label: const Text('إدارة المديرين'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [AppColors.cardShadowLight],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              AppIcons.dashboard,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'لوحة التحكم',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'إدارة شاملة للنظام',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/admin-profile'),
            icon: const Icon(AppIcons.profile),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              foregroundColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _showLogoutDialog(context),
            icon: const Icon(AppIcons.logout),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.error.withOpacity(0.1),
              foregroundColor: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminInfo() {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        if (state is AdminAuthenticated) {
          final admin = state.admin;
          return Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [AppColors.cardShadowMedium],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    AppIcons.admin,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        admin.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        admin.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          admin.roleDisplayName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatistics() {
    return BlocBuilder<RequestCubit, RequestState>(
      builder: (context, state) {
        int total = 0, newCount = 0, taken = 0;

        if (state is RequestLoaded) {
          total = state.requests.length;
          newCount = state.requests.where((r) => r.status == 'new').length;
          taken = state.requests.where((r) => r.status == 'taken').length;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'إجمالي الطلبات',
                  value: total.toString(),
                  icon: AppIcons.requests,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'طلبات جديدة',
                  value: newCount.toString(),
                  icon: AppIcons.statusNew,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'مستلمة',
                  value: taken.toString(),
                  icon: AppIcons.statusCompleted,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChips() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('الكل', 'all'),
            const SizedBox(width: 8),
            _buildFilterChip('جديد', 'new'),
            const SizedBox(width: 8),
            _buildFilterChip('مستلم', 'taken'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      checkmarkColor: Colors.white,
      elevation: isSelected ? 4 : 0,
      shadowColor: AppColors.primary.withOpacity(0.3),
    );
  }

  Widget _buildRequestsList() {
    return BlocBuilder<RequestCubit, RequestState>(
      builder: (context, state) {
        if (state is RequestLoading) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is RequestLoaded) {
          var requests = state.requests;

          if (_selectedFilter != 'all') {
            requests = requests.where((r) => r.status == _selectedFilter).toList();
          }

          if (requests.isEmpty) {
            return SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      AppIcons.requests,
                      size: 80,
                      color: AppColors.textDisabled,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد طلبات',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RequestCard(request: requests[index]),
                  );
                },
                childCount: requests.length,
              ),
            ),
          );
        }

        return const SliverFillRemaining(
          child: Center(child: Text('حدث خطأ في تحميل الطلبات')),
        );
      },
    );
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
