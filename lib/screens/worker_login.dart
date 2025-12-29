import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wenh/cubits/auth_cubit.dart';
import 'package:wenh/cubits/auth_state.dart';
import 'package:wenh/widgets/custom_button.dart';

class WorkerLoginScreen extends StatefulWidget {
  const WorkerLoginScreen({super.key});

  @override
  State<WorkerLoginScreen> createState() => _WorkerLoginScreenState();
}

class _WorkerLoginScreenState extends State<WorkerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    try {
      if ((_formKey.currentState?.validate() ?? false)) {
        debugPrint(
          '[WorkerLoginScreen] Attempting login for: ${_emailController.text.trim()}',
        );
        context.read<AuthCubit>().login(
          _emailController.text.trim(),
          _passwordController.text,
          rememberMe: _rememberMe,
          userType: 'worker',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('[WorkerLoginScreen] _login error: $e');
      debugPrint('[WorkerLoginScreen] stackTrace: $stackTrace');
    }
  }

  void _loginWithGoogle() {
    try {
      debugPrint('[WorkerLoginScreen] Attempting Google login');
      context.read<AuthCubit>().loginWithGoogle();
    } catch (e, stackTrace) {
      debugPrint('[WorkerLoginScreen] _loginWithGoogle error: $e');
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
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              child: Column(
                                children: [
                                  Hero(
                                    tag: 'app_logo',
                                    child: Image.asset(
                                      'assets/images/logo.png',
                                      height: 72,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.handyman,
                                        size: 56,
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
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'البريد الإلكتروني',
                              prefixIcon: Icon(Icons.email),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'مطلوب'
                                : null,
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
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(color: Colors.grey.shade400),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'أو',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ),
                              Expanded(
                                child: Divider(color: Colors.grey.shade400),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          BlocBuilder<AuthCubit, AuthState>(
                            builder: (context, state) {
                              final loading = state is AuthLoading;
                              return OutlinedButton.icon(
                                onPressed: loading ? null : _loginWithGoogle,
                                icon: Image.asset(
                                  'assets/images/logo.png',
                                  height: 24,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.g_mobiledata, size: 24),
                                ),
                                label: const Text('تسجيل الدخول بواسطة Google'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
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
