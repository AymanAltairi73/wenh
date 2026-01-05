import 'package:flutter/material.dart';

import 'package:wenh/core/theme/app_colors.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('اختيار الدور'),
        actions: const [],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.darkBackgroundGradient
              : AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header Section
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Section - Arched Bottom
                      ClipPath(
                        clipper: BottomArchClipper(),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        'اختر دورك',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'اختر الدور المناسب لك',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Role Selection Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Role Cards
                      _buildRoleCard(
                        context,
                        title: 'الزبون',
                        icon: Icons.person_outline,
                        onTap: () => Navigator.pushReplacementNamed(context, '/customer'),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 20),
                      _buildRoleCard(
                        context,
                        title: 'عامل',
                        icon: Icons.person_outline,
                        onTap: () => Navigator.pushNamed(context, '/login'),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 20),

                      _buildRoleCard(
                        context,
                        title: 'مدير',
                        icon: Icons.admin_panel_settings_outlined,
                        onTap: () => Navigator.pushNamed(context, '/admin-login'),
                        isDark: isDark,
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: isDark
                ? AppColors.dividerDark.withValues(alpha: 0.3)
                : AppColors.divider.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Icon Container
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom clipper for creating a bottom arch shape
class BottomArchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Start from top left corner
    path.moveTo(0, 0);

    // Draw straight line to top right
    path.lineTo(size.width, 0);

    // Draw straight line to bottom right
    path.lineTo(size.width, size.height * 0.7);

    // Draw a curve that creates the arch at the bottom
    path.quadraticBezierTo(
      size.width / 2, // Control point x (middle of width)
      size.height * 1.1, // Control point y (extends below to create curve)
      0, // End point x (left edge)
      size.height * 0.7, // End point y (same level as right side)
    );

    // Complete the path
    path.lineTo(0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
