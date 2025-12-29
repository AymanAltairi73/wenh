import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wenh/widgets/animated_role_card.dart';
import 'package:wenh/widgets/theme_toggle.dart';
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
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: ThemeToggle(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.darkBackgroundGradient
              : AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  
                  // Logo and Title
                  Center(
                    child: Column(
                      children: [
                        Hero(
                          tag: 'app_logo',
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: AppColors.purpleIndigoGradient,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/logo.png',
                              height: 64,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.handyman,
                                size: 64,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .scale(
                              begin: const Offset(0.8, 0.8),
                              end: const Offset(1, 1),
                              duration: 600.ms,
                              curve: Curves.easeOutBack,
                            ),
                        const SizedBox(height: 24),
                        Text(
                          'مرحباً بك في وينه',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..shader = AppColors.purpleIndigoGradient.createShader(
                                    const Rect.fromLTWH(0, 0, 200, 70),
                                  ),
                              ),
                        )
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 600.ms)
                            .slideY(begin: 0.3, end: 0, duration: 600.ms),
                        const SizedBox(height: 12),
                        Text(
                          'يرجى اختيار نوع المستخدم للمتابعة',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                        )
                            .animate()
                            .fadeIn(delay: 400.ms, duration: 600.ms)
                            .slideY(begin: 0.3, end: 0, duration: 600.ms),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Customer Card
                  AnimatedRoleCard(
                    title: 'زبون',
                    subtitle: 'أنشئ طلب خدمة بدون الحاجة إلى حساب واحصل على المساعدة من العمال المهرة.',
                    icon: Icons.person_outline,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primaryLight,
                      ],
                    ),
                    onTap: () => Navigator.pushReplacementNamed(context, '/customer'),
                    animationDelay: 600,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Worker Card
                  AnimatedRoleCard(
                    title: 'عامل',
                    subtitle: 'سجّل دخولك للاطلاع على طلبات الزبائن واستلامها وتقديم خدماتك المهنية.',
                    icon: Icons.build_circle_outlined,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.secondary,
                        AppColors.secondaryLight,
                      ],
                    ),
                    onTap: () => Navigator.pushNamed(context, '/login'),
                    animationDelay: 800,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Admin Card
                  AnimatedRoleCard(
                    title: 'مدير النظام',
                    subtitle: 'سجّل دخولك لإدارة النظام والطلبات والمستخدمين بصلاحيات كاملة.',
                    icon: Icons.admin_panel_settings_outlined,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.accent,
                        AppColors.accentLight,
                      ],
                    ),
                    onTap: () => Navigator.pushNamed(context, '/admin-login'),
                    showBadge: true,
                    badgeText: 'جديد',
                    animationDelay: 1000,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Footer
                  Center(
                    child: Text(
                      'اختر الدور المناسب لك وابدأ رحلتك معنا',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.textTertiaryDark
                                : AppColors.textSecondary,
                          ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 1200.ms, duration: 600.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
