import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wenh/cubits/request_cubit.dart';
import 'package:wenh/cubits/request_state.dart';
import 'package:wenh/cubits/auth_cubit.dart';
import 'package:wenh/cubits/auth_state.dart';
import 'package:wenh/models/request_model.dart';
import 'package:wenh/models/request_filter_model.dart';
import 'package:wenh/services/filter_service.dart';
import 'package:wenh/services/location_service.dart';
import 'package:wenh/core/theme/app_colors.dart';
import 'package:wenh/widgets/glassmorphic_search_bar.dart';
import 'package:wenh/widgets/shimmer_loading.dart';

class EnhancedWorkerRequestsScreen extends StatefulWidget {
  const EnhancedWorkerRequestsScreen({super.key});

  @override
  State<EnhancedWorkerRequestsScreen> createState() =>
      _EnhancedWorkerRequestsScreenState();
}

class _EnhancedWorkerRequestsScreenState
    extends State<EnhancedWorkerRequestsScreen> {
  final FilterService _filterService = FilterService();
  final TextEditingController _searchController = TextEditingController();
  RequestFilterModel _currentFilter = const RequestFilterModel();
  bool _showMap = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeFilter();
  }

  Future<void> _initializeFilter() async {
    try {
      await _filterService.init();
      final lastFilter = await _filterService.getLastFilter();
      if (lastFilter != null && mounted) {
        setState(() {
          _currentFilter = lastFilter;
          _searchController.text = lastFilter.searchQuery;
        });
      }
      setState(() {
        _isInitialized = true;
      });
    } catch (e, stackTrace) {
      debugPrint('[EnhancedWorkerRequestsScreen] _initializeFilter error: $e');
      debugPrint('[EnhancedWorkerRequestsScreen] stackTrace: $stackTrace');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RequestModel> _applyFilters(List<RequestModel> requests) {
    return requests.where((request) {
      // Search query filter
      if (_currentFilter.searchQuery.isNotEmpty) {
        final query = _currentFilter.searchQuery.toLowerCase();
        final matchesSearch =
            request.type.toLowerCase().contains(query) ||
            request.area.toLowerCase().contains(query) ||
            request.description.toLowerCase().contains(query);
        if (!matchesSearch) return false;
      }

      // Category filter
      if (_currentFilter.category != null &&
          request.type != _currentFilter.category) {
        return false;
      }

      // Area filter
      if (_currentFilter.area != null && request.area != _currentFilter.area) {
        return false;
      }

      // Priority filter
      // Note: RequestModel doesn't have priority field yet, so this is for future use
      // if (_currentFilter.priority != null && request.priority != _currentFilter.priority) {
      //   return false;
      // }

      return true;
    }).toList();
  }

  void _updateFilter(RequestFilterModel newFilter) {
    setState(() {
      _currentFilter = newFilter;
    });
    _filterService.saveLastFilter(newFilter);
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterBottomSheet(
        currentFilter: _currentFilter,
        onApply: _updateFilter,
        filterService: _filterService,
      ),
    );
  }

  void _showSavedFiltersDialog() async {
    final savedFilters = await _filterService.getAllSavedFilters();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الفلاتر المحفوظة'),
        content: savedFilters.isEmpty
            ? const Text('لا توجد فلاتر محفوظة')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: savedFilters.length,
                  itemBuilder: (context, index) {
                    final entry = savedFilters.entries.elementAt(index);
                    return ListTile(
                      title: Text(entry.key),
                      subtitle: Text(
                        '${entry.value.activeFiltersCount} فلتر نشط',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () {
                              _updateFilter(entry.value);
                              Navigator.pop(context);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await _filterService.deleteSavedFilter(entry.key);
                              Navigator.pop(context);
                              _showSavedFiltersDialog();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('طلبات العامل'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(_showMap ? Icons.list : Icons.map),
            onPressed: () => setState(() => _showMap = !_showMap),
            tooltip: _showMap ? 'عرض القائمة' : 'عرض الخريطة',
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: _showSavedFiltersDialog,
            tooltip: 'الفلاتر المحفوظة',
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/worker-profile'),
            tooltip: 'الملف الشخصي',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.darkBackgroundGradient
              : AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: GlassmorphicSearchBar(
                  controller: _searchController,
                  hintText: 'ابحث عن طلب...',
                  onChanged: (value) {
                    _updateFilter(_currentFilter.copyWith(searchQuery: value));
                  },
                  onClear: () {
                    _updateFilter(_currentFilter.copyWith(searchQuery: ''));
                  },
                ),
              ),

              // Filter Chips
              if (_currentFilter.activeFiltersCount > 0)
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      if (_currentFilter.category != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Chip(
                            label: Text(_currentFilter.category!),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () =>
                                _updateFilter(_currentFilter.clearCategory()),
                          ),
                        ),
                      if (_currentFilter.area != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Chip(
                            label: Text(_currentFilter.area!),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () =>
                                _updateFilter(_currentFilter.clearArea()),
                          ),
                        ),
                      if (_currentFilter.minBudget != null ||
                          _currentFilter.maxBudget != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Chip(
                            label: Text(
                              '${_currentFilter.minBudget ?? 0} - ${_currentFilter.maxBudget ?? '∞'} د.ع',
                            ),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () =>
                                _updateFilter(_currentFilter.clearBudget()),
                          ),
                        ),
                      if (_currentFilter.maxDistance != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Chip(
                            label: Text('حتى ${_currentFilter.maxDistance} كم'),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () =>
                                _updateFilter(_currentFilter.clearDistance()),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: const Text('مسح الكل'),
                          onPressed: () {
                            _searchController.clear();
                            _updateFilter(_currentFilter.clearAll());
                          },
                        ),
                      ),
                    ],
                  ),
                ),

              // Filter Button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.filter_list),
                        label: Text(
                          _currentFilter.activeFiltersCount > 0
                              ? 'الفلاتر (${_currentFilter.activeFiltersCount})'
                              : 'الفلاتر',
                        ),
                        onPressed: _showFilterDialog,
                      ),
                    ),
                  ],
                ),
              ),

              // Subscription Warning
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state is Authenticated &&
                      !state.worker.isSubscriptionActive) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Card(
                        color: Colors.orange.shade50,
                        child: const ListTile(
                          leading: Icon(Icons.info, color: Colors.orange),
                          title: Text('انتهى الاشتراك'),
                          subtitle: Text(
                            'يرجى التجديد لعرض الطلبات واستلامها.',
                          ),
                        ),
                      ),
                    );
                  }
                  if (state is! Authenticated) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Card(
                        color: Colors.red.shade50,
                        child: const ListTile(
                          leading: Icon(Icons.lock, color: Colors.red),
                          title: Text('غير مسجل الدخول'),
                          subtitle: Text('يرجى تسجيل الدخول لاستلام الطلبات.'),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Requests List
              Expanded(
                child: BlocBuilder<RequestCubit, RequestState>(
                  builder: (context, state) {
                    if (state is RequestLoading) {
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: 5,
                        itemBuilder: (context, index) =>
                            const RequestCardSkeleton(),
                      );
                    }

                    if (state is RequestLoaded) {
                      final newRequests = state.requests
                          .where((r) => r.status == 'new')
                          .toList();
                      final filteredRequests = _applyFilters(newRequests);

                      if (filteredRequests.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'لا توجد طلبات متاحة',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              if (_currentFilter.activeFiltersCount > 0) ...[
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    _updateFilter(_currentFilter.clearAll());
                                  },
                                  child: const Text('مسح الفلاتر'),
                                ),
                              ],
                            ],
                          ),
                        );
                      }

                      return _showMap
                          ? _buildMapView(filteredRequests)
                          : _buildListView(filteredRequests);
                    }

                    return const Center(
                      child: Text('حدث خطأ في تحميل الطلبات'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListView(List<RequestModel> requests) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        bool disabled = true;
        String workerName = '';
        if (authState is Authenticated) {
          disabled = !authState.worker.isSubscriptionActive;
          workerName = authState.worker.name;
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<RequestCubit>().getRequests();
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final request = requests[index];
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 400 + (index * 100)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 50 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: _EnhancedRequestCard(
                  request: request,
                  disabled: disabled,
                  workerName: workerName,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMapView(List<RequestModel> requests) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'عرض الخريطة',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'سيتم إضافة الخريطة التفاعلية قريباً',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 16),
          Text(
            '${requests.length} طلب متاح',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _EnhancedRequestCard extends StatelessWidget {
  final RequestModel request;
  final bool disabled;
  final String workerName;

  const _EnhancedRequestCard({
    required this.request,
    required this.disabled,
    required this.workerName,
  });

  IconData _getServiceIcon(String type) {
    if (type.contains('كهرباء')) return Icons.electrical_services;
    if (type.contains('سباكة') || type.contains('ماء')) return Icons.plumbing;
    if (type.contains('بناء') || type.contains('دهان'))
      return Icons.construction;
    if (type.contains('نجارة')) return Icons.carpenter;
    if (type.contains('تكييف')) return Icons.ac_unit;
    return Icons.home_repair_service;
  }

  Color _getServiceColor(String type) {
    if (type.contains('كهرباء')) return Colors.amber;
    if (type.contains('سباكة') || type.contains('ماء')) return Colors.blue;
    if (type.contains('بناء') || type.contains('دهان')) return Colors.orange;
    if (type.contains('نجارة')) return Colors.brown;
    if (type.contains('تكييف')) return Colors.cyan;
    return Colors.teal;
  }

  String _calculateDistance(String area) {
    final location = LocationService.getLocationByCity(area);
    if (location != null) {
      final baghdadLocation = LocationService.getLocationByCity('بغداد');
      if (baghdadLocation != null) {
        final distance = LocationService.calculateDistance(
          baghdadLocation.latitude,
          baghdadLocation.longitude,
          location.latitude,
          location.longitude,
        );
        return '${distance.toStringAsFixed(1)} كم';
      }
    }
    return 'غير محدد';
  }

  @override
  Widget build(BuildContext context) {
    final serviceColor = _getServiceColor(request.type);
    final distance = _calculateDistance(request.area);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [AppColors.softShadow],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: serviceColor.withOpacity(0.12),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: serviceColor.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getServiceIcon(request.type),
                      color: serviceColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.type,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              request.area,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.straighten,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              distance,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Description
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الوصف:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    request.description,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle, size: 20),
                      label: const Text('استلام الطلب'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: serviceColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: disabled
                          ? null
                          : () {
                              context.read<RequestCubit>().takeRequest(
                                id: request.id,
                                workerName: workerName,
                                isSubscribed: !disabled,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم استلام الطلب بنجاح'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () => _showDetailsDialog(context, distance),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, String distance) {
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
              Text(
                'تفاصيل الطلب',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 32),
              _buildDetailRow('النوع:', request.type),
              _buildDetailRow('المنطقة:', request.area),
              _buildDetailRow('المسافة:', distance),
              _buildDetailRow('الحالة:', request.status),
              const SizedBox(height: 16),
              const Text(
                'الوصف:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
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
                  child: const Text('إغلاق'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final RequestFilterModel currentFilter;
  final Function(RequestFilterModel) onApply;
  final FilterService filterService;

  const _FilterBottomSheet({
    required this.currentFilter,
    required this.onApply,
    required this.filterService,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late RequestFilterModel _filter;
  final TextEditingController _minBudgetController = TextEditingController();
  final TextEditingController _maxBudgetController = TextEditingController();
  final TextEditingController _maxDistanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
    if (_filter.minBudget != null) {
      _minBudgetController.text = _filter.minBudget.toString();
    }
    if (_filter.maxBudget != null) {
      _maxBudgetController.text = _filter.maxBudget.toString();
    }
    if (_filter.maxDistance != null) {
      _maxDistanceController.text = _filter.maxDistance.toString();
    }
  }

  @override
  void dispose() {
    _minBudgetController.dispose();
    _maxBudgetController.dispose();
    _maxDistanceController.dispose();
    super.dispose();
  }

  void _saveFilter() async {
    final nameController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حفظ الفلتر'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'اسم الفلتر',
            hintText: 'مثال: طلبات بغداد',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      await widget.filterService.saveFilter(nameController.text, _filter);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم حفظ الفلتر بنجاح')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'الفلاتر',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('حفظ'),
                      onPressed: _saveFilter,
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Filters
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Budget Range
                    const Text(
                      'نطاق الميزانية (د.ع)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _minBudgetController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'من',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _filter = _filter.copyWith(
                                  minBudget: double.tryParse(value),
                                );
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _maxBudgetController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'إلى',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _filter = _filter.copyWith(
                                  maxBudget: double.tryParse(value),
                                );
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Max Distance
                    const Text(
                      'المسافة القصوى (كم)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _maxDistanceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'المسافة القصوى',
                        border: OutlineInputBorder(),
                        suffixText: 'كم',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _filter = _filter.copyWith(
                            maxDistance: double.tryParse(value),
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Actions
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _minBudgetController.clear();
                          _maxBudgetController.clear();
                          _maxDistanceController.clear();
                          setState(() {
                            _filter = const RequestFilterModel();
                          });
                        },
                        child: const Text('مسح الكل'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onApply(_filter);
                          Navigator.pop(context);
                        },
                        child: const Text('تطبيق'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
