import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Layer tipis di atas `local_auth` untuk biometric login (sidik jari/wajah).
///
/// Kontrak keamanan:
/// - **Tidak menyimpan password.** Biometric hanya membuka kembali sesi
///   Firebase yang sudah aktif (persistent oleh Firebase Auth) — sehingga
///   yang dikunci adalah akses ke shell aplikasi, bukan kredensial.
/// - Disimpan: flag enabled + email yang ter-enroll. Jika user logout atau
///   ganti akun, biometric otomatis di-clear.
class BiometricService {
  BiometricService._();

  static const _kEnabled = 'biometric_enabled';
  static const _kEnrolledEmail = 'biometric_enrolled_email';

  static final LocalAuthentication _auth = LocalAuthentication();

  /// Apakah perangkat punya hardware biometric & user sudah enrol di OS.
  static Future<bool> isAvailable() async {
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) return false;
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) return false;
      final available = await _auth.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kEnabled) ?? false;
  }

  static Future<String?> enrolledEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kEnrolledEmail);
  }

  /// Aktifkan biometric untuk akun ini. Dipanggil setelah user
  /// berhasil login dengan email/password & memilih enroll.
  /// Pra-syarat: panggil [authenticate] dulu untuk konfirmasi.
  static Future<void> enable(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, true);
    await prefs.setString(_kEnrolledEmail, email.toLowerCase());
  }

  static Future<void> disable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, false);
    await prefs.remove(_kEnrolledEmail);
  }

  /// Prompt biometric. Mengembalikan true bila berhasil.
  static Future<bool> authenticate({
    String reason = 'Verifikasi identitas Anda untuk masuk ke Majadigi',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
