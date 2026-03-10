import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'onboarding.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'verify_email_page.dart';
import 'forget_password.dart';
import 'email_sent_page.dart';
import 'personalization_location.dart';
import 'location_manual_page.dart';
import 'personalization_services_page.dart';
import 'personalization_success_page.dart';
import 'beranda/beranda_page.dart';

class AppRoutes {
  static const String splashScreen = '/';
  static const String onboarding = '/onboarding';
  static const String loginPage = '/loginPage';
  static const String registerPage = '/registerPage';
  static const String verifyEmailPage = '/verifyEmailPage';
  static const String forgetPasswordPage = '/forgetPasswordPage';
  static const String emailSentPage = '/emailSentPage';
  static const String personalizationLocationPage =
      '/personalizationLocationPage';
  static const String locationManualPage = '/locationManualPage';
  static const String personalizationServicesPage =
      '/personalizationServicesPage';
  static const String personalizationSuccessPage =
      '/personalizationSuccessPage';
  static const String berandaPage = '/berandaPage';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashScreen:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );

      case onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingPage(),
        );

      case loginPage:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );

      case registerPage:
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
        );

      case verifyEmailPage:
        final verifyArgs = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => VerifyEmailPage(
            email: verifyArgs['email'] as String? ?? '',
          ),
        );

      case forgetPasswordPage:
        return MaterialPageRoute(
          builder: (_) => const ForgetPasswordPage(),
        );

      case emailSentPage:
        final emailArgs = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => EmailSentPage(
            email: emailArgs['email'] as String? ?? '',
          ),
        );

      case personalizationLocationPage:
        return MaterialPageRoute(
          builder: (_) => const PersonalizationLocationPage(),
        );

      case locationManualPage:
        return MaterialPageRoute(
          builder: (_) => const LocationManualPage(),
        );

      case personalizationServicesPage:
        return MaterialPageRoute(
          builder: (_) => const PersonalizationServicesPage(),
        );

      case personalizationSuccessPage:
        return MaterialPageRoute(
          builder: (_) => const PersonalizationSuccessPage(),
        );

      case berandaPage:
        return MaterialPageRoute(
          builder: (_) => const BerandaPage(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
    }
  }
}