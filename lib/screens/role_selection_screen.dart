import 'package:flutter/material.dart';
import 'package:wenh/core/theme/app_colors.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark 
            ? AppColors.darkBackgroundGradient
            : AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Section
                  Image.asset(
                    'assets/images/logo.png',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 24),
                  
                  // App Title
                  Text(
                    'مرحباً بك',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اختر دورك للمتابعة',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              // Role Selection Cards
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Worker Card
                      _buildRoleCard(
                        context,
                        title: 'عامل',
                        icon: Icons.person_outline,
                        onTap: () => Navigator.pushNamed(context, '/login'),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 20),
                      
                      // Admin Card
                      _buildRoleCard(
                        context,
                        title: 'مدير',
                        //subtitle: 'إدارة الوظائف والموظفين',
                        icon: Icons.admin_panel_settings_outlined,
                        onTap: () => Navigator.pushNamed(context, '/admin_login'),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: isDark 
              ? AppColors.dividerDark.withOpacity(0.3)
              : AppColors.divider.withOpacity(0.3),
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
                    color: AppColors.primary.withOpacity(0.3),
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
            const SizedBox(height: 8),
            
            // Subtitle
           
          ],
        ),
      ),
    );
  }
}
