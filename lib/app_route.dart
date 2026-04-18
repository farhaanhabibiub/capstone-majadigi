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
import 'bapenda/bapenda_page.dart';
import 'bapenda/info_pajak_page.dart';
import 'bapenda/hasil_pajak_page.dart';
import 'bapenda/estimasi_njkb_page.dart';
import 'bapenda/hasil_njkb_page.dart';
import 'rsud/rsud_page.dart';
import 'rsud/ketersediaan_kamar_page.dart';
import 'rsud/jadwal_operasi_page.dart';
import 'rsud/info_antrean_page.dart';
import 'rsud/hospital_config.dart';
import 'transjatim/transjatim_page.dart';
import 'siskaperbapo/siskaperbapo_page.dart';
import 'etibi/etibi_page.dart';
import 'sapabansos/sapa_bansos_page.dart';

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
  static const String bapendaPage = '/bapendaPage';
  static const String infoPajakPage = '/infoPajakPage';
  static const String hasilPajakPage = '/hasilPajakPage';
  static const String estimasiNjkbPage = '/estimasiNjkbPage';
  static const String hasilNjkbPage = '/hasilNjkbPage';
  static const String rsudPage = '/rsudPage';
  static const String ketersediaanKamarPage = '/ketersediaanKamarPage';
  static const String jadwalOperasiPage = '/jadwalOperasiPage';
  static const String infoAntreanPage = '/infoAntreanPage';
  static const String transjatimPage = '/transjatimPage';
  static const String siskaperbapoPage = '/siskaperbapoPage';
  static const String etibiPage = '/etibiPage';
  static const String sapaBansosPage = '/sapaBansosPage';

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

      case bapendaPage:
        return MaterialPageRoute(
          builder: (_) => const BapendaPage(),
        );

      case infoPajakPage:
        return MaterialPageRoute(
          builder: (_) => const InfoPajakPage(),
        );

      case hasilPajakPage:
        final kendaraan = settings.arguments as KendaraanData;
        return MaterialPageRoute(
          builder: (_) => HasilPajakPage(data: kendaraan),
        );

      case estimasiNjkbPage:
        return MaterialPageRoute(
          builder: (_) => const EstimasiNjkbPage(),
        );

      case hasilNjkbPage:
        final hasil = settings.arguments as HasilNjkbData;
        return MaterialPageRoute(
          builder: (_) => HasilNjkbPage(data: hasil),
        );

      case rsudPage:
        final rsudHospital = settings.arguments as HospitalConfig;
        return MaterialPageRoute(
          builder: (_) => RsudPage(hospital: rsudHospital),
        );

      case ketersediaanKamarPage:
        final kamarHospital = settings.arguments as HospitalConfig;
        return MaterialPageRoute(
          builder: (_) => KetersediaanKamarPage(hospital: kamarHospital),
        );

      case jadwalOperasiPage:
        final jadwalHospital = settings.arguments as HospitalConfig;
        return MaterialPageRoute(
          builder: (_) => JadwalOperasiPage(hospital: jadwalHospital),
        );

      case infoAntreanPage:
        final antreanHospital = settings.arguments as HospitalConfig;
        return MaterialPageRoute(
          builder: (_) => InfoAntreanPage(hospital: antreanHospital),
        );

      case transjatimPage:
        return MaterialPageRoute(
          builder: (_) => const TransjatimPage(),
        );

      case siskaperbapoPage:
        return MaterialPageRoute(
          builder: (_) => const SiskaperbapoPage(),
        );

      case etibiPage:
        return MaterialPageRoute(
          builder: (_) => const EtibiPage(),
        );

      case sapaBansosPage:
        return MaterialPageRoute(
          builder: (_) => const SapaBansosPage(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
    }
  }
}