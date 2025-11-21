import 'package:flutter/material.dart';

import 'theme/costealo_theme.dart';
import 'routes/app_routes.dart';

import 'screens/welcome/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_shell.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/sheets/new_sheet_screen.dart';
import 'screens/sheets/summary_screen.dart';
import 'screens/database/database_screen.dart';
import 'screens/database/database_selection_screen.dart';

class CostealoApp extends StatelessWidget {
  const CostealoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Costealo',
      debugShowCheckedModeBanner: false,
      theme: CostealoTheme.light,
      initialRoute: AppRoutes.welcome,
      routes: {
        AppRoutes.welcome: (_) => const WelcomeScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.home: (_) => const HomeShell(),

        AppRoutes.profile: (_) => const ProfileScreen(),
        AppRoutes.newSheet: (_) => const NewSheetScreen(),
        AppRoutes.summary: (_) => const SummaryScreen(),
        AppRoutes.database: (_) => const DatabaseSelectionScreen(),
        AppRoutes.databaseManual: (_) => const DatabaseScreen(),
      },
    );
  }
}
