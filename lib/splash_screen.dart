import 'package:flutter/material.dart';
import 'app_route.dart';  // Pastikan path-nya benar

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Arahkan ke halaman Onboarding
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      },
      child: Scaffold(
        body: Center(
          child: Image.asset(
            'assets/images/Splash Screen.png',  // Gambar splash screen
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}