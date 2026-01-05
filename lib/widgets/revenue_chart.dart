import 'package:flutter/material.dart';
import 'package:wenh/core/theme/app_colors.dart';

class RevenueChart extends StatelessWidget {
  final Map<String, double> revenueData;
  final String title;
  final Color chartColor;

  const RevenueChart({
    super.key,
    required this.revenueData,
    required this.title,
    this.chartColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final maxRevenue = revenueData.values.isNotEmpty 
        ? revenueData.values.reduce((a, b) => a > b ? a : b) 
        : 1.0;

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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: revenueData.isEmpty
                ? const Center(
                    child: Text(
                      'لا توجد بيانات متاحة',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: revenueData.length,
                    itemBuilder: (context, index) {
                      final entry = revenueData.entries.elementAt(index);
                      final label = entry.key;
                      final value = entry.value;
                      final barHeight = maxRevenue > 0 ? (value / maxRevenue * 180).toDouble() : 0.0;

                      return Container(
                        width: 60,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 40,
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: chartColor,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              value.toStringAsFixed(0),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              label,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class SubscriptionStatsChart extends StatelessWidget {
  final Map<String, int> subscriptionData;

  const SubscriptionStatsChart({
    super.key,
    required this.subscriptionData,
  });

  @override
  Widget build(BuildContext context) {
    final total = subscriptionData.values.isNotEmpty
        ? subscriptionData.values.reduce((a, b) => a + b)
        : 1;

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
            'إحصائيات الاشتراكات',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (subscriptionData.isEmpty)
            const Center(
              child: Text(
                'لا توجد بيانات اشتراكات',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            )
          else
            Column(
              children: subscriptionData.entries.map((entry) {
                final label = entry.key;
                final value = entry.value;
                final percentage = total > 0 ? (value / total) * 100 : 0;
                final color = label.contains('أسبوعي') 
                    ? Colors.blue 
                    : label.contains('شهري') 
                        ? Colors.green 
                        : Colors.orange;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '$value (${percentage.toStringAsFixed(1)}%)',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerRight,
                          widthFactor: (percentage / 100).toDouble(),
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
