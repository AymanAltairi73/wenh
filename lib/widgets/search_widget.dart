import 'package:flutter/material.dart';
import 'package:wenh/core/theme/app_colors.dart';

class SearchWidget extends StatefulWidget {
  final String? initialValue;
  final Function(String) onSearchChanged;
  final Function(String) onSearchSubmitted;
  final String hintText;
  final bool showFilter;
  final VoidCallback? onFilterPressed;

  const SearchWidget({
    super.key,
    this.initialValue,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    this.hintText = 'ابحث عن طلب...',
    this.showFilter = false,
    this.onFilterPressed,
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppColors.cardShadowLight],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: widget.onSearchChanged,
        onSubmitted: widget.onSearchSubmitted,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecondary,
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_controller.text.isNotEmpty)
                IconButton(
                  onPressed: () {
                    _controller.clear();
                    widget.onSearchChanged('');
                  },
                  icon: const Icon(
                    Icons.clear,
                    color: AppColors.textSecondary,
                  ),
                ),
              if (widget.showFilter)
                IconButton(
                  onPressed: widget.onFilterPressed,
                  icon: const Icon(
                    Icons.filter_list,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

class AdvancedSearchWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onSearch;
  final List<String> availableAreas;
  final List<String> availableJobTypes;

  const AdvancedSearchWidget({
    super.key,
    required this.onSearch,
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
  State<AdvancedSearchWidget> createState() => _AdvancedSearchWidgetState();
}

class _AdvancedSearchWidgetState extends State<AdvancedSearchWidget> {
  final _searchController = TextEditingController();
  final _areaController = TextEditingController();
  final _jobTypeController = TextEditingController();
  final _statusController = TextEditingController();
  
  String _selectedArea = 'الكل';
  String _selectedJobType = 'الكل';
  String _selectedStatus = 'الكل';

  @override
  void dispose() {
    _searchController.dispose();
    _areaController.dispose();
    _jobTypeController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final searchParams = <String, dynamic>{};
    
    if (_searchController.text.isNotEmpty) {
      searchParams['query'] = _searchController.text;
    }
    
    if (_selectedArea != 'الكل') {
      searchParams['area'] = _selectedArea;
    }
    
    if (_selectedJobType != 'الكل') {
      searchParams['type'] = _selectedJobType;
    }
    
    if (_selectedStatus != 'الكل') {
      searchParams['status'] = _selectedStatus;
    }
    
    widget.onSearch(searchParams);
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedArea = 'الكل';
      _selectedJobType = 'الكل';
      _selectedStatus = 'الكل';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('بحث متقدم'),
          actions: [
            TextButton(
              onPressed: _clearFilters,
              child: const Text('مسح'),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Field
              const Text(
                'البحث في الوصف',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _searchController,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'اكتب كلمات مفتاحية...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Area Filter
              const Text(
                'المنطقة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedArea,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: ['الكل', ...widget.availableAreas].map((area) {
                  return DropdownMenuItem(
                    value: area,
                    child: Text(area),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedArea = value!;
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // Job Type Filter
              const Text(
                'نوع العمل',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedJobType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: ['الكل', ...widget.availableJobTypes].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedJobType = value!;
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // Status Filter
              const Text(
                'الحالة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: const ['الكل', 'جديد', 'مأخوذ', 'مكتمل'].map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
              
              const SizedBox(height: 32),
              
              // Search Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _performSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'بحث',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
