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
  bool _obscure = true;
  bool _rememberMe = true;
  String _selectedCountryCode = '+966'; // Default Saudi Arabia

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    try {
      if ((_formKey.currentState?.validate() ?? false)) {
        debugPrint(
          '[WorkerLoginScreen] Attempting login for: ${_phoneController.text.trim()}',
        );
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
                          const SizedBox(height: 24),
                          BlocBuilder<AuthCubit, AuthState>(
                            builder: (context, state) {
                              final loading = state is AuthLoading;
                              return CustomButton(
                                label: loading
                                    ? 'جاري تسجيل الدخول...'
                                    : 'تسجيل الدخول',
                                onPressed: loading ? null : _login,
                                icon: Icons.login,
                              );
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
