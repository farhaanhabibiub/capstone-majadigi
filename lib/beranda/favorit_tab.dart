import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_route.dart';
import '../common/share_service.dart';
import '../rsud/hospital_config.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/skeleton_loader.dart';

// ── Registry semua layanan yang bisa di-bookmark ───────────────────────────

class _BookmarkEntry {
  final String key;
  final String label;
  final String description;
  final String assetPath;
  final IconData fallback;
  final String route;
  final Object? arguments;

  const _BookmarkEntry({
    required this.key,
    required this.label,
    required this.description,
    required this.assetPath,
    required this.fallback,
    required this.route,
    this.arguments,
  });
}

const List<_BookmarkEntry> _kAllEntries = [
  _BookmarkEntry(
    key: 'fav_bapenda',
    label: 'BAPENDA',
    description: 'Informasi pajak kendaraan bermotor',
    assetPath: 'assets/images/layanan_bapenda.png',
    fallback: Icons.account_balance_rounded,
    route: AppRoutes.bapendaPage,
  ),
  _BookmarkEntry(
    key: 'fav_transjatim',
    label: 'Transjatim',
    description: 'Jadwal dan rute bus Trans Jawa Timur',
    assetPath: 'assets/images/layanan_transjatim.png',
    fallback: Icons.directions_bus_rounded,
    route: AppRoutes.transjatimPage,
  ),
  _BookmarkEntry(
    key: 'fav_siskaperbapo',
    label: 'SISKAPERBAPO',
    description: 'Harga bahan pokok Jawa Timur',
    assetPath: 'assets/images/layanan_siskaperbapo.png',
    fallback: Icons.storefront_rounded,
    route: AppRoutes.siskaperbapoPage,
  ),
  _BookmarkEntry(
    key: 'fav_etibi',
    label: 'E-TIBI',
    description: 'Layanan tuberkulosis terintegrasi',
    assetPath: 'assets/images/layanan_etibi.png',
    fallback: Icons.medical_services_rounded,
    route: AppRoutes.etibiPage,
  ),
  _BookmarkEntry(
    key: 'fav_sapabansos',
    label: 'SAPA BANSOS',
    description: 'Cek penerima bantuan sosial',
    assetPath: 'assets/images/layanan_sapa_bansos.png',
    fallback: Icons.volunteer_activism_rounded,
    route: AppRoutes.sapaBansosPage,
  ),
  _BookmarkEntry(
    key: 'fav_klinikhoaks',
    label: 'Klinik Hoaks',
    description: 'Laporkan dan cek berita hoaks',
    assetPath: 'assets/images/layanan_klinik_hoaks.png',
    fallback: Icons.fact_check_rounded,
    route: AppRoutes.klinikHoaksLandingPage,
  ),
  _BookmarkEntry(
    key: 'fav_opendata',
    label: 'Open Data',
    description: 'Data publik Provinsi Jawa Timur',
    assetPath: 'assets/images/layanan_open_data.png',
    fallback: Icons.dataset_rounded,
    route: AppRoutes.openDataLandingPage,
  ),
  _BookmarkEntry(
    key: 'fav_nomordarurat',
    label: 'Nomor Darurat',
    description: 'Kontak layanan darurat Jawa Timur',
    assetPath: 'assets/images/layanan_nomor_darurat.png',
    fallback: Icons.emergency_rounded,
    route: AppRoutes.nomorDaruratLandingPage,
  ),
  _BookmarkEntry(
    key: 'fav_rsud_daha_husada',
    label: 'RSUD Daha Husada',
    description: 'Layanan rumah sakit daerah Kediri',
    assetPath: 'assets/images/layanan_rsud.png',
    fallback: Icons.local_hospital_rounded,
    route: AppRoutes.rsudPage,
    arguments: HospitalConfig.dahaHusada,
  ),
  _BookmarkEntry(
    key: 'fav_rsud_saiful_anwar',
    label: 'RSUD Saiful Anwar',
    description: 'Layanan rumah sakit daerah Malang',
    assetPath: 'assets/images/layanan_rsud.png',
    fallback: Icons.local_hospital_rounded,
    route: AppRoutes.rsudPage,
    arguments: HospitalConfig.saifulAnwar,
  ),
  _BookmarkEntry(
    key: 'fav_rsud_karsa_husada',
    label: 'RSUD Karsa Husada',
    description: 'Layanan rumah sakit daerah Batu',
    assetPath: 'assets/images/layanan_rsud.png',
    fallback: Icons.local_hospital_rounded,
    route: AppRoutes.rsudPage,
    arguments: HospitalConfig.karsaHusada,
  ),
  _BookmarkEntry(
    key: 'fav_rsud_prov_jatim',
    label: 'RSUD Prov. Jatim',
    description: 'Layanan rumah sakit daerah Surabaya',
    assetPath: 'assets/images/layanan_rsud.png',
    fallback: Icons.local_hospital_rounded,
    route: AppRoutes.rsudPage,
    arguments: HospitalConfig.provJatim,
  ),
];

// ── Widget ─────────────────────────────────────────────────────────────────

class FavoritTab extends StatefulWidget {
  const FavoritTab({super.key});

  @override
  State<FavoritTab> createState() => _FavoritTabState();
}

class _FavoritTabState extends State<FavoritTab> {
  List<_BookmarkEntry> _saved = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved =
        _kAllEntries.where((e) => prefs.getBool(e.key) == true).toList();
    if (!mounted) return;
    setState(() {
      _saved = saved;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Layanan Tersimpan',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontFamily: AppTheme.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return SkeletonLoader.list(itemCount: 5);
    }

    if (_saved.isEmpty) {
      return EmptyState(
        icon: Icons.bookmark_border_rounded,
        title: 'Belum ada layanan tersimpan',
        subtitle:
            'Tekan ikon bookmark di halaman layanan\nuntuk menyimpannya di sini.',
        actionLabel: 'Jelajahi Layanan',
        onAction: () => Navigator.pushNamed(context, AppRoutes.tambahLayananPage)
            .then((_) => _load()),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: _saved.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _buildCard(context, _saved[index]),
    );
  }

  Widget _buildCard(BuildContext context, _BookmarkEntry entry) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        entry.route,
        arguments: entry.arguments,
      ).then((_) => _load()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Logo — sama persis dengan kartu layanan di beranda ──────────
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(235, 243, 255, 1),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                entry.assetPath,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) =>
                    Icon(entry.fallback, color: AppTheme.primary, size: 22),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.label,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    entry.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(
                  Icons.ios_share_rounded,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                tooltip: 'Bagikan layanan',
                onPressed: () => ShareService.shareLayanan(
                  label: entry.label,
                  description: entry.description,
                  context: ctx,
                ),
              ),
            ),
            const Icon(
              Icons.bookmark_rounded,
              color: AppTheme.primary,
              size: 22,
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
