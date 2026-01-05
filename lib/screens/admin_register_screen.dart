import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wenh/cubits/admin_cubit.dart';
import 'package:wenh/cubits/admin_state.dart';
import 'package:wenh/core/theme/app_colors.dart';
import 'package:wenh/core/theme/app_icons.dart';
import 'package:wenh/widgets/professional_dialog.dart';

class AdminRegisterScreen extends StatefulWidget {
  const AdminRegisterScreen({super.key});

  @override
  State<AdminRegisterScreen> createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String _selectedCountryCode = '+966'; // Default Saudi Arabia

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: BlocListener<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state is AdminLoading) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
          }
          
          if (state is AdminAuthenticated) {
            ProfessionalDialog.showSuccess(
              context: context,
              title: 'تم إنشاء الحساب',
              message: 'تم إنشاء حساب المدير بنجاح',
            );
            Navigator.pushReplacementNamed(context, '/admin-login');
          } else if (state is AdminError) {
            ProfessionalDialog.showError(
              context: context,
              title: 'خطأ في إنشاء الحساب',
              message: state.message,
            );
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
                          'إنشاء حساب مدير',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'أدخل بياناتك لإنشاء حساب',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
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
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, -10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        
                        // Register Form
                        _buildRegisterCard(),
                        
                        const SizedBox(height: 24),
                        
                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'لديك حساب بالفعل؟',
                              style: TextStyle(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pushNamed(context, '/admin-login'),
                              child: Text(
                                'تسجيل الدخول',
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


  Widget _buildRegisterCard() {
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
            'إنشاء حساب مدير',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'قم بإنشاء حساب مدير جديد للوصول إلى لوحة التحكم',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'الاسم الكامل',
              prefixIcon: const Icon(Icons.person_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'يرجى إدخال الاسم الكامل';
              }
              return null;
            },
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
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
                  _obscurePassword ? AppIcons.visibilityOff : AppIcons.visibility,
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
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
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
          const SizedBox(height: 20),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirm,
            decoration: InputDecoration(
              labelText: 'تأكيد كلمة المرور',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? AppIcons.visibilityOff : AppIcons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirm = !_obscureConfirm;
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
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى تأكيد كلمة المرور';
              }
              if (value != _passwordController.text) {
                return 'كلمتا المرور غير متطابقتين';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          BlocBuilder<AdminCubit, AdminState>(
            builder: (context, state) {
              final loading = state is AdminLoading;
              return ElevatedButton(
                onPressed: loading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_add_rounded, size: 22),
                          SizedBox(width: 12),
                          Text(
                            'إنشاء الحساب',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              );
            },
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'لديك حساب؟ تسجيل الدخول',
              style: TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      debugPrint('[AdminRegisterScreen] Attempting registration for: ${_phoneController.text.trim()}');
      await context.read<AdminCubit>().registerWithPhone(
        phoneNumber: '$_selectedCountryCode${_phoneController.text.trim()}',
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );
    } catch (e, stackTrace) {
      debugPrint('[AdminRegisterScreen] _handleRegister error: $e');
      debugPrint('[AdminRegisterScreen] stackTrace: $stackTrace');
      if (mounted) {
        ProfessionalDialog.showError(
          context: context,
          title: 'خطأ في إنشاء الحساب',
          message: e.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
      size.width / 2,  // Control point x (middle of width)
      size.height * 1.1,  // Control point y (extends below to create curve)
      0,              // End point x (left edge)
      size.height * 0.7,  // End point y (same level as right side)
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
