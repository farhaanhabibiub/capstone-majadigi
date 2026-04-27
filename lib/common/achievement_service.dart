import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../beranda/feature_usage_service.dart';
import 'streak_service.dart';

/// Lencana pencapaian — gamifikasi ringan untuk meningkatkan engagement.
///
/// Lencana dievaluasi dari kombinasi streak + jumlah fitur unik dipakai +
/// total open. Tidak menyimpan state per-lencana; semua diturunkan dari
/// data eksisting (streak + feature usage) untuk hindari sumber kebenaran ganda.
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool unlocked;
  final double progress; // 0.0 - 1.0

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.unlocked,
    required this.progress,
  });
}

class AchievementService {
  AchievementService._();

  static Future<List<Achievement>> evaluate() async {
    final streak = await StreakService.read();
    final prefs = await SharedPreferences.getInstance();

    // Hitung jumlah fitur unik yang pernah dibuka & total opens
    int uniqueFeatures = 0;
    int totalOpens = 0;
    for (final k in prefs.getKeys()) {
      if (k.startsWith('feature_usage.') &&
          !k.startsWith('feature_usage_monthly.')) {
        final c = prefs.getInt(k) ?? 0;
        if (c > 0) {
          uniqueFeatures++;
          totalOpens += c;
        }
      }
    }
    // Manfaatkan helper monthly untuk verifikasi keys (tidak perlu dipakai)
    await FeatureUsageService.topThisMonth(limit: 1);

    return [
      _streakAchievement(
        id: 'first_step',
        title: 'Langkah Pertama',
        description: 'Login pertama kali',
        icon: Icons.flag_rounded,
        color: const Color(0xFF22C55E),
        target: 1,
        current: streak.current,
      ),
      _streakAchievement(
        id: 'streak_3',
        title: '3 Hari Berturut',
        description: 'Buka aplikasi 3 hari berturut-turut',
        icon: Icons.local_fire_department_rounded,
        color: const Color(0xFFFB923C),
        target: 3,
        current: streak.current,
      ),
      _streakAchievement(
        id: 'streak_7',
        title: 'Seminggu Aktif',
        description: 'Streak 7 hari',
        icon: Icons.whatshot_rounded,
        color: const Color(0xFFEF4444),
        target: 7,
        current: streak.current,
      ),
      _streakAchievement(
        id: 'streak_30',
        title: 'Sebulan Aktif',
        description: 'Streak 30 hari — luar biasa!',
        icon: Icons.emoji_events_rounded,
        color: const Color(0xFFFACC15),
        target: 30,
        current: streak.current,
      ),
      _counterAchievement(
        id: 'explorer',
        title: 'Penjelajah',
        description: 'Coba 5 layanan berbeda',
        icon: Icons.travel_explore_rounded,
        color: const Color(0xFF3B82F6),
        target: 5,
        current: uniqueFeatures,
      ),
      _counterAchievement(
        id: 'power_user',
        title: 'Pengguna Aktif',
        description: 'Akses layanan 50 kali total',
        icon: Icons.bolt_rounded,
        color: const Color(0xFF8B5CF6),
        target: 50,
        current: totalOpens,
      ),
      _counterAchievement(
        id: 'loyal',
        title: 'Loyal',
        description: 'Streak terpanjang capai 14 hari',
        icon: Icons.workspace_premium_rounded,
        color: const Color(0xFFEC4899),
        target: 14,
        current: streak.longest,
      ),
    ];
  }

  static Achievement _streakAchievement({
    required String id,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required int target,
    required int current,
  }) {
    final unlocked = current >= target;
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      color: color,
      unlocked: unlocked,
      progress: (current / target).clamp(0.0, 1.0),
    );
  }

  static Achievement _counterAchievement({
    required String id,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required int target,
    required int current,
  }) {
    final unlocked = current >= target;
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      color: color,
      unlocked: unlocked,
      progress: (current / target).clamp(0.0, 1.0),
    );
  }
}
