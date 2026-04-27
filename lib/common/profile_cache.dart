import 'package:shared_preferences/shared_preferences.dart';

/// Cache lokal untuk data profil pengguna (lokasi & layanan tersimpan).
/// Dipakai sebagai fallback offline ketika Firestore tidak bisa dihubungi.
class ProfileCache {
  ProfileCache._();

  static const String _kLocationCity = 'profile_cache.location.city';
  static const String _kLocationRegency = 'profile_cache.location.regency';
  static const String _kAddedServices = 'profile_cache.added_services';

  // ── Lokasi ────────────────────────────────────────────────────────────────

  static Future<void> saveLocation({String? city, String? regency}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocationCity, city?.trim() ?? '');
    await prefs.setString(_kLocationRegency, regency?.trim() ?? '');
  }

  static Future<({String city, String regency})> getLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      city: prefs.getString(_kLocationCity) ?? '',
      regency: prefs.getString(_kLocationRegency) ?? '',
    );
  }

  // ── Layanan tersimpan ─────────────────────────────────────────────────────

  static Future<void> saveAddedServices(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kAddedServices, ids);
  }

  static Future<List<String>> getAddedServices() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_kAddedServices) ?? const [];
  }

  /// Hapus semua cache profil — dipanggil saat logout.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLocationCity);
    await prefs.remove(_kLocationRegency);
    await prefs.remove(_kAddedServices);
  }
}
