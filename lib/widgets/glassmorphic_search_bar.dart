import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';

/// Modern glassmorphic search bar with animations
class GlassmorphicSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool autofocus;

  const GlassmorphicSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'ابحث...',
    this.onChanged,
    this.onClear,
    this.autofocus = false,
  });

  @override
  State<GlassmorphicSearchBar> createState() => _GlassmorphicSearchBarState();
}

class _GlassmorphicSearchBarState extends State<GlassmorphicSearchBar> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _isFocused
                ? (isDark ? AppColors.accentLight : AppColors.primary).withOpacity(0.3)
                : (isDark ? AppColors.cardShadowDark : AppColors.cardShadow).withOpacity(0.2),
            blurRadius: _isFocused ? 16 : 8,
            offset: Offset(0, _isFocused ? 6 : 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        AppColors.surfaceVariantDark.withOpacity(0.8),
                        AppColors.surfaceDark.withOpacity(0.6),
                      ]
                    : [
                        Colors.white.withOpacity(0.9),
                        Colors.white.withOpacity(0.7),
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isFocused
                    ? (isDark ? AppColors.accentLight : AppColors.primary)
                    : AppColors.glassBorder,
                width: _isFocused ? 2 : 1.5,
              ),
            ),
            child: TextField(
              controller: widget.controller,
              autofocus: widget.autofocus,
              onChanged: widget.onChanged,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondary,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: _isFocused
                      ? (isDark ? AppColors.accentLight : AppColors.primary)
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                )
                    .animate(target: _isFocused ? 1 : 0)
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.1, 1.1),
                      duration: 200.ms,
                    )
                    .then()
                    .shimmer(
                      duration: 1500.ms,
                      color: (isDark ? AppColors.accentLight : AppColors.primary).withOpacity(0.3),
                    ),
                suffixIcon: widget.controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                        onPressed: () {
                          widget.controller.clear();
                          widget.onClear?.call();
                          widget.onChanged?.call('');
                        },
                      )
                          .animate()
                          .fadeIn(duration: 200.ms)
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1, 1),
                            duration: 200.ms,
                          )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onTap: () => setState(() => _isFocused = true),
              onTapOutside: (_) => setState(() => _isFocused = false),
            ),
          ),
        ),
      ),
    );
  }
}
