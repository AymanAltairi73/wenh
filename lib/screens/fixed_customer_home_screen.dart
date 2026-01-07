import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wenh/cubits/request_cubit.dart';
import 'package:wenh/cubits/request_state.dart';
import 'package:wenh/cubits/auth_cubit.dart';
import 'package:wenh/cubits/auth_state.dart';
import 'package:wenh/models/request_model.dart';
import 'package:wenh/core/theme/app_colors.dart';
import 'package:wenh/widgets/glassmorphic_search_bar.dart';
import 'package:wenh/widgets/customer_map_view.dart';
import 'package:wenh/models/worker_model.dart';
import 'package:wenh/utils/map_utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

/// Fixed Customer Home Screen - No Permission Issues
class FixedCustomerHomeScreen extends StatefulWidget {
  const FixedCustomerHomeScreen({super.key});

  @override
  State<FixedCustomerHomeScreen> createState() =>
      _FixedCustomerHomeScreenState();
}

class _FixedCustomerHomeScreenState extends State<FixedCustomerHomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  LatLng? _userLocation;
  bool _isLocationLoaded = false;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      final hasPermission = await MapUtils.handleLocationPermission(context);
      if (!hasPermission) {
        if (mounted) {
          setState(() {
            _userLocation = const LatLng(33.3152, 44.3661); // Baghdad default
            _isLocationLoaded = true;
          });
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
          _isLocationLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted) {
        setState(() {
          _userLocation = const LatLng(33.3152, 44.3661); // Baghdad default
          _isLocationLoaded = true;
        });
      }
    }
  }

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
        title: const Text('طلباتي'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('لا توجد إشعارات جديدة')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
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
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [AppColors.cardShadowLight],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'الرئيسية', 0),
            _buildNavItem(Icons.map, 'الخريطة', 1),
            _buildNavItem(Icons.list_alt, 'طلباتي', 2),
            _buildNavItem(Icons.person, 'الملف', 3),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/send'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
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
        return _buildMapTab();
      case 2:
        return _buildMyRequestsTab();
      case 3:
        return _buildMoreTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blueGrey,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'مرحباً بك في وينه',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'منصة الخدمات المنزلية الموثوقة',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Search Bar
          GlassmorphicSearchBar(
            controller: _searchController,
            hintText: 'ابحث عن خدمة...',
            onChanged: (value) => setState(() {}),
            onClear: () => setState(() {}),
          ),

          const SizedBox(height: 24),

          // Statistics Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'الخدمات المتاحة',
                  '6+',
                  Icons.home_repair_service,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'العاملون النشطون',
                  '50+',
                  Icons.people,
                  Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Services Section
          const Text(
            'الخدمات الشهيرة',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildServiceCard(
                'كهرباء',
                Icons.electrical_services,
                Colors.blue,
              ),
              _buildServiceCard('سباكة', Icons.plumbing, Colors.cyan),
              _buildServiceCard('تكييف', Icons.ac_unit, Colors.lightBlue),
              _buildServiceCard('دهان', Icons.format_paint, Colors.orange),
              _buildServiceCard('نجارة', Icons.carpenter, Colors.brown),
              _buildServiceCard('نظافة', Icons.cleaning_services, Colors.green),
            ],
          ),

          const SizedBox(height: 24),

          // // How it works
          // const Text(
          //   'كيف يعمل التطبيق؟',
          //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          // ),
          // const SizedBox(height: 16),

          // Container(
          //   padding: const EdgeInsets.all(16),
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(12),
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.black.withOpacity(0.05),
          //         blurRadius: 10,
          //         offset: const Offset(0, 2),
          //       ),
          //     ],
          //   ),
          //   child: Column(
          //     children: [
          //       _buildStep('1', 'اطلب خدمة', 'اختر الخدمة التي تحتاجها'),
          //       _buildStep('2', 'استلم العامل', 'سيتم تخصيص عامل مؤهل'),
          //       _buildStep('3', 'استلم الخدمة', 'احصل على الخدمة بجودة عالية'),
          //     ],
          //   ),
          // ),

          // const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildMapTab() {
    if (!_isLocationLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final firestoreService = context.read<RequestCubit>().firestoreService;

    return StreamBuilder<List<WorkerModel>>(
      stream: firestoreService.getAllWorkers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final workers = snapshot.data ?? [];

        return CustomerMapView(
          userLocation: _userLocation!,
          workers: workers,
          onWorkerTap: (worker) {
            _showWorkerDetails(worker);
          },
        );
      },
    );
  }

  void _showWorkerDetails(WorkerModel worker) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    worker.name[0],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        worker.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        worker.profession,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'متاح الآن',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const Text(
                  ' 4.8 ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '(24 تقييم)',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    '/send',
                    arguments: {'worker': worker},
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('طلب خدمة من هذا العامل'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyRequestsTab() {
    // Trigger fetch if needed (optional, but good practice if not done elsewhere)
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   context.read<RequestCubit>().getRequests();
    // });

    return BlocBuilder<RequestCubit, RequestState>(
      builder: (context, state) {
        if (state is RequestLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is RequestError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'حدث خطأ في تحميل الطلبات',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message, // Show actual error for debugging
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<RequestCubit>().getRequests();
                  },
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
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
                    'لا توجد طلبات بعد',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/send'),
                    icon: const Icon(Icons.add),
                    label: const Text('إنشاء طلب جديد'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return _buildRequestCard(request);
            },
          );
        }

        // Initial state
        return Center(
          child: ElevatedButton(
            onPressed: () {
              final authState = context.read<AuthCubit>().state;
              String? userId;
              if (authState is Authenticated) {
                userId = authState.user.uid;
              }
              context.read<RequestCubit>().getRequests(createdBy: userId);
            },
            child: const Text('عرض الطلبات'),
          ),
        );
      },
    );
  }

  Widget _buildMoreTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
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
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildServiceCard(String title, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(RequestModel request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(request.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStatusText(request.status),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getStatusColor(request.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                request.type,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            request.description,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                request.area,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : Colors.grey,
              size: 22, // Reduced from 24 to fit better
            ),
            const SizedBox(height: 2), // Reduced from 4
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primary : Colors.grey,
                fontSize: 11, // Reduced from 12
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
      trailing: const Icon(Icons.arrow_forward_ios),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'new':
        return Colors.blue;
      case 'taken':
        return Colors.orange;
      case 'in_progress':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'new':
        return 'جديد';
      case 'taken':
        return 'تم الاستلام';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }
}
