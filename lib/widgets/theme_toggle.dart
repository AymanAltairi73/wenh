import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wenh/cubits/theme_cubit.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: state.isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ThemeButton(
                icon: Icons.light_mode,
                isSelected: !state.isDark,
                onTap: () => context.read<ThemeCubit>().setTheme(AppTheme.light),
              ),
              _ThemeButton(
                icon: Icons.dark_mode,
                isSelected: state.isDark,
                onTap: () => context.read<ThemeCubit>().setTheme(AppTheme.dark),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ThemeButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
              : Colors.transparent,
        ),
        child: Icon(
          icon,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          size: 20,
        ),
      ),
    );
  }
}
