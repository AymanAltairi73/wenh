import 'package:flutter/material.dart';
import 'package:wenh/screens/request_preview_screen.dart';
import 'package:wenh/widgets/custom_button.dart';

class SendRequestScreen extends StatefulWidget {
  const SendRequestScreen({super.key});

  @override
  State<SendRequestScreen> createState() => _SendRequestScreenState();
}

class _SendRequestScreenState extends State<SendRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  
  String? _selectedCategory;
  String? _selectedSubType;
  String? _selectedArea;
  String? _selectedPriority = 'normal';
  String? _selectedTime;
  
  List<String> _filteredCategories = [];
  List<String> _filteredAreas = [];
  
  final Map<String, List<String>> _serviceCategories = const {
    '🏗 البناء والتشطيبات': [
      'بنّاء',
      'مبلّط',
      'جبّاس',
      'دهّان',
      'حدّاد بناء',
      'نجّار',
      'عازل أسطح',
      'قصّار',
      'تركيب طابوق',
      'تشطيب واجهات',
      'ترميم بيوت',
    ],
    '⚡ الكهرباء والطاقة': [
      'كهربائي',
      'كهربائي مولدات',
      'فني طاقة شمسية',
      'تركيب إنفرتر',
      'تمديدات كهرباء',
      'تركيب إنارة',
      'تصليح أجهزة كهربائية',
    ],
    '🚿 الماء والتبريد': [
      'سبّاك',
      'تمديدات صحية',
      'فني مضخات ماء',
      'فني تبريد وتكييف',
      'تركيب مكيفات',
      'تصليح ثلاجات',
      'تصليح غسالات',
      'صيانة سخانات',
    ],
    '📺 الإلكترونيات والأجهزة': [
      'فني ستلايت',
      'تركيب ستلايت',
      'تصليح تلفزيونات',
      'تصليح موبايلات',
      'تصليح حاسبات',
      'برمجة حاسبات',
      'فني كاميرات مراقبة',
      'تركيب إنترنت',
      'صيانة شبكات',
    ],
    '🪚 النجارة والحدادة': [
      'نجّار أثاث',
      'تفصيل مطابخ',
      'تفصيل غرف نوم',
      'نجّار ألمنيوم',
      'نجّار PVC',
      'حدّاد أبواب وشبابيك',
      'لحّام',
      'تركيب أبواب',
    ],
    '🚗 السيارات': [
      'ميكانيكي سيارات',
      'كهربائي سيارات',
      'فحص سيارات',
      'سمكري',
      'دهّان سيارات',
      'تصليح تكييف سيارات',
      'تبديل زيوت',
      'بنشرجي',
    ],
    '🧹 الخدمات المنزلية': [
      'عامل تنظيف',
      'عاملة تنظيف',
      'تنظيف خزانات',
      'تنظيف سجاد',
      'مكافحة حشرات',
      'نقل أثاث',
      'فك وتركيب أثاث',
      'تركيب ستائر',
      'تركيب ورق جدران',
    ],
    '🌿 الخدمات الخارجية والحدائق': [
      'عامل حدائق',
      'تصميم حدائق',
      'قصّ عشب',
      'تبليط حدائق',
      'سقي حدائق',
      'صيانة عامة',
      'تصليح أبواب',
      'تركيب مظلات',
    ],
    '🛠 أشغال عامة': [
      'صيانة عامة منازل',
      'تصليح أبواب ونوافذ',
      'فك وتركيب أثاث',
      'نقل أثاث',
      'تركيب ستائر',
      'تركيب ورق جدران',
      'تنظيف منازل',
      'تنظيف خزانات',
      'تنظيف سجاد',
      'مكافحة حشرات',
      'تركيب مظلات',
      'تركيب خزانات ماء',
      'تركيب فلاتر ماء',
      'حفر يدوي',
      'قصّ خرسانة',
      'أعمال تحميل وتنزيل',
    ],
  };
  List<String> get _currentSubServices => _serviceCategories[_selectedCategory] ?? const [];
 final List<String> _areas = const [
  'بغداد',
  'نينوى',
  'البصرة',
  'صلاح الدين',
  'دهوك',
  'أربيل',
  'السليمانية',
  'ديالى',
  'واسط',
  'ميسان',
  'ذي قار',
  'المثنى',
  'بابل',
  'كربلاء',
  'النجف',
  'الأنبار',
  'الديوانية (القادسية)',
  'كركوك',
];


  @override
  void initState() {
    super.initState();
    _initializeFilters();
  }

  void _initializeFilters() {
    _filteredCategories = _serviceCategories.keys.toList();
    _filteredAreas = _areas;
  }

  void _filterCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = _serviceCategories.keys.toList();
      } else {
        _filteredCategories = _serviceCategories.keys
            .where((cat) => cat.contains(query))
            .toList();
      }
    });
  }

  void _filterAreas(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredAreas = _areas;
      } else {
        _filteredAreas =
            _areas.where((area) => area.contains(query)).toList();
      }
    });
  }

  void _goToPreview() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RequestPreviewScreen(
            category: _selectedCategory!,
            subType: _selectedSubType!,
            area: _selectedArea!,
            description: _descriptionController.text,
            priority: _selectedPriority,
            budget: _budgetController.text.isEmpty
                ? null
                : double.tryParse(_budgetController.text),
            preferredTime: _selectedTime,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إرسال طلب'),
        centerTitle: true,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildProgressIndicator(),
                      const SizedBox(height: 24),
                      _buildCategorySection(),
                      const SizedBox(height: 16),
                      _buildSubTypeSection(),
                      const SizedBox(height: 16),
                      _buildAreaSection(),
                      const SizedBox(height: 16),
                      _buildDescriptionField(),
                      const SizedBox(height: 16),
                      _buildPrioritySection(),
                      const SizedBox(height: 16),
                      _buildBudgetField(),
                      const SizedBox(height: 16),
                      _buildTimeSection(),
                      const SizedBox(height: 24),
                      CustomButton(
                        label: 'معاينة وإرسال',
                        onPressed: _goToPreview,
                        icon: Icons.preview,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    int filledSteps = 0;
    if (_selectedCategory != null) filledSteps++;
    if (_selectedSubType != null) filledSteps++;
    if (_selectedArea != null) filledSteps++;
    if (_descriptionController.text.isNotEmpty) filledSteps++;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تقدم الملء: $filledSteps/4',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: filledSteps / 4,
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التصنيف الرئيسي',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            hintText: 'ابحث عن التصنيف...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: _filterCategories,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _filteredCategories.map((category) {
            final isSelected = _selectedCategory == category;
            return FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? category : null;
                  _selectedSubType = null;
                });
              },
            );
          }).toList(),
        ),
        if (_selectedCategory == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'مطلوب',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSubTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الخدمة الفرعية',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        if (_selectedCategory == null)
          Text(
            'اختر التصنيف أولاً',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _currentSubServices.map((subType) {
              final isSelected = _selectedSubType == subType;
              return FilterChip(
                label: Text(subType),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedSubType = selected ? subType : null;
                  });
                },
              );
            }).toList(),
          ),
        if (_selectedSubType == null && _selectedCategory != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'مطلوب',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAreaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المنطقة',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            hintText: 'ابحث عن المنطقة...',
            prefixIcon: const Icon(Icons.location_on),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: _filterAreas,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _filteredAreas.map((area) {
            final isSelected = _selectedArea == area;
            return FilterChip(
              label: Text(area),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedArea = selected ? area : null;
                });
              },
            );
          }).toList(),
        ),
        if (_selectedArea == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'مطلوب',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'وصف الطلب',
        hintText: 'اشرح المشكلة أو الخدمة المطلوبة بالتفصيل...',
        prefixIcon: const Icon(Icons.description),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildPrioritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الأولوية',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FilterChip(
                label: const Text('عادي'),
                selected: _selectedPriority == 'normal',
                onSelected: (selected) {
                  setState(() {
                    _selectedPriority = selected ? 'normal' : null;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilterChip(
                label: const Text('مستعجل'),
                selected: _selectedPriority == 'urgent',
                onSelected: (selected) {
                  setState(() {
                    _selectedPriority = selected ? 'urgent' : null;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBudgetField() {
    return TextFormField(
      controller: _budgetController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'الميزانية المتوقعة (اختياري)',
        hintText: 'أدخل المبلغ بالدينار العراقي',
        prefixIcon: const Icon(Icons.attach_money),
        suffixText: 'د.ع',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildTimeSection() {
    final timeOptions = const [
      'في أقرب وقت',
      'خلال 24 ساعة',
      'خلال 3 أيام',
      'خلال أسبوع',
      'وقت محدد لاحقاً',
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الوقت المفضل (اختياري)',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: timeOptions.map((time) {
            final isSelected = _selectedTime == time;
            return FilterChip(
              label: Text(time),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedTime = selected ? time : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
