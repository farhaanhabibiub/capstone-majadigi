import 'package:firebase_auth/firebase_auth.dart';
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
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null || !user.emailVerified) {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      return;
    }

    // Cek apakah user sudah selesai onboarding (lokasi sudah diisi)
    final profile = await AuthService.instance.getUserProfile();
    if (!mounted) return;

    final location = profile?['location'] as Map<String, dynamic>?;
    final hasLocation = (location?['regency'] as String?)?.isNotEmpty == true;

    if (!hasLocation) {
      Navigator.pushReplacementNamed(context, AppRoutes.personalizationLocationPage);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.berandaPage);
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
