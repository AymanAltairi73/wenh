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
    this.borderRadius = 24,
    this.blur = 15,
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
          isDark ? AppColors.cardShadowHeavy : AppColors.cardShadowMedium,
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              gradient:
                  gradient ??
                  LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            AppColors.glassDark.withOpacity(opacity),
                            AppColors.glassDark.withOpacity(opacity * 0.4),
                          ]
                        : [
                            AppColors.glassLight.withOpacity(opacity),
                            AppColors.glassLight.withOpacity(opacity * 0.4),
                          ],
                  ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: showBorder
                  ? Border.all(
                      color: isDark
                          ? AppColors.glassBorderDark
                          : AppColors.glassBorderLight,
                      width: 1.0,
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
