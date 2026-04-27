import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Mencatat berapa kali user membuka tiap fitur/layanan.
/// Dipakai oleh:
///  - Maja AI: suggestion chip yang menyesuaikan kebiasaan user
///  - Profil: section "Aktivitas Terakhir" & "Statistik Bulan Ini"
class FeatureUsageService {
  FeatureUsageService._();

  static const String _kPrefix = 'feature_usage.';
  static const String _kMonthlyPrefix = 'feature_usage_monthly.';
  static const String _kRecentKey = 'feature_usage_recent';
  static const int _recentLimit = 20;

  /// Catat satu kali pembukaan fitur (idempotent terhadap kegagalan I/O).
  static Future<void> recordOpen(String featureId) async {
    final id = featureId.trim();
    if (id.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();

    // 1. Total all-time count
    final totalKey = '$_kPrefix$id';
    final total = prefs.getInt(totalKey) ?? 0;
    await prefs.setInt(totalKey, total + 1);

    // 2. Monthly count (key: feature_usage_monthly.YYYY-MM.<id>)
    final monthKey = '$_kMonthlyPrefix${_currentMonth()}.$id';
    final monthly = prefs.getInt(monthKey) ?? 0;
    await prefs.setInt(monthKey, monthly + 1);

    // 3. Recent opens — list JSON [{id, ts}], dedupe oleh id
    final now = DateTime.now().millisecondsSinceEpoch;
    final raw = prefs.getStringList(_kRecentKey) ?? const <String>[];
    final entries = raw
        .map((s) => jsonDecode(s) as Map<String, dynamic>)
        .where((m) => m['id'] != id)
        .toList();
    entries.insert(0, {'id': id, 'ts': now});
    final trimmed = entries.take(_recentLimit).toList();
    await prefs.setStringList(
      _kRecentKey,
      trimmed.map((m) => jsonEncode(m)).toList(),
    );
  }

  /// Top N fitur paling sering dibuka all-time, urut menurun.
  static Future<List<String>> topFeatures({int limit = 4}) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = prefs
        .getKeys()
        .where((k) =>
            k.startsWith(_kPrefix) && !k.startsWith(_kMonthlyPrefix))
        .map((k) => MapEntry(
              k.substring(_kPrefix.length),
              prefs.getInt(k) ?? 0,
            ))
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(limit).map((e) => e.key).toList();
  }

  /// 5 (atau N) layanan terakhir dibuka, urut paling baru.
  /// Mengembalikan list (featureId, timestamp).
  static Future<List<RecentOpen>> recentOpens({int limit = 5}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kRecentKey) ?? const <String>[];
    return raw.take(limit).map((s) {
      final m = jsonDecode(s) as Map<String, dynamic>;
      return RecentOpen(
        id: m['id'] as String,
        timestamp:
            DateTime.fromMillisecondsSinceEpoch(m['ts'] as int),
      );
    }).toList();
  }

  /// Berapa kali fitur dibuka di bulan berjalan.
  static Future<int> monthlyCount(String featureId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_kMonthlyPrefix${_currentMonth()}.$featureId') ?? 0;
  }

  /// Top N fitur bulan berjalan dengan count-nya.
  static Future<List<MonthlyStat>> topThisMonth({int limit = 3}) async {
    final prefs = await SharedPreferences.getInstance();
    final monthPrefix = '$_kMonthlyPrefix${_currentMonth()}.';
    final entries = prefs
        .getKeys()
        .where((k) => k.startsWith(monthPrefix))
        .map((k) => MapEntry(
              k.substring(monthPrefix.length),
              prefs.getInt(k) ?? 0,
            ))
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries
        .take(limit)
        .map((e) => MonthlyStat(id: e.key, count: e.value))
        .toList();
  }

  /// Kosongkan riwayat — dipanggil saat logout (bersama ProfileCache).
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs
        .getKeys()
        .where((k) =>
            k.startsWith(_kPrefix) || k.startsWith(_kMonthlyPrefix))
        .toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
    await prefs.remove(_kRecentKey);
  }

  static String _currentMonth() {
    final now = DateTime.now();
    final m = now.month.toString().padLeft(2, '0');
    return '${now.year}-$m';
  }
}

class RecentOpen {
  final String id;
  final DateTime timestamp;
  const RecentOpen({required this.id, required this.timestamp});
}

class MonthlyStat {
  final String id;
  final int count;
  const MonthlyStat({required this.id, required this.count});
}
