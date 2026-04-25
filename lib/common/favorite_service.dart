import 'package:shared_preferences/shared_preferences.dart';

/// Lapisan tunggal untuk membaca/menulis status favorit layanan.
///
/// Semua key menggunakan format `fav_<slug>` (contoh: `fav_bapenda`).
/// Menjaga pattern yang sudah dipakai di kode lama agar preferensi
/// pengguna tidak hilang setelah refactor.
class FavoriteService {
  FavoriteService._();

  static Future<bool> isFavorite(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  static Future<void> setFavorite(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }
}
