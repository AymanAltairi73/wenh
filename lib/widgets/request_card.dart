import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wenh/core/theme/app_colors.dart';
import 'package:wenh/core/theme/app_icons.dart';
import 'package:wenh/models/request_model.dart';
import 'package:wenh/cubits/request_cubit.dart';
import 'package:wenh/widgets/professional_dialog.dart';

class RequestCard extends StatelessWidget {
  final RequestModel request;

  const RequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final isNew = request.status == 'new';
    final statusColor = isNew ? AppColors.warning : AppColors.success;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadowLight],
        border: Border.all(
          color: statusColor.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getServiceIcon(request.type),
                    color: statusColor,
                    size: 24,
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
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            AppIcons.location,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            request.area,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isNew ? 'جديد' : 'مستلم',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'الوصف:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  request.description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
                if (request.takenBy != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          AppIcons.check,
                          color: AppColors.success,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'مستلم بواسطة: ${request.takenBy}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _changeStatus(context),
                        icon: const Icon(AppIcons.edit, size: 18),
                        label: const Text('تغيير الحالة'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _deleteRequest(context),
                      icon: const Icon(AppIcons.delete),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.error.withOpacity(0.1),
                        foregroundColor: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getServiceIcon(String type) {
    if (type.contains('نجّار') || type.contains('البناء')) {
      return AppIcons.construction;
    } else if (type.contains('كهربائي') || type.contains('الكهرباء')) {
      return AppIcons.electrical;
    } else if (type.contains('سبّاك') || type.contains('الماء')) {
      return AppIcons.plumbing;
    } else if (type.contains('دهان')) {
      return AppIcons.painting;
    } else if (type.contains('تنظيف')) {
      return AppIcons.cleaning;
    }
    return AppIcons.work;
  }

  Future<void> _changeStatus(BuildContext context) async {
    final newStatus = request.status == 'new' ? 'taken' : 'new';
    final result = await ProfessionalDialog.showConfirm(
      context: context,
      title: 'تغيير الحالة',
      message: 'هل تريد تغيير حالة الطلب إلى "${newStatus == 'new' ? 'جديد' : 'مستلم'}"؟',
    );

    if (result == true && context.mounted) {
      await context.read<RequestCubit>().updateStatus(
            id: request.id,
            status: newStatus,
          );
    }
  }

  Future<void> _deleteRequest(BuildContext context) async {
    final result = await ProfessionalDialog.showConfirm(
      context: context,
      title: 'حذف الطلب',
      message: 'هل أنت متأكد من حذف هذا الطلب؟ لا يمكن التراجع عن هذا الإجراء.',
    );

    if (result == true && context.mounted) {
      await context.read<RequestCubit>().deleteRequest(request.id);
      if (context.mounted) {
        await ProfessionalDialog.showSuccess(
          context: context,
          title: 'تم الحذف',
          message: 'تم حذف الطلب بنجاح',
        );
      }
    }
  }
}
