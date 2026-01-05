import 'package:flutter/material.dart';
import 'package:wenh/core/theme/app_colors.dart';
import '../models/request_model.dart';

class RequestTimelineEvent {
  final String title;
  final String description;
  final DateTime timestamp;
  final IconData icon;
  final Color color;
  final bool isCompleted;

  const RequestTimelineEvent({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
    required this.color,
    this.isCompleted = true,
  });
}

class RequestTimelineWidget extends StatelessWidget {
  final RequestModel request;
  final List<RequestTimelineEvent>? customEvents;

  const RequestTimelineWidget({
    super.key,
    required this.request,
    this.customEvents,
  });

  List<RequestTimelineEvent> _generateTimelineEvents() {
    if (customEvents != null) return customEvents!;

    final events = <RequestTimelineEvent>[];
    
    // Request created
    events.add(RequestTimelineEvent(
      title: 'تم إنشاء الطلب',
      description: 'تم إرسال طلب ${request.type} في منطقة ${request.area}',
      timestamp: request.timestamp,
      icon: Icons.add_circle_outline,
      color: Colors.blue,
      isCompleted: true,
    ));

    // Request taken (if applicable)
    if (request.status == 'taken' || request.status == 'completed') {
      events.add(RequestTimelineEvent(
        title: 'تم استلام الطلب',
        description: 'قام عامل باستلام الطلب',
        timestamp: request.timestamp.add(const Duration(hours: 1)), // Estimate
        icon: Icons.person_outline,
        color: Colors.orange,
        isCompleted: true,
      ));
    }

    // Request completed (if applicable)
    if (request.status == 'completed') {
      events.add(RequestTimelineEvent(
        title: 'تم إكمال الطلب',
        description: 'تم إنجاز العمل بنجاح',
        timestamp: request.timestamp.add(const Duration(hours: 24)), // Estimate
        icon: Icons.check_circle_outline,
        color: Colors.green,
        isCompleted: true,
      ));
    } else if (request.status == 'taken') {
      // Next step (not completed yet)
      events.add(RequestTimelineEvent(
        title: 'في انتظار الإكمال',
        description: 'العمل قيد التنفيذ',
        timestamp: DateTime.now(),
        icon: Icons.pending_outlined,
        color: Colors.grey,
        isCompleted: false,
      ));
    } else {
      // Next step (not completed yet)
      events.add(RequestTimelineEvent(
        title: 'في انتظار الاستلام',
        description: 'لم يتم استلام الطلب بعد',
        timestamp: DateTime.now(),
        icon: Icons.hourglass_empty,
        color: Colors.grey,
        isCompleted: false,
      ));
    }

    return events;
  }

  @override
  Widget build(BuildContext context) {
    final events = _generateTimelineEvents();

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
          const Text(
            'تاريخ الطلب',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final isLast = index == events.length - 1;
              
              return _TimelineItem(
                event: event,
                isLast: isLast,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final RequestTimelineEvent event;
  final bool isLast;

  const _TimelineItem({
    required this.event,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: event.isCompleted ? event.color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: event.isCompleted ? event.color : Colors.grey,
                  width: 2,
                ),
              ),
              child: Icon(
                event.icon,
                color: event.isCompleted ? event.color : Colors.grey,
                size: 20,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: event.isCompleted ? event.color.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: event.isCompleted ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                event.description,
                style: TextStyle(
                  fontSize: 14,
                  color: event.isCompleted ? AppColors.textSecondary : AppColors.textDisabled,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDateTime(event.timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textDisabled,
                ),
              ),
              if (!isLast) const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم${difference.inDays > 1 ? 'ـ' : ''}';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة${difference.inHours > 1 ? 'ـ' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة${difference.inMinutes > 1 ? 'ـ' : ''}';
    } else {
      return 'الآن';
    }
  }
}

class RequestStatusTracker extends StatelessWidget {
  final RequestModel request;

  const RequestStatusTracker({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      _StatusStep(
        title: 'إنشاء الطلب',
        description: 'تم إرسال الطلب',
        icon: Icons.add_circle,
        isCompleted: true,
        isActive: request.status == 'new',
      ),
      _StatusStep(
        title: 'استلام الطلب',
        description: 'قام عامل باستلام الطلب',
        icon: Icons.person,
        isCompleted: request.status == 'taken' || request.status == 'completed',
        isActive: request.status == 'taken',
      ),
      _StatusStep(
        title: 'إكمال الطلب',
        description: 'تم إنجاز العمل',
        icon: Icons.check_circle,
        isCompleted: request.status == 'completed',
        isActive: request.status == 'completed',
      ),
    ];

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
          const Text(
            'حالة الطلب',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          
          Row(
            children: steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isLast = index == steps.length - 1;
              
              return Expanded(
                child: _StatusStepWidget(
                  step: step,
                  isLast: isLast,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _StatusStep {
  final String title;
  final String description;
  final IconData icon;
  final bool isCompleted;
  final bool isActive;

  const _StatusStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.isCompleted,
    required this.isActive,
  });
}

class _StatusStepWidget extends StatelessWidget {
  final _StatusStep step;
  final bool isLast;

  const _StatusStepWidget({
    required this.step,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: step.isCompleted ? AppColors.primary : Colors.grey[300],
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            step.icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          step.title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: step.isCompleted ? FontWeight.bold : FontWeight.normal,
            color: step.isCompleted ? AppColors.textPrimary : AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        if (!isLast) ...[
          const SizedBox(height: 8),
          Container(
            width: 2,
            height: 30,
            color: step.isCompleted ? AppColors.primary : Colors.grey[300],
          ),
        ],
      ],
    );
  }
}
