import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Layer tipis di atas `local_auth` untuk biometric login (sidik jari/wajah).
///
/// Kontrak keamanan:
/// - Password disimpan terenkripsi di Android Keystore / iOS Keychain
///   via `flutter_secure_storage`. Tidak bisa dibaca tanpa kunci OS.
/// - SharedPreferences hanya menyimpan flag enabled + email (bukan password).
/// - Saat user logout atau ganti akun, semua data biometric di-clear.
class BiometricService {
  BiometricService._();

  static const _kEnabled = 'biometric_enabled';
  static const _kEnrolledEmail = 'biometric_enrolled_email';
  static const _kPassword = 'biometric_password';

  static final LocalAuthentication _auth = LocalAuthentication();

  static const FlutterSecureStorage _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

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

  /// Password yang tersimpan di secure storage. Null jika tidak ada/sudah dihapus.
  static Future<String?> getStoredPassword() async {
    try {
      return await _secure.read(key: _kPassword);
    } catch (_) {
      return null;
    }
  }

  /// Aktifkan biometric untuk akun ini. Menyimpan password terenkripsi
  /// di Keystore sehingga login bisa dilakukan bahkan saat sesi Firebase habis.
  /// Pra-syarat: panggil [authenticate] dulu untuk konfirmasi identitas.
  static Future<void> enable(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, true);
    await prefs.setString(_kEnrolledEmail, email.toLowerCase());
    await _secure.write(key: _kPassword, value: password);
  }

  static Future<void> disable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, false);
    await prefs.remove(_kEnrolledEmail);
    try {
      await _secure.delete(key: _kPassword);
    } catch (_) {}
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
