import 'package:flutter/foundation.dart';
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
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _showOtpField = false;
  String? _verificationId;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
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
          } else if (state is AdminOtpSent) {
            LoadingDialog.hide(context);
            setState(() {
              _verificationId = state.verificationId;
              _showOtpField = true;
            });
            ProfessionalDialog.showSuccess(
              context: context,
              title: 'تم إرسال رمز التحقق',
              message: 'يرجى إدخال رمز التحقق المرسل',
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
              prefixIcon: const Icon(Icons.phone),
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
              if (!value.startsWith('+')) {
                return 'يجب أن يبدأ برمز الدولة (+966)';
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
          if (_showOtpField) ..[
            const SizedBox(height: 16),
            TextFormField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'رمز التحقق',
                prefixIcon: const Icon(Icons.sms),
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
                  return 'يرجى إدخال رمز التحقق';
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 32),
          BlocBuilder<AdminCubit, AdminState>(
            builder: (context, state) {
              final loading = state is AdminLoading;
              if (!_showOtpField) {
                return ElevatedButton(
                  onPressed: loading ? null : _handlePhoneVerification,
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
                      const Icon(Icons.phone, size: 22),
                      const SizedBox(width: 12),
                      Text(
                        loading ? 'جاري إرسال رمز التحقق...' : 'إرسال رمز التحقق',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              } else {
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
                      const Icon(AppIcons.login, size: 22),
                      const SizedBox(width: 12),
                      Text(
                        loading ? 'جاري تسجيل الدخول...' : 'تسجيل الدخول',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }
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
      ),
    );
  }

  Future<void> _handlePhoneVerification() async {
    try {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      final phoneNumber = _phoneController.text.trim();

      debugPrint('[AdminLoginScreen] Attempting phone verification for: $phoneNumber');
      await context.read<AdminCubit>().verifyPhoneNumber(phoneNumber);
    } catch (e, stackTrace) {
      debugPrint('[AdminLoginScreen] _handlePhoneVerification error: $e');
      debugPrint('[AdminLoginScreen] stackTrace: $stackTrace');
    }
  }

  Future<void> _handleLogin() async {
    try {
      if (!_formKey.currentState!.validate() || _verificationId == null) {
        return;
      }

      final phoneNumber = _phoneController.text.trim();
      final password = _passwordController.text;

      debugPrint('[AdminLoginScreen] Attempting login for: $phoneNumber');
      await context.read<AdminCubit>().loginWithPhone(
        phoneNumber,
        password,
        _verificationId!,
        _otpController.text,
        rememberMe: _rememberMe,
      );
    } catch (e, stackTrace) {
      debugPrint('[AdminLoginScreen] _handleLogin error: $e');
      debugPrint('[AdminLoginScreen] stackTrace: $stackTrace');
    }
  }

}
