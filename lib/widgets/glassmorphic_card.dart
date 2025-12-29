import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Glassmorphic card widget with frosted glass effect
class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool showBorder;
  final Gradient? gradient;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.blur = 10,
    this.opacity = 0.1,
    this.padding,
    this.margin,
    this.onTap,
    this.showBorder = true,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? AppColors.cardShadowDark.withOpacity(0.3)
                : AppColors.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient ?? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        AppColors.glassDark.withOpacity(opacity),
                        AppColors.glassDark.withOpacity(opacity * 0.5),
                      ]
                    : [
                        AppColors.glassLight.withOpacity(opacity),
                        AppColors.glassLight.withOpacity(opacity * 0.5),
                      ],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: showBorder
                  ? Border.all(
                      color: AppColors.glassBorder,
                      width: 1.5,
                    )
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(borderRadius),
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(16),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
