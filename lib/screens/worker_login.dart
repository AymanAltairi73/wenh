import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wenh/cubits/auth_cubit.dart';
import 'package:wenh/cubits/auth_state.dart';
import 'package:wenh/widgets/custom_button.dart';
import 'package:wenh/core/theme/app_colors.dart';

class WorkerLoginScreen extends StatefulWidget {
  const WorkerLoginScreen({super.key});

  @override
  State<WorkerLoginScreen> createState() => _WorkerLoginScreenState();
}

class _WorkerLoginScreenState extends State<WorkerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  bool _obscure = true;
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

  void _verifyPhone() {
    try {
      if ((_formKey.currentState?.validate() ?? false)) {
        debugPrint(
          '[WorkerLoginScreen] Attempting phone verification for: ${_phoneController.text.trim()}',
        );
        context.read<AuthCubit>().verifyPhoneNumber(_phoneController.text.trim());
      }
    } catch (e, stackTrace) {
      debugPrint('[WorkerLoginScreen] _verifyPhone error: $e');
      debugPrint('[WorkerLoginScreen] stackTrace: $stackTrace');
    }
  }

  void _login() {
    try {
      if ((_formKey.currentState?.validate() ?? false) && _verificationId != null) {
        debugPrint(
          '[WorkerLoginScreen] Attempting login for: ${_phoneController.text.trim()}',
        );
        context.read<AuthCubit>().loginWithPhone(
          _phoneController.text.trim(),
          _passwordController.text,
          _verificationId!,
          _otpController.text,
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
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل دخول العامل')),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              Navigator.pushReplacementNamed(context, '/worker');
            } else if (state is AuthError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is OtpSent) {
              setState(() {
                _verificationId = state.verificationId;
                _showOtpField = true;
              });
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('تم إرسال رمز التحقق')));
            }
          },
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppColors.vibrantGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Hero(
                                    tag: 'app_logo',
                                    child: Container(
                                      width: 72,
                                      height: 72,
                                      decoration: BoxDecoration(
                                        gradient: AppColors.vibrantGradient,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.work_outline,
                                        size: 36,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'تسجيل دخول العامل',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'رقم الجوال',
                              prefixIcon: Icon(Icons.phone),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'مطلوب';
                              }
                              if (!v.startsWith('+')) {
                                return 'يجب أن يبدأ برمز الدولة (+966)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              labelText: 'كلمة المرور',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'مطلوب' : null,
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
                                  onChanged: (v) =>
                                      setState(() => _rememberMe = v ?? false),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _rememberMe = !_rememberMe),
                                child: Text(
                                  'تذكرني',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
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
                              decoration: const InputDecoration(
                                labelText: 'رمز التحقق',
                                prefixIcon: Icon(Icons.sms),
                              ),
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? 'مطلوب' : null,
                            ),
                          ],
                          const SizedBox(height: 24),
                          BlocBuilder<AuthCubit, AuthState>(
                            builder: (context, state) {
                              final loading = state is AuthLoading;
                              if (!_showOtpField) {
                                return CustomButton(
                                  label: loading
                                      ? 'جاري إرسال رمز التحقق...'
                                      : 'إرسال رمز التحقق',
                                  onPressed: loading ? null : _verifyPhone,
                                  icon: Icons.phone,
                                );
                              } else {
                                return CustomButton(
                                  label: loading
                                      ? 'جاري تسجيل الدخول...'
                                      : 'تسجيل الدخول',
                                  onPressed: loading ? null : _login,
                                  icon: Icons.login,
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: TextButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/register'),
                              child: const Text('إنشاء حساب جديد'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
