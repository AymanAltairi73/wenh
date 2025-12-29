import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/theme/app_colors.dart';

class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerLoading({
    super.key,
    required this.child,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark
          ? AppColors.shimmerBaseDark
          : AppColors.shimmerBaseLight,
      highlightColor: isDark
          ? AppColors.shimmerHighlightDark
          : AppColors.shimmerHighlightLight,
      child: child,
    );
  }
}

class ShimmerPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerPlaceholder({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBaseLight,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class RequestCardSkeleton extends StatelessWidget {
  const RequestCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [AppColors.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ShimmerPlaceholder(width: 50, height: 50, borderRadius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerPlaceholder(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 16,
                    ),
                    const SizedBox(height: 8),
                    ShimmerPlaceholder(
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const ShimmerPlaceholder(height: 14),
          const SizedBox(height: 8),
          const ShimmerPlaceholder(width: 150, height: 14),
        ],
      ),
    );
  }
}
