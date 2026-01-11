import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wenh/cubits/auth_cubit.dart';
import 'package:wenh/cubits/auth_state.dart';
import 'package:wenh/widgets/custom_button.dart';
import 'package:wenh/core/theme/app_colors.dart';

class WorkerLoginScreen extends StatelessWidget {
  const WorkerLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Reset success message flag when entering login screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().resetSuccessMessageFlag();
    });

    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            // Show success message only once when authenticated
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Show success message using the cubit method
              context.read<AuthCubit>().showAuthSuccess(context);

              // Navigate to worker home screen after showing message
              Future.delayed(const Duration(milliseconds: 500), () {
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/worker');
                }
              });
            });
          }
        },
        child: Container(
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
                          'تسجيل دخول العامل',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'أدخل بياناتك للمتابعة',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Form Section
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

                        // Login Form
                        _WorkerLoginForm(isDark: isDark),

                        const SizedBox(height: 24),

                        // Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ليس لديك حساب؟',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                '/register',
                                arguments: 'worker',
                              ),
                              child: Text(
                                'إنشاء حساب',
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
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
      ),
    );
  }
}

class _WorkerLoginForm extends StatefulWidget {
  final bool isDark;

  const _WorkerLoginForm({required this.isDark});

  @override
  State<_WorkerLoginForm> createState() => _WorkerLoginFormState();
}

class _WorkerLoginFormState extends State<_WorkerLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _rememberMe = true;
  String _selectedCountryCode = '+966';

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    try {
      if ((_formKey.currentState?.validate() ?? false)) {
        context.read<AuthCubit>().loginWithPhone(
          '$_selectedCountryCode${_phoneController.text.trim()}',
          _passwordController.text,
          rememberMe: _rememberMe,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('[WorkerLoginScreen] _login error: $e');
      debugPrint('[WorkerLoginScreen] stackTrace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Phone Number Field
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'رقم الجوال',
              prefixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 80,
                    child: DropdownButton<String>(
                      value: _selectedCountryCode,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down, size: 20),
                      items: [
                        DropdownMenuItem(
                          value: '+966',
                          child: Text('🇸🇦 +966'),
                        ),
                        DropdownMenuItem(
                          value: '+971',
                          child: Text('🇦🇪 +971'),
                        ),
                        DropdownMenuItem(
                          value: '+965',
                          child: Text('🇰🇼 +965'),
                        ),
                        DropdownMenuItem(
                          value: '+968',
                          child: Text('🇴🇲 +968'),
                        ),
                        DropdownMenuItem(
                          value: '+973',
                          child: Text('🇧🇭 +973'),
                        ),
                        DropdownMenuItem(
                          value: '+962',
                          child: Text('🇯🇴 +962'),
                        ),
                        DropdownMenuItem(
                          value: '+961',
                          child: Text('🇱🇧 +961'),
                        ),
                        DropdownMenuItem(value: '+20', child: Text('🇪🇬 +20')),
                        DropdownMenuItem(
                          value: '+213',
                          child: Text('🇩🇿 +213'),
                        ),
                        DropdownMenuItem(
                          value: '+216',
                          child: Text('🇹🇳 +216'),
                        ),
                        DropdownMenuItem(
                          value: '+212',
                          child: Text('🇲🇦 +212'),
                        ),
                        DropdownMenuItem(
                          value: '+967',
                          child: Text('🇾🇪 +967'),
                        ),
                        DropdownMenuItem(
                          value: '+964',
                          child: Text('🇮🇶 +964'),
                        ),
                        DropdownMenuItem(
                          value: '+970',
                          child: Text('🇸🇾 +970'),
                        ),
                        DropdownMenuItem(
                          value: '+974',
                          child: Text('🇶🇦 +974'),
                        ),
                        DropdownMenuItem(
                          value: '+218',
                          child: Text('🇱🇾 +218'),
                        ),
                        DropdownMenuItem(
                          value: '+963',
                          child: Text('🇮🇶 +963'),
                        ),
                      ],
                      onChanged: (String? value) {
                        setState(() {
                          _selectedCountryCode = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.phone, color: AppColors.primary),
                ],
              ),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'مطلوب';
              }
              if (v.trim().length < 9) {
                return 'رقم الجوال قصير جداً';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'كلمة المرور',
              prefixIcon: const Icon(Icons.lock, color: AppColors.primary),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.secondary,
                ),
              ),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
          ),
          const SizedBox(height: 16),

          // Remember Me
          Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: _rememberMe,
                  onChanged: (v) => setState(() => _rememberMe = v ?? false),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  activeColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => setState(() => _rememberMe = !_rememberMe),
                child: Text(
                  'تذكرني',
                  style: TextStyle(
                    color: widget.isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Login Button
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final loading = state is AuthLoading;
              return CustomButton(
                label: loading ? 'جاري تسجيل الدخول...' : 'تسجيل الدخول',
                onPressed: loading ? null : _login,
                icon: Icons.login,
              );
            },
          ),
        ],
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
