import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wenh/cubits/auth_cubit.dart';
import 'package:wenh/widgets/custom_button.dart';
import 'package:wenh/core/theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _otpController = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _showOtpField = false;
  String? _verificationId;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _verifyPhone() {
    try {
      if (!(_formKey.currentState?.validate() ?? false)) return;
      debugPrint('[RegisterScreen] Attempting phone verification for: ${_phoneController.text.trim()}');
      context.read<AuthCubit>().verifyPhoneNumber(_phoneController.text.trim());
    } catch (e, stackTrace) {
      debugPrint('[RegisterScreen] _verifyPhone error: $e');
      debugPrint('[RegisterScreen] stackTrace: $stackTrace');
    }
  }

  void _submit() {
    try {
      if (!(_formKey.currentState?.validate() ?? false) || _verificationId == null) return;
      debugPrint('[RegisterScreen] Attempting registration for: ${_phoneController.text.trim()}');
      context.read<AuthCubit>().registerWithPhone(
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        verificationId: _verificationId!,
        smsCode: _otpController.text,
      );
    } catch (e, stackTrace) {
      debugPrint('[RegisterScreen] _submit error: $e');
      debugPrint('[RegisterScreen] stackTrace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب')),
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
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
                                      Icons.person_add_outlined,
                                      size: 36,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'إنشاء حساب',
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'الاسم الكامل',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                        ),
                        const SizedBox(height: 12),
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
                          obscureText: _obscure1,
                          decoration: InputDecoration(
                            labelText: 'كلمة المرور',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _obscure1 = !_obscure1),
                              icon: Icon(_obscure1 ? Icons.visibility : Icons.visibility_off),
                            ),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _confirmController,
                          obscureText: _obscure2,
                          decoration: InputDecoration(
                            labelText: 'تأكيد كلمة المرور',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _obscure2 = !_obscure2),
                              icon: Icon(_obscure2 ? Icons.visibility : Icons.visibility_off),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'مطلوب';
                            if (v != _passwordController.text) return 'كلمتا المرور غير متطابقتين';
                            return null;
                          },
                        ),
                        if (_showOtpField) ..[
                          const SizedBox(height: 12),
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
                                    ? 'جاري إنشاء الحساب...'
                                    : 'إنشاء الحساب',
                                onPressed: loading ? null : _submit,
                                icon: Icons.person_add,
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                            child: const Text('لديك حساب؟ تسجيل الدخول'),
                          ),
                        ),
                      ],
                      ],
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
