import 'package:flutter/material.dart';
import 'package:wenh/widgets/custom_button.dart';
import 'package:wenh/widgets/theme_toggle.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Center(
                  child: Hero(
                    tag: 'app_logo',
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 96,
                      errorBuilder: (_, __, ___) => const Icon(Icons.handyman, size: 64, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'مرحباً بك في وينه',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'يرجى اختيار نوع المستخدم للمتابعة',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
            // Customer
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('زبون', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    const Text('أنشئ طلب خدمة بدون الحاجة إلى حساب.'),
                    const SizedBox(height: 12),
                    CustomButton(
                      label: 'أنا زبون',
                      icon: Icons.person_outline,
                      onPressed: () => Navigator.pushNamed(context, '/send'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Worker
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('عامل', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    const Text('سجّل دخولك للاطلاع على طلبات الزبائن واستلامها.'),
                    const SizedBox(height: 12),
                    CustomButton(
                      label: 'أنا عامل',
                      icon: Icons.build,
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                    ),
                  ],
                ),
              ),
            ),
                const SizedBox(height: 16),
            // Admin
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Text('مدير النظام', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'جديد',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('سجّل دخولك لإدارة النظام والطلبات والمستخدمين.'),
                    const SizedBox(height: 12),
                    CustomButton(
                      label: 'تسجيل دخول المدير',
                      icon: Icons.admin_panel_settings,
                      onPressed: () => Navigator.pushNamed(context, '/admin-login'),
                    ),
                  ],
                ),
              ),
            ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
