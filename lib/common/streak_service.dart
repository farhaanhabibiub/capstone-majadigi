import 'package:shared_preferences/shared_preferences.dart';

/// Tracks daily login streak (gamifikasi ringan).
///
/// Aturan streak:
/// - Hari pertama → streak = 1
/// - Hari berikutnya berturut-turut → streak +1
/// - Selisih > 1 hari → streak reset ke 1
/// - Hari yang sama → tidak menambah, hanya touch lastVisit
class StreakService {
  StreakService._();

  static const _kCurrent = 'streak_current';
  static const _kLongest = 'streak_longest';
  static const _kLastVisit = 'streak_last_visit'; // yyyy-MM-dd

  /// Catat kunjungan hari ini & update streak. Idempotent dalam 1 hari.
  /// Mengembalikan snapshot streak setelah update.
  static Future<StreakSnapshot> recordVisit() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _today();
    final last = prefs.getString(_kLastVisit);
    int current = prefs.getInt(_kCurrent) ?? 0;
    int longest = prefs.getInt(_kLongest) ?? 0;

    if (last == today) {
      return StreakSnapshot(current: current, longest: longest, lastVisit: last);
    }

    if (last == null) {
      current = 1;
    } else {
      final lastDate = DateTime.parse(last);
      final todayDate = DateTime.parse(today);
      final diff = todayDate.difference(lastDate).inDays;
      if (diff == 1) {
        current += 1;
      } else {
        current = 1;
      }
    }

    if (current > longest) longest = current;

    await prefs.setString(_kLastVisit, today);
    await prefs.setInt(_kCurrent, current);
    await prefs.setInt(_kLongest, longest);

    return StreakSnapshot(current: current, longest: longest, lastVisit: today);
  }

  /// Baca streak tanpa mengubah apapun.
  static Future<StreakSnapshot> read() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getString(_kLastVisit);
    var current = prefs.getInt(_kCurrent) ?? 0;

    // Auto-decay: jika user terakhir kunjung > 1 hari lalu, streak putus,
    // tapi kita tahan sampai user actually visit hari ini (recordVisit)
    // agar nilai yang dibaca adalah "streak terakhir yang valid".
    if (last != null) {
      final lastDate = DateTime.parse(last);
      final todayDate = DateTime.parse(_today());
      final diff = todayDate.difference(lastDate).inDays;
      if (diff > 1) {
        current = 0;
      }
    }

    return StreakSnapshot(
      current: current,
      longest: prefs.getInt(_kLongest) ?? 0,
      lastVisit: last,
    );
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCurrent);
    await prefs.remove(_kLongest);
    await prefs.remove(_kLastVisit);
  }

  static String _today() {
    final now = DateTime.now();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '${now.year}-$m-$d';
  }
}

class StreakSnapshot {
  final int current;
  final int longest;
  final String? lastVisit;
  const StreakSnapshot({
    required this.current,
    required this.longest,
    required this.lastVisit,
  });
}
