import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_screen.dart';
import 'screens/admin_dashboard.dart';
import 'theme/theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: const DincoffApp(),
    ),
  );
}

class DincoffApp extends StatelessWidget {
  const DincoffApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return MaterialApp(
          title: 'Dincoff',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: appProvider.themeMode,
          initialRoute: '/main',
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/main': (context) => const MainScreen(),
            '/admin': (context) => const AdminDashboard(),
          },
        );
      },
    );
  }
}
