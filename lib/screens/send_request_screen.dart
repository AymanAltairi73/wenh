import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wenh/cubits/request_cubit.dart';
import 'package:wenh/widgets/custom_button.dart';

class SendRequestScreen extends StatefulWidget {
  const SendRequestScreen({super.key});

  @override
  State<SendRequestScreen> createState() => _SendRequestScreenState();
}

class _SendRequestScreenState extends State<SendRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  String? _selectedSubType;
  String? _selectedArea;
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
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final combinedType = '${_selectedCategory!.trim()} - ${_selectedSubType!.trim()}';
      context.read<RequestCubit>().addRequest(
            type: combinedType,
            area: _selectedArea!.trim(),
            description: _descriptionController.text.trim(),
          );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال الطلب')));
      Navigator.pushNamed(context, '/worker');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إرسال طلب')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: Center(
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
                        const Text(
                          'يرجى إدخال تفاصيل الطلب:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          items: _serviceCategories.keys
                              .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (v) => setState(() {
                            _selectedCategory = v;
                            _selectedSubType = null;
                          }),
                          decoration: const InputDecoration(
                            labelText: 'التصنيف الرئيسي',
                            prefixIcon: Icon(Icons.category),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedSubType,
                          items: _currentSubServices
                              .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                              .toList(),
                          onChanged: _selectedCategory == null
                              ? null
                              : (v) => setState(() => _selectedSubType = v),
                          decoration: const InputDecoration(
                            labelText: 'الخدمة الفرعية',
                            prefixIcon: Icon(Icons.build),
                          ),
                          validator: (v) {
                            if (_selectedCategory == null) return 'اختر التصنيف أولاً';
                            return (v == null || v.isEmpty) ? 'مطلوب' : null;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedArea,
                          items: _areas
                              .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedArea = v),
                          decoration: const InputDecoration(
                            labelText: 'المنطقة',
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'وصف الطلب',
                            prefixIcon: Icon(Icons.description),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                        ),
                        const SizedBox(height: 24),
                        CustomButton(label: 'إرسال', onPressed: _submit, icon: Icons.send),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
