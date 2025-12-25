import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wenh/cubits/request_cubit.dart';
import 'package:wenh/widgets/custom_button.dart';

class RequestPreviewScreen extends StatelessWidget {
  final String category;
  final String subType;
  final String area;
  final String description;
  final String? priority;
  final double? budget;
  final String? preferredTime;

  const RequestPreviewScreen({
    super.key,
    required this.category,
    required this.subType,
    required this.area,
    required this.description,
    this.priority,
    this.budget,
    this.preferredTime,
  });

  void _submitRequest(BuildContext context) {
    final combinedType = '$category - $subType';
    context.read<RequestCubit>().addRequest(
          type: combinedType,
          area: area,
          description: description,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إرسال الطلب بنجاح')),
    );
    Navigator.pushNamedAndRemoveUntil(context, '/worker', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('معاينة الطلب'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ملخص الطلب',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        context,
                        'التصنيف الرئيسي',
                        category,
                        Icons.category,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        'الخدمة',
                        subType,
                        Icons.build,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        'المنطقة',
                        area,
                        Icons.location_on,
                      ),
                      if (priority != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          context,
                          'الأولوية',
                          priority == 'urgent' ? 'مستعجل' : 'عادي',
                          Icons.priority_high,
                        ),
                      ],
                      if (budget != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          context,
                          'الميزانية المتوقعة',
                          '$budget د.ع',
                          Icons.attach_money,
                        ),
                      ],
                      if (preferredTime != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          context,
                          'الوقت المفضل',
                          preferredTime!,
                          Icons.schedule,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تفاصيل الطلب',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('تعديل'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      label: 'تأكيد الإرسال',
                      onPressed: () => _submitRequest(context),
                      icon: Icons.check,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
