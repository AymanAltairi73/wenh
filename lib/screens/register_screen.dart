import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wenh/cubits/auth_cubit.dart';
import 'package:wenh/cubits/auth_state.dart';
import 'package:wenh/widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthCubit>().register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب')),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
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
                              gradient: LinearGradient(
                                colors: [Colors.teal, Colors.teal.shade300],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Column(
                              children: [
                                Hero(
                                  tag: 'app_logo',
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    height: 72,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.handyman, size: 56, color: Colors.white),
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
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'البريد الإلكتروني',
                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
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
                        CustomButton(label: 'إنشاء الحساب', onPressed: _submit, icon: Icons.person_add),
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
    );
  }
}
