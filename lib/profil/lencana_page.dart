import 'package:flutter/material.dart';
import '../common/achievement_service.dart';
import '../common/streak_service.dart';
import '../theme/app_theme.dart';

class LencanaPage extends StatefulWidget {
  const LencanaPage({super.key});

  @override
  State<LencanaPage> createState() => _LencanaPageState();
}

class _LencanaPageState extends State<LencanaPage> {
  List<Achievement> _items = const [];
  StreakSnapshot? _streak;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      AchievementService.evaluate(),
      StreakService.read(),
    ]);
    if (!mounted) return;
    setState(() {
      _items = results[0] as List<Achievement>;
      _streak = results[1] as StreakSnapshot;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final unlockedCount = _items.where((a) => a.unlocked).length;
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textSecondary = AppTheme.textSecondaryOf(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundOf(context),
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceOf(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          tooltip: 'Kembali',
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Lencana Pencapaian',
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                // ── Streak hero ─────────────────────────────────────────
                _streakHero(),
                const SizedBox(height: 20),

                // ── Progres ─────────────────────────────────────────────
                Text(
                  '$unlockedCount dari ${_items.length} lencana terbuka',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 12),

                // ── Grid lencana ────────────────────────────────────────
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _items.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.95,
                  ),
                  itemBuilder: (_, i) => _badgeCard(_items[i]),
                ),
              ],
            ),
    );
  }

  Widget _streakHero() {
    final s = _streak!;
    final hasStreak = s.current > 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFB923C), Color(0xFFEF4444)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_fire_department_rounded,
                color: Colors.white, size: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasStreak
                      ? '${s.current} hari berturut-turut!'
                      : 'Mulai streak hari ini',
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasStreak
                      ? 'Streak terpanjang: ${s.longest} hari'
                      : 'Buka aplikasi setiap hari untuk membangun streak',
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badgeCard(Achievement a) {
    final surface = AppTheme.surfaceOf(context);
    final muted = AppTheme.textMutedOf(context);
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textSecondary = AppTheme.textSecondaryOf(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: a.unlocked
                  ? a.color.withValues(alpha: 0.15)
                  : muted.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              a.unlocked ? a.icon : Icons.lock_outline_rounded,
              color: a.unlocked ? a.color : muted,
              size: 22,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            a.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: a.unlocked ? textPrimary : muted,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              a.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 11,
                height: 1.4,
                color: textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: a.progress,
              minHeight: 4,
              backgroundColor: muted.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                a.unlocked ? a.color : AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
