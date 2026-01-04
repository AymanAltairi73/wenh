import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wenh/cubits/admin_cubit.dart';
import 'package:wenh/cubits/admin_state.dart';
import 'package:wenh/core/theme/app_colors.dart';
import 'package:wenh/core/theme/app_icons.dart';
import 'package:wenh/widgets/professional_dialog.dart';
import 'package:wenh/widgets/loading_dialog.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _rememberMe = true;
  String _selectedCountryCode = '+966'; // Default Saudi Arabia

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state is AdminLoading) {
            LoadingDialog.show(context, message: 'جاري تسجيل الدخول...');
          } else if (state is AdminAuthenticated) {
            LoadingDialog.hide(context);
            Navigator.of(context).pushReplacementNamed('/admin');
          } else if (state is AdminError) {
            LoadingDialog.hide(context);
            ProfessionalDialog.showError(
              context: context,
              title: 'خطأ في تسجيل الدخول',
              message: state.message,
            );
          }
        },
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLogo(),
                      const SizedBox(height: 48),
                      _buildLoginCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: AppColors.vibrantGradient,
        shape: BoxShape.circle,
        boxShadow: [AppColors.cardShadowHeavy],
      ),
      child: const Icon(
        Icons.admin_panel_settings_outlined,
        size: 80,
        color: Colors.white,
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [AppColors.cardShadowMedium],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'تسجيل دخول المدير',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'قم بتسجيل الدخول للوصول إلى لوحة التحكم',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
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
                      underline: SizedBox(),
                      icon: Icon(Icons.arrow_drop_down, size: 20),
                      items: [
                        DropdownMenuItem(value: '+966', child: Text('🇸🇦 +966')),
                        DropdownMenuItem(value: '+971', child: Text('🇦🇪 +971')),
                        DropdownMenuItem(value: '+965', child: Text('🇰🇼 +965')),
                        DropdownMenuItem(value: '+968', child: Text('🇴🇲 +968')),
                        DropdownMenuItem(value: '+973', child: Text('🇧🇭 +973')),
                        DropdownMenuItem(value: '+962', child: Text('🇯🇴 +962')),
                        DropdownMenuItem(value: '+961', child: Text('🇱🇧 +961')),
                        DropdownMenuItem(value: '+20', child: Text('🇪🇬 +20')),
                        DropdownMenuItem(value: '+213', child: Text('🇩🇿 +213')),
                        DropdownMenuItem(value: '+216', child: Text('🇹🇳 +216')),
                        DropdownMenuItem(value: '+212', child: Text('🇲🇦 +212')),
                        DropdownMenuItem(value: '+967', child: Text('🇾🇪 +967')),
                        DropdownMenuItem(value: '+964', child: Text('🇮🇶 +964')),
                        DropdownMenuItem(value: '+970', child: Text('🇸🇾 +970')),
                        DropdownMenuItem(value: '+974', child: Text('🇶🇦 +974')),
                        DropdownMenuItem(value: '+218', child: Text('🇱🇾 +218')),
                        DropdownMenuItem(value: '+963', child: Text('🇮🇶 +963')),
                      ],
                      onChanged: (String? value) {
                        setState(() {
                          _selectedCountryCode = value!;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.phone),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال رقم الجوال';
              }
              if (value.trim().length < 9) {
                return 'رقم الجوال قصير جداً';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'كلمة المرور',
              prefixIcon: const Icon(Icons.lock_rounded),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? AppIcons.visibilityOff
                      : AppIcons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال كلمة المرور';
              }
              if (value.length < 6) {
                return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Remember Me Toggle
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
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          BlocBuilder<AdminCubit, AdminState>(
            builder: (context, state) {
              final loading = state is AdminLoading;
              return ElevatedButton(
                onPressed: loading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.login, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      loading ? 'جاري تسجيل الدخول...' : 'تسجيل الدخول',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/admin-register'),
          child: const Text(
            'إنشاء حساب مدير جديد',
            style: TextStyle(fontSize: 15),
          ),
        ),
      ],
    ));
  }

  Future<void> _handleLogin() async {
    try {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      final phoneNumber = _phoneController.text.trim();
      final password = _passwordController.text;

      debugPrint('[AdminLoginScreen] Attempting login for: $phoneNumber');
      await context.read<AdminCubit>().loginWithPhone(
        '$_selectedCountryCode${_phoneController.text.trim()}',
        _passwordController.text,
        rememberMe: _rememberMe,
      );
    } catch (e, stackTrace) {
      debugPrint('[AdminLoginScreen] _handleLogin error: $e');
      debugPrint('[AdminLoginScreen] stackTrace: $stackTrace');
    }
  }

}
