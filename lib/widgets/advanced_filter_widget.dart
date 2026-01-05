import 'package:flutter/material.dart';
import 'package:wenh/core/theme/app_colors.dart';

class FilterOptions {
  final String? status;
  final String? area;
  final String? jobType;
  final DateTimeRange? dateRange;

  const FilterOptions({
    this.status,
    this.area,
    this.jobType,
    this.dateRange,
  });

  FilterOptions copyWith({
    String? status,
    String? area,
    String? jobType,
    DateTimeRange? dateRange,
  }) {
    return FilterOptions(
      status: status ?? this.status,
      area: area ?? this.area,
      jobType: jobType ?? this.jobType,
      dateRange: dateRange ?? this.dateRange,
    );
  }

  bool get hasAnyFilter => status != null || area != null || jobType != null || dateRange != null;

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;
    if (area != null) params['area'] = area;
    if (jobType != null) params['type'] = jobType;
    return params;
  }
}

class AdvancedFilterWidget extends StatefulWidget {
  final FilterOptions initialFilters;
  final Function(FilterOptions) onFiltersChanged;
  final List<String> availableAreas;
  final List<String> availableJobTypes;

  const AdvancedFilterWidget({
    super.key,
    required this.initialFilters,
    required this.onFiltersChanged,
    this.availableAreas = const [
      'بغداد',
      'البصرة',
      'أربيل',
      'السليمانية',
      'دهوك',
      'نينوى',
      'الأنبار',
      'كربلاء',
      'واسط',
      'ميسان',
      'بابل',
      'ديالى',
      'صلاح الدين',
      'القادسية',
      'ذي قار',
      'المثنى',
    ],
    this.availableJobTypes = const [
      'كهرباء',
      'سباكة',
      'تنظيف',
      'نقل',
      'دهان',
      'تصليح',
      'نجارة',
      'حدادة',
      'تكييف',
      'تلفزيون',
      'ثلاجة',
      'غسالة',
      'أخرى',
    ],
  });

  @override
  State<AdvancedFilterWidget> createState() => _AdvancedFilterWidgetState();
}

class _AdvancedFilterWidgetState extends State<AdvancedFilterWidget> {
  late FilterOptions _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
  }

  void _updateFilters(FilterOptions newFilters) {
    setState(() {
      _filters = newFilters;
    });
    widget.onFiltersChanged(newFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadowLight],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الفلاتر المتقدمة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (_filters.hasAnyFilter)
                TextButton(
                  onPressed: () => _updateFilters(const FilterOptions()),
                  child: const Text(
                    'مسح الكل',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Status Filter
          _buildFilterSection(
            'حالة الطلب',
            [
              'الكل',
              'جديد',
              'مأخوذ',
              'مكتمل',
            ],
            _filters.status,
            (value) => _updateFilters(_filters.copyWith(status: value == 'الكل' ? null : value)),
          ),
          
          const SizedBox(height: 16),
          
          // Area Filter
          _buildFilterSection(
            'المنطقة',
            ['الكل', ...widget.availableAreas],
            _filters.area,
            (value) => _updateFilters(_filters.copyWith(area: value == 'الكل' ? null : value)),
          ),
          
          const SizedBox(height: 16),
          
          // Job Type Filter
          _buildFilterSection(
            'نوع العمل',
            ['الكل', ...widget.availableJobTypes],
            _filters.jobType,
            (value) => _updateFilters(_filters.copyWith(jobType: value == 'الكل' ? null : value)),
          ),
          
          const SizedBox(height: 16),
          
          // Date Range Filter
          _buildDateRangeFilter(),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, List<String> options, String? selectedValue, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValue == option || (selectedValue == null && option == 'الكل');
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onChanged(option);
                }
              },
              backgroundColor: Colors.grey[100],
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'نطاق التاريخ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _filters.dateRange != null
                    ? '${_formatDate(_filters.dateRange!.start)} - ${_formatDate(_filters.dateRange!.end)}'
                    : 'اختر نطاق التاريخ',
                style: TextStyle(
                  color: _filters.dateRange != null ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
              Row(
                children: [
                  if (_filters.dateRange != null)
                    IconButton(
                      onPressed: () => _updateFilters(_filters.copyWith(dateRange: null)),
                      icon: const Icon(Icons.clear, size: 20),
                      color: Colors.grey,
                    ),
                  IconButton(
                    onPressed: _selectDateRange,
                    icon: const Icon(Icons.calendar_today, size: 20),
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );

    if (picked != null) {
      _updateFilters(_filters.copyWith(dateRange: picked));
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
