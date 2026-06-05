import 'package:flutter/material.dart';
import 'package:hostel_booking/features/auth/presentation/pages/login_page.dart';
import 'package:hostel_booking/features/auth/presentation/pages/signup_page.dart';
import 'package:hostel_booking/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:hostel_booking/features/splash/presentation/pages/dashboard_page.dart';
import 'package:hostel_booking/features/splash/presentation/pages/splash_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F51B5)),
        useMaterial3: true,
      ),
      home: const SplashPage(),
      routes: {
        '/onboarding': (_) => const OnboardingPage(),
        '/login': (_) => const LoginPage(),
        '/signup': (_) => const SignupPage(),
        '/dashboard': (_) => const DashboardPage(),
      },
    );
  }
}
