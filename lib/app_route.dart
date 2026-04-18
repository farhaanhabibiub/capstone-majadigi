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
import 'open_data_landing_page.dart';
import 'open_data_list_page.dart';
import 'open_data_dapurmbg.dart';
import 'open_data_ayopasok.dart';
import 'klinikhoaks_permohonan.dart';
import 'klinikhoaks_landing_page.dart';
import 'nomordarurat_landing_page.dart';
import 'nomordarurat_carinomor.dart';
import 'nomordarurat_informasi.dart';

class AppRoutes {
  static const String splashScreen = '/';
  static const String onboarding = '/onboarding';
  static const String loginPage = '/loginPage';
  static const String registerPage = '/registerPage';
  static const String verifyEmailPage = '/verifyEmailPage';
  static const String forgetPasswordPage = '/forgetPasswordPage';
  static const String emailSentPage = '/emailSentPage';
  static const String personalizationLocationPage = '/personalizationLocationPage';
  static const String locationManualPage = '/locationManualPage';
  static const String personalizationServicesPage = '/personalizationServicesPage';
  static const String personalizationSuccessPage = '/personalizationSuccessPage';
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
  static const String openDataLandingPage = '/openDataLandingPage';
  static const String openDataListPage = '/openDataListPage';
  static const String openDataDapurMBGPage = '/openDataDapurMBGPage';
  static const String openDataAyoPasokPage = '/openDataAyoPasokPage';
  static const String klinikHoaksPermohonanPage = '/klinikHoaksPermohonanPage';
  static const String klinikHoaksLandingPage = '/klinikHoaksLandingPage';
  static const String nomorDaruratLandingPage = '/nomorDaruratLandingPage';
  static const String nomorDaruratCariNomorPage = '/nomorDaruratCariNomorPage';
  static const String nomorDaruratInformasiPage = '/nomorDaruratInformasiPage';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());

      case loginPage:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case registerPage:
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case verifyEmailPage:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => VerifyEmailPage(email: args['email'] as String? ?? ''),
        );

      case forgetPasswordPage:
        return MaterialPageRoute(builder: (_) => const ForgetPasswordPage());

      case emailSentPage:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => EmailSentPage(email: args['email'] as String? ?? ''),
        );

      case personalizationLocationPage:
        return MaterialPageRoute(builder: (_) => const PersonalizationLocationPage());

      case locationManualPage:
        return MaterialPageRoute(builder: (_) => const LocationManualPage());

      case personalizationServicesPage:
        return MaterialPageRoute(builder: (_) => const PersonalizationServicesPage());

      case personalizationSuccessPage:
        return MaterialPageRoute(builder: (_) => const PersonalizationSuccessPage());

      case berandaPage:
        return MaterialPageRoute(builder: (_) => const BerandaPage());

      case bapendaPage:
        return MaterialPageRoute(builder: (_) => const BapendaPage());

      case infoPajakPage:
        return MaterialPageRoute(builder: (_) => const InfoPajakPage());

      case hasilPajakPage:
        final data = settings.arguments as KendaraanData;
        return MaterialPageRoute(builder: (_) => HasilPajakPage(data: data));

      case estimasiNjkbPage:
        return MaterialPageRoute(builder: (_) => const EstimasiNjkbPage());

      case hasilNjkbPage:
        final data = settings.arguments as HasilNjkbData;
        return MaterialPageRoute(builder: (_) => HasilNjkbPage(data: data));

      case rsudPage:
        final hospital = settings.arguments as HospitalConfig;
        return MaterialPageRoute(builder: (_) => RsudPage(hospital: hospital));

      case ketersediaanKamarPage:
        final hospital = settings.arguments as HospitalConfig;
        return MaterialPageRoute(builder: (_) => KetersediaanKamarPage(hospital: hospital));

      case jadwalOperasiPage:
        final hospital = settings.arguments as HospitalConfig;
        return MaterialPageRoute(builder: (_) => JadwalOperasiPage(hospital: hospital));

      case infoAntreanPage:
        final hospital = settings.arguments as HospitalConfig;
        return MaterialPageRoute(builder: (_) => InfoAntreanPage(hospital: hospital));

      case transjatimPage:
        return MaterialPageRoute(builder: (_) => const TransjatimPage());

      case siskaperbapoPage:
        return MaterialPageRoute(builder: (_) => const SiskaperbapoPage());

      case etibiPage:
        return MaterialPageRoute(builder: (_) => const EtibiPage());

      case sapaBansosPage:
        return MaterialPageRoute(builder: (_) => const SapaBansosPage());

      case openDataLandingPage:
        return MaterialPageRoute(builder: (_) => const OpenDataLandingPage());

      case openDataListPage:
        return MaterialPageRoute(builder: (_) => const OpenDataListPage());

      case openDataDapurMBGPage:
        return MaterialPageRoute(builder: (_) => const OpenDataDapurMBGPage());

      case openDataAyoPasokPage:
        return MaterialPageRoute(builder: (_) => const OpenDataAyoPasokPage());

      case klinikHoaksPermohonanPage:
        return MaterialPageRoute(builder: (_) => const KlinikHoaksPermohonanPage());

      case klinikHoaksLandingPage:
        return MaterialPageRoute(builder: (_) => const KlinikHoaksLandingPage());

      case nomorDaruratLandingPage:
        return MaterialPageRoute(builder: (_) => const NomorDaruratLandingPage());

      case nomorDaruratCariNomorPage:
        return MaterialPageRoute(builder: (_) => const NomorDaruratCariNomorPage());

      case nomorDaruratInformasiPage:
        return MaterialPageRoute(builder: (_) => const NomorDaruratInformasiPage());

      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
