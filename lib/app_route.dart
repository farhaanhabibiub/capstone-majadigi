import 'package:flutter/material.dart';
import 'app_transitions.dart';
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
import 'beranda/notifikasi_page.dart';
import 'beranda/tambah_layanan_page.dart';
import 'beranda/maja_ai_chat_page.dart';
import 'beranda/global_search_page.dart';
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
import 'admin/admin_page.dart';
import 'admin/admin_notifikasi_page.dart';
import 'admin/admin_session_guard.dart';
import 'admin/audit_log_page.dart';
import 'profil/ubah_profil_page.dart';
import 'profil/keamanan_akun_page.dart';
import 'profil/aksesibilitas_page.dart';
import 'profil/lencana_page.dart';
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
  static const String tambahLayananPage = '/tambahLayananPage';
  static const String majaAiChatPage = '/majaAiChatPage';
  static const String globalSearchPage = '/globalSearchPage';
  static const String notifikasiPage = '/notifikasiPage';
  static const String adminPage = '/adminPage';
  static const String adminNotifikasiPage = '/adminNotifikasiPage';
  static const String auditLogPage = '/auditLogPage';
  static const String ubahProfilPage = '/ubahProfilPage';
  static const String keamananAkunPage = '/keamananAkunPage';
  static const String aksesibilitasPage = '/aksesibilitasPage';
  static const String lencanaPage = '/lencanaPage';

  /// Routes yang muncul "menumpuk" tanpa arah spasial → pakai fade.
  /// Sisanya pakai slide forward.
  static const Set<String> _fadeRoutes = {
    splashScreen,
    onboarding,
    emailSentPage,
    personalizationSuccessPage,
    hasilPajakPage,
    hasilNjkbPage,
    majaAiChatPage,
    globalSearchPage,
    notifikasiPage,
    adminNotifikasiPage,
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final builder = _builderFor(settings);
    final isFade = _fadeRoutes.contains(settings.name);
    if (isFade) {
      return FadePageRoute(builder: builder, settings: settings);
    }
    return SlidePageRoute(builder: builder, settings: settings);
  }

  static WidgetBuilder _builderFor(RouteSettings settings) {
    switch (settings.name) {
      case splashScreen:
        return (_) => const SplashScreen();

      case onboarding:
        return (_) => const OnboardingPage();

      case loginPage:
        return (_) => const LoginPage();

      case registerPage:
        return (_) => const RegisterPage();

      case verifyEmailPage:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return (_) => VerifyEmailPage(email: args['email'] as String? ?? '');

      case forgetPasswordPage:
        return (_) => const ForgetPasswordPage();

      case emailSentPage:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return (_) => EmailSentPage(email: args['email'] as String? ?? '');

      case personalizationLocationPage:
        return (_) => const PersonalizationLocationPage();

      case locationManualPage:
        return (_) => const LocationManualPage();

      case personalizationServicesPage:
        return (_) => const PersonalizationServicesPage();

      case personalizationSuccessPage:
        return (_) => const PersonalizationSuccessPage();

      case berandaPage:
        return (_) => const BerandaPage();

      case bapendaPage:
        return (_) => const BapendaPage();

      case infoPajakPage:
        return (_) => const InfoPajakPage();

      case hasilPajakPage:
        final data = settings.arguments as KendaraanData;
        return (_) => HasilPajakPage(data: data);

      case estimasiNjkbPage:
        return (_) => const EstimasiNjkbPage();

      case hasilNjkbPage:
        final data = settings.arguments as HasilNjkbData;
        return (_) => HasilNjkbPage(data: data);

      case rsudPage:
        final hospital = settings.arguments as HospitalConfig;
        return (_) => RsudPage(hospital: hospital);

      case ketersediaanKamarPage:
        final hospital = settings.arguments as HospitalConfig;
        return (_) => KetersediaanKamarPage(hospital: hospital);

      case jadwalOperasiPage:
        final hospital = settings.arguments as HospitalConfig;
        return (_) => JadwalOperasiPage(hospital: hospital);

      case infoAntreanPage:
        final hospital = settings.arguments as HospitalConfig;
        return (_) => InfoAntreanPage(hospital: hospital);

      case transjatimPage:
        return (_) => const TransjatimPage();

      case siskaperbapoPage:
        return (_) => const SiskaperbapoPage();

      case etibiPage:
        return (_) => const EtibiPage();

      case sapaBansosPage:
        return (_) => const SapaBansosPage();

      case openDataLandingPage:
        return (_) => const OpenDataLandingPage();

      case openDataListPage:
        return (_) => const OpenDataListPage();

      case openDataDapurMBGPage:
        return (_) => const OpenDataDapurMBGPage();

      case openDataAyoPasokPage:
        return (_) => const OpenDataAyoPasokPage();

      case klinikHoaksPermohonanPage:
        return (_) => const KlinikHoaksPermohonanPage();

      case klinikHoaksLandingPage:
        return (_) => const KlinikHoaksLandingPage();

      case nomorDaruratLandingPage:
        return (_) => const NomorDaruratLandingPage();

      case nomorDaruratCariNomorPage:
        return (_) => const NomorDaruratCariNomorPage();

      case nomorDaruratInformasiPage:
        return (_) => const NomorDaruratInformasiPage();

      case tambahLayananPage:
        return (_) => const TambahLayananPage();

      case majaAiChatPage:
        return (_) => const MajaAiChatPage();

      case globalSearchPage:
        return (_) => const GlobalSearchPage();

      case notifikasiPage:
        return (_) => const NotifikasiPage();

      case adminPage:
        return (_) => const AdminSessionGuard(child: AdminPage());

      case adminNotifikasiPage:
        return (_) => const AdminSessionGuard(child: AdminNotifikasiPage());

      case auditLogPage:
        return (_) => const AdminSessionGuard(child: AuditLogPage());

      case ubahProfilPage:
        return (_) => const UbahProfilPage();

      case keamananAkunPage:
        return (_) => const KeamananAkunPage();

      case aksesibilitasPage:
        return (_) => const AksesibilitasPage();

      case lencanaPage:
        return (_) => const LencanaPage();

      default:
        return (_) => const SplashScreen();
    }
  }
}
