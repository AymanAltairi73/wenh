import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';

/// Modern floating bottom navigation bar with animations
class ModernBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem> items;

  const ModernBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? AppColors.cardShadowDark.withOpacity(0.5)
                : AppColors.cardShadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = currentIndex == index;
          
          return Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? AppColors.vibrantGradient
                            : null,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isSelected ? item.activeIcon : item.icon,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.textTertiaryDark : AppColors.textSecondary),
                        size: 24,
                      ),
                    )
                        .animate(target: isSelected ? 1 : 0)
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.1, 1.1),
                          duration: 200.ms,
                        ),
                    const SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: isSelected ? 12 : 11,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? (isDark ? AppColors.accentLight : AppColors.primary)
                            : (isDark ? AppColors.textTertiaryDark : AppColors.textSecondary),
                      ),
                      child: Text(item.label),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const BottomNavItem({
    required this.icon,
    required this.label,
    IconData? activeIcon,
  }) : activeIcon = activeIcon ?? icon;
}
