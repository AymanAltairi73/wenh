import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wenh/cubits/auth_cubit.dart';
import 'package:wenh/cubits/auth_state.dart';
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
  bool _obscure1 = true;
  bool _obscure2 = true;
  String _selectedCountryCode = '+966'; // Default Saudi Arabia

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    try {
      if (!(_formKey.currentState?.validate() ?? false)) return;
      debugPrint('[RegisterScreen] Attempting registration for: ${_phoneController.text.trim()}');
      context.read<AuthCubit>().registerWithPhone(
        phoneNumber: '$_selectedCountryCode${_phoneController.text.trim()}',
        password: _passwordController.text,
        name: _nameController.text.trim(),
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
                                          color: Colors.white.withValues(alpha: 0.3),
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
                        const SizedBox(height: 24),
                        BlocBuilder<AuthCubit, AuthState>(
                          builder: (context, state) {
                            final loading = state is AuthLoading;
                            return CustomButton(
                              label: loading
                                  ? 'جاري إنشاء الحساب...'
                                  : 'إنشاء الحساب',
                              onPressed: loading ? null : _submit,
                              icon: Icons.person_add,
                            );
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
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
