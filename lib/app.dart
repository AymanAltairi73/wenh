import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cubits/request_cubit.dart';
import 'cubits/auth_cubit.dart';
import 'cubits/theme_cubit.dart';
import 'screens/role_selection.dart';
import 'screens/customer_home.dart';
import 'screens/send_request_screen.dart';
import 'screens/worker_login.dart';
import 'screens/worker_requests.dart';
import 'screens/admin_dashboard.dart';
import 'screens/register_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/customer_profile_screen.dart';
import 'screens/worker_profile_screen.dart';
import 'screens/admin_profile_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => RequestCubit()..getRequests()),
        BlocProvider(create: (_) => AuthCubit()),
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
        initialRoute: '/role',
            routes: {
              '/role': (_) => const RoleSelectionScreen(),
              '/': (_) => const CustomerHomeScreen(),
              '/send': (_) => const SendRequestScreen(),
              '/login': (_) => const WorkerLoginScreen(),
              '/register': (_) => const RegisterScreen(),
              '/worker': (_) => const WorkerRequestsScreen(),
              '/admin': (_) => const AdminDashboardScreen(),
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
