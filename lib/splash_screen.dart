import 'dart:async';

import 'package:flutter/material.dart';

import 'app_route.dart';
import 'auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    // Tampilkan splash minimal 2 detik
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final user = AuthService.instance.currentUser;

    if (user == null) {
      // Belum login → onboarding
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      return;
    }

    // Sudah login → cek apakah onboarding sudah selesai
    final completed = await AuthService.instance.hasCompletedOnboarding();
    if (!mounted) return;

    if (completed) {
      Navigator.pushReplacementNamed(context, AppRoutes.berandaPage);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.personalizationLocationPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.asset(
        'assets/images/Splash Screen.png',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
