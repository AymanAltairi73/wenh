import 'package:flutter/foundation.dart';
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
import 'package:wenh/widgets/shimmer_loading.dart';
import 'package:wenh/models/worker_model.dart';
import 'package:wenh/services/firestore_service.dart';

class EnhancedAdminDashboard extends StatefulWidget {
  const EnhancedAdminDashboard({super.key});

  @override
  State<EnhancedAdminDashboard> createState() => _EnhancedAdminDashboardState();
}

class _EnhancedAdminDashboardState extends State<EnhancedAdminDashboard>
    with SingleTickerProviderStateMixin {
  String _selectedFilter = 'all';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    try {
      debugPrint('[EnhancedAdminDashboard] Initializing and fetching requests');
      context.read<RequestCubit>().getRequests();
    } catch (e, stackTrace) {
      debugPrint('[EnhancedAdminDashboard] initState error: $e');
      debugPrint('[EnhancedAdminDashboard] stackTrace: $stackTrace');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRequestsTab(),
                    _buildWorkersTab(),
                    _buildRevenueTab(),
                  ],
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

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.softShadow],
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'الطلبات', icon: Icon(AppIcons.requests, size: 20)),
          Tab(text: 'العمال', icon: Icon(AppIcons.workers, size: 20)),
          Tab(text: 'الأرباح', icon: Icon(Icons.payments, size: 20)),
        ],
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorColor: AppColors.primary,
        dividerColor: Colors.transparent,
      ),
    );
  }

  Widget _buildRequestsTab() {
    return RefreshIndicator(
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
    );
  }

  Widget _buildWorkersTab() {
    final service = FirestoreService();
    return StreamBuilder<List<WorkerModel>>(
      stream: service.getAllWorkers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('لا يوجد عمال مسجلين'));
        }

        final workers = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: workers.length,
          itemBuilder: (context, index) {
            final worker = workers[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: worker.isSubscriptionActive
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  child: Icon(
                    AppIcons.workers,
                    color: worker.isSubscriptionActive
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                title: Text(
                  worker.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'الخطة: ${worker.subscriptionPlan == 'weekly'
                      ? 'أسبوعي'
                      : worker.subscriptionPlan == 'monthly'
                      ? 'شهري'
                      : 'لا يوجد'}',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      worker.isSubscriptionActive ? 'نشط' : 'منتهي',
                      style: TextStyle(
                        color: worker.isSubscriptionActive
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'ينتهي: ${worker.subscriptionEnd.day}/${worker.subscriptionEnd.month}',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRevenueTab() {
    final service = FirestoreService();
    return FutureBuilder<Map<String, dynamic>>(
      future: service.fetchRevenueStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData)
          return const Center(child: Text('خطأ في تحميل الإحصائيات'));

        final stats = snapshot.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              StatCard(
                title: 'إجمالي الأرباح',
                value: '${stats['totalRevenue']} د.ع',
                icon: Icons.monetization_on,
                color: Colors.green,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'أرباح أسبوعية',
                      value: '${stats['weeklyRevenue']} د.ع',
                      icon: Icons.calendar_view_week,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      title: 'أرباح شهرية',
                      value: '${stats['monthlyRevenue']} د.ع',
                      icon: Icons.calendar_month,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'عدد المشتركين الفعليين',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildRevenueRow(
                        'خطط أسبوعية',
                        '${stats['weeklyCount']} عمال',
                      ),
                      const Divider(),
                      _buildRevenueRow(
                        'خطط شهرية',
                        '${stats['monthlyCount']} عمال',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRevenueRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'لوحة التحكم',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                Text(
                  'إدارة شاملة للنظام',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
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
              borderRadius: BorderRadius.circular(24),
              boxShadow: [AppColors.cardShadowHeavy],
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
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

        if (state is RequestLoading) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                Expanded(
                  child: ShimmerPlaceholder(height: 100, borderRadius: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ShimmerPlaceholder(height: 100, borderRadius: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ShimmerPlaceholder(height: 100, borderRadius: 20),
                ),
              ],
            ),
          );
        }

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
          return SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: RequestCardSkeleton(),
                ),
                childCount: 5,
              ),
            ),
          );
        }

        if (state is RequestLoaded) {
          var requests = state.requests;

          if (_selectedFilter != 'all') {
            requests = requests
                .where((r) => r.status == _selectedFilter)
                .toList();
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
              delegate: SliverChildBuilderDelegate((context, index) {
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 400 + (index * 100)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RequestCard(request: requests[index]),
                  ),
                );
              }, childCount: requests.length),
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
