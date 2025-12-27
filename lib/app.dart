import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cubits/request_cubit.dart';
import 'cubits/auth_cubit.dart';
import 'cubits/admin_cubit.dart';
import 'cubits/theme_cubit.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/role_selection.dart';
// import 'screens/customer_home.dart';
import 'screens/enhanced_customer_home_screen.dart';
import 'screens/send_request_screen.dart';
import 'screens/worker_login.dart';
import 'screens/worker_requests.dart';
import 'screens/enhanced_worker_requests_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_register_screen.dart';
import 'screens/enhanced_admin_dashboard.dart';
import 'screens/admin_management_screen.dart';
import 'screens/register_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/customer_profile_screen.dart';
import 'screens/worker_profile_screen.dart';
import 'screens/admin_profile_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => RequestCubit()..getRequests()),
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => AdminCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'وينه',
            debugShowCheckedModeBanner: false,
            theme: themeState.themeData.copyWith(
              textTheme: GoogleFonts.tajawalTextTheme(themeState.themeData.textTheme),
            ),
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        initialRoute: '/splash',
            routes: {
              '/splash': (_) => const SplashScreen(),
              '/onboarding': (_) => const OnboardingScreen(),
              '/role': (_) => const RoleSelectionScreen(),
              //'/': (_) => const CustomerHomeScreen(),
              '/enhanced-home': (_) => const EnhancedCustomerHomeScreen(),
              '/send': (_) => const SendRequestScreen(),
              '/login': (_) => const WorkerLoginScreen(),
              '/register': (_) => const RegisterScreen(),
              '/worker': (_) => const WorkerRequestsScreen(),
              '/enhanced-worker': (_) => const EnhancedWorkerRequestsScreen(),
              '/admin': (_) => const AdminDashboardScreen(),
              '/admin-login': (_) => const AdminLoginScreen(),
              '/admin-register': (_) => const AdminRegisterScreen(),
              '/enhanced-admin': (_) => const EnhancedAdminDashboard(),
              '/admin-management': (_) => const AdminManagementScreen(),
              '/settings': (_) => const SettingsScreen(),
              '/customer-profile': (_) => const CustomerProfileScreen(),
              '/worker-profile': (_) => const WorkerProfileScreen(),
              '/admin-profile': (_) => const AdminProfileScreen(),
            },
          );
        },
      ),
    );
  }
}
