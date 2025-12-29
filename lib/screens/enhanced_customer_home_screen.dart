import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wenh/cubits/request_cubit.dart';
import 'package:wenh/cubits/request_state.dart';
import 'package:wenh/models/request_model.dart';
import 'package:wenh/core/theme/app_colors.dart';
import 'package:wenh/widgets/modern_bottom_nav.dart';
import 'package:wenh/widgets/glassmorphic_search_bar.dart';
import 'package:wenh/widgets/shimmer_loading.dart';

class EnhancedCustomerHomeScreen extends StatefulWidget {
  const EnhancedCustomerHomeScreen({super.key});

  @override
  State<EnhancedCustomerHomeScreen> createState() =>
      _EnhancedCustomerHomeScreenState();
}

class _EnhancedCustomerHomeScreenState
    extends State<EnhancedCustomerHomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('وينه'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('لا توجد إشعارات جديدة')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/customer-profile'),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.darkBackgroundGradient
              : AppColors.backgroundGradient,
        ),
        child: _buildBody(),
      ),
      bottomNavigationBar: ModernBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'الرئيسية',
          ),
          BottomNavItem(
            icon: Icons.list_alt_outlined,
            activeIcon: Icons.list_alt,
            label: 'طلباتي',
          ),
          BottomNavItem(
            icon: Icons.grid_view_outlined,
            activeIcon: Icons.grid_view,
            label: 'الخدمات',
          ),
          BottomNavItem(
            icon: Icons.menu_outlined,
            activeIcon: Icons.menu,
            label: 'المزيد',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/send'),
        icon: const Icon(Icons.add),
        label: const Text('طلب جديد'),
        elevation: 8,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildMyRequestsTab();
      case 2:
        return _buildServicesTab();
      case 3:
        return _buildMoreTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<RequestCubit>().getRequests();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: GlassmorphicSearchBar(
                controller: _searchController,
                hintText: 'ابحث عن خدمة...',
                onChanged: (value) => setState(() {}),
                onClear: () => setState(() {}),
              ),
            ),

            // Statistics Cards
            BlocBuilder<RequestCubit, RequestState>(
              builder: (context, state) {
                if (state is RequestLoaded) {
                  final myRequests = state.requests;
                  final activeRequests = myRequests
                      .where(
                        (r) => r.status == 'new' || r.status == 'in_progress',
                      )
                      .length;
                  final completedRequests = myRequests
                      .where((r) => r.status == 'completed')
                      .length;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'الطلبات النشطة',
                            activeRequests.toString(),
                            Icons.pending_actions,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'المكتملة',
                            completedRequests.toString(),
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: const [
                      Expanded(
                        child: ShimmerPlaceholder(
                          height: 120,
                          borderRadius: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ShimmerPlaceholder(
                          height: 120,
                          borderRadius: 24,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Quick Services
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'الخدمات الشهيرة',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _currentIndex = 2),
                    child: const Text('عرض الكل'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            _buildQuickServices(),

            const SizedBox(height: 24),

            // Recent Requests
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'طلباتي الأخيرة',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _currentIndex = 1),
                    child: const Text('عرض الكل'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            _buildRecentRequests(),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildMyRequestsTab() {
    return BlocBuilder<RequestCubit, RequestState>(
      builder: (context, state) {
        if (state is RequestLoading) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 5,
            itemBuilder: (context, index) => const RequestCardSkeleton(),
          );
        }

        if (state is RequestLoaded) {
          final requests = state.requests;

          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد طلبات',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/send'),
                    icon: const Icon(Icons.add),
                    label: const Text('إنشاء طلب جديد'),
                  ),
                ],
              ),
            );
          }

          // Group requests by status
          final activeRequests = requests
              .where((r) => r.status == 'new' || r.status == 'in_progress')
              .toList();
          final completedRequests = requests
              .where((r) => r.status == 'completed')
              .toList();

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'النشطة'),
                    Tab(text: 'المكتملة'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildRequestsList(activeRequests, 'لا توجد طلبات نشطة'),
                      _buildRequestsList(
                        completedRequests,
                        'لا توجد طلبات مكتملة',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return const Center(child: Text('حدث خطأ في تحميل الطلبات'));
      },
    );
  }

  Widget _buildServicesTab() {
    final services = [
      {
        'name': '🏗 البناء والتشطيبات',
        'icon': Icons.construction,
        'color': Colors.orange,
      },
      {
        'name': '⚡ الكهرباء والطاقة',
        'icon': Icons.electrical_services,
        'color': Colors.amber,
      },
      {
        'name': '🚿 الماء والتبريد',
        'icon': Icons.plumbing,
        'color': Colors.blue,
      },
      {
        'name': '🪚 النجارة والأثاث',
        'icon': Icons.carpenter,
        'color': Colors.brown,
      },
      {
        'name': '🎨 الدهان والديكور',
        'icon': Icons.format_paint,
        'color': Colors.purple,
      },
      {'name': '🔧 الصيانة العامة', 'icon': Icons.build, 'color': Colors.teal},
      {
        'name': '🌿 الحدائق والزراعة',
        'icon': Icons.grass,
        'color': Colors.green,
      },
      {
        'name': '🧹 التنظيف',
        'icon': Icons.cleaning_services,
        'color': Colors.cyan,
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'جميع الخدمات',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return _buildServiceCard(
              service['name'] as String,
              service['icon'] as IconData,
              service['color'] as Color,
            );
          },
        ),
      ],
    );
  }

  Widget _buildMoreTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'المزيد',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildMenuTile(
          'الملف الشخصي',
          Icons.person,
          () => Navigator.pushNamed(context, '/customer-profile'),
        ),
        _buildMenuTile(
          'الإعدادات',
          Icons.settings,
          () => Navigator.pushNamed(context, '/settings'),
        ),
        _buildMenuTile(
          'تسجيل دخول العامل',
          Icons.work,
          () => Navigator.pushNamed(context, '/login'),
        ),
        _buildMenuTile(
          'لوحة تحكم المدير',
          Icons.admin_panel_settings,
          () => Navigator.pushNamed(context, '/admin-login'),
        ),
        const Divider(height: 32),
        _buildMenuTile('المساعدة والدعم', Icons.help, () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('قريباً: صفحة المساعدة')),
          );
        }),
        _buildMenuTile('عن التطبيق', Icons.info, () {
          showAboutDialog(
            context: context,
            applicationName: 'وينه',
            applicationVersion: '1.0.0',
            applicationIcon: const Icon(Icons.handyman, size: 48),
            children: [const Text('تطبيق وينه لربط العملاء بالعمال المهرة')],
          );
        }),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [AppColors.softShadow],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickServices() {
    final quickServices = [
      {
        'name': 'كهرباء',
        'icon': Icons.electrical_services,
        'color': Colors.amber,
      },
      {'name': 'سباكة', 'icon': Icons.plumbing, 'color': Colors.blue},
      {'name': 'بناء', 'icon': Icons.construction, 'color': Colors.orange},
      {'name': 'نجارة', 'icon': Icons.carpenter, 'color': Colors.brown},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: quickServices.length,
        itemBuilder: (context, index) {
          final service = quickServices[index];
          return Padding(
            padding: const EdgeInsets.only(left: 12),
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, '/send'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 80,
                decoration: BoxDecoration(
                  color: (service['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (service['color'] as Color).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'service_${service['name']}',
                      child: Icon(
                        service['icon'] as IconData,
                        color: service['color'] as Color,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      service['name'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: service['color'] as Color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentRequests() {
    return BlocBuilder<RequestCubit, RequestState>(
      builder: (context, state) {
        if (state is RequestLoading) {
          return Column(
            children: List.generate(
              3,
              (index) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: RequestCardSkeleton(),
              ),
            ),
          );
        }

        if (state is RequestLoaded) {
          final recentRequests = state.requests.take(3).toList();

          if (recentRequests.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'لا توجد طلبات حتى الآن',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            );
          }

          return Column(
            children: recentRequests.map((request) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: _buildRequestCard(request),
              );
            }).toList(),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildRequestsList(List<RequestModel> requests, String emptyMessage) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<RequestCubit>().getRequests();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildRequestCard(requests[index]),
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(RequestModel request) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (request.status) {
      case 'new':
        statusColor = Colors.blue;
        statusText = 'جديد';
        statusIcon = Icons.fiber_new;
        break;
      case 'in_progress':
        statusColor = Colors.orange;
        statusText = 'قيد التنفيذ';
        statusIcon = Icons.pending;
        break;
      case 'completed':
        statusColor = Colors.green;
        statusText = 'مكتمل';
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = Colors.grey;
        statusText = request.status;
        statusIcon = Icons.info;
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [AppColors.softShadow],
      ),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [AppColors.cardShadowHeavy],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(statusIcon, color: statusColor, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request.type,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    _buildDetailRow('المنطقة:', request.area),
                    if (request.takenBy != null)
                      _buildDetailRow('العامل:', request.takenBy!),
                    const SizedBox(height: 16),
                    const Text(
                      'الوصف:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        request.description,
                        style: const TextStyle(height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('إغلاق'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      request.type,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    request.area,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  if (request.takenBy != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        request.takenBy!,
                        style: TextStyle(color: Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                request.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(String name, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/send'),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Hero(
                  tag: 'service_$name',
                  child: Icon(icon, color: color, size: 32),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile(String title, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
