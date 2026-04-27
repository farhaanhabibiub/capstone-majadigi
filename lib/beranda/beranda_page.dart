import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_route.dart';
import '../app_transitions.dart';
import '../auth_service.dart';
import '../common/profile_cache.dart';
import '../common/streak_service.dart';
import '../theme/app_theme.dart';
import '../rsud/hospital_config.dart';
import 'favorit_tab.dart';
import 'feature_usage_service.dart';
import 'notifikasi_service.dart';
import 'service_registry.dart';
import '../profil/profil_tab.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  int _selectedIndex = 0;
  int _unreadCount = 0;
  String _locationText = '...';
  String _locationCity = '';
  String _locationRegency = '';
  List<AddableService> _addedServices = [];
  List<_ShortcutItem> _shortcuts = const [];

  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _whiteBg = Color.fromRGBO(248, 248, 245, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);

  static const List<_ServiceItem> _services = [
    _ServiceItem(
      id: 'bapenda',
      label: 'BAPENDA',
      assetPath: 'assets/images/layanan_bapenda.png',
      fallback: Icons.account_balance_rounded,
      route: AppRoutes.bapendaPage,
    ),
    _ServiceItem(
      id: 'rsud',
      label: 'RSUD',
      assetPath: 'assets/images/layanan_rsud.png',
      fallback: Icons.local_hospital_rounded,
    ),
    _ServiceItem(
      id: 'transjatim',
      label: 'Transjatim',
      assetPath: 'assets/images/layanan_transportasi.png',
      fallback: Icons.directions_bus_rounded,
      route: AppRoutes.transjatimPage,
    ),
    _ServiceItem(
      id: 'siskaperbapo',
      label: 'SISKAPERBAPO',
      assetPath: 'assets/images/layanan_siskaperbapo.png',
      fallback: Icons.storefront_rounded,
      route: AppRoutes.siskaperbapoPage,
    ),
    _ServiceItem(
      id: 'nomor_darurat',
      label: 'Nomor Darurat',
      assetPath: 'assets/images/layanan_nomor_darurat.png',
      fallback: Icons.emergency_rounded,
      route: AppRoutes.nomorDaruratLandingPage,
    ),
  ];

  static const List<_ArtikelItem> _artikels = [
    _ArtikelItem(
      tag: 'TEKNOLOGI',
      tagColor: Color.fromRGBO(0, 101, 255, 1),
      title: 'BAPENDA Jatim Luncurkan Fitur Pembayaran Digital',
      assetPath: 'assets/images/artikel_1.png',
      date: '11 April 2026',
      url: 'https://rri.co.id/surabaya/regional/1189034/bapenda-jatim-mudahkan-bayar-pajak-dengan-inovasi-digital',
    ),
    _ArtikelItem(
      tag: 'KEBIJAKAN',
      tagColor: Color.fromRGBO(202, 138, 4, 1),
      title: 'Update Aturan Pajak Kendaraan Bermotor 2026',
      assetPath: 'assets/images/artikel_2.png',
      date: '15 Maret 2026',
      url: 'https://nasional.kontan.co.id/news/resmi-berlaku-april-2026-pajak-mobil-motor-listrik-tak-lagi-rp-0-ini-aturannya',
    ),
    _ArtikelItem(
      tag: 'LAYANAN',
      tagColor: Color.fromRGBO(13, 148, 136, 1),
      title: 'Integrasi Layanan Kesehatan RSUD Dr. Soetomo',
      assetPath: 'assets/images/artikel_3.png',
      date: '15 Maret 2026',
      url: 'https://rsudrsoetomo.jatimprov.go.id/',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _hydrateFromCache();
    _loadUserProfile();
    _loadUnreadCount();
    _loadShortcuts();
    StreakService.recordVisit();
  }

  Future<void> _loadShortcuts() async {
    final prefs = await SharedPreferences.getInstance();
    final items = _kShortcutCatalog
        .where((e) => prefs.getBool(e.bookmarkKey) == true)
        .take(4)
        .toList();
    if (!mounted) return;
    setState(() => _shortcuts = items);
  }

  Future<void> _loadUnreadCount() async {
    final count = await NotifikasiService.getUnreadCount();
    if (mounted) setState(() => _unreadCount = count);
  }

  // Tampilkan data terakhir dari cache lokal lebih dulu agar UI tidak kosong
  // saat offline / fetch Firestore lambat.
  Future<void> _hydrateFromCache() async {
    final loc = await ProfileCache.getLocation();
    final cachedIds = await ProfileCache.getAddedServices();
    if (!mounted) return;
    setState(() {
      _locationCity = loc.city;
      _locationRegency = loc.regency;
      _locationText = _formatLocation(loc.city, loc.regency);
      _addedServices = cachedIds
          .map((id) => ServiceRegistry.findById(id))
          .whereType<AddableService>()
          .toList();
    });
  }

  Future<void> _loadUserProfile() async {
    final profile = await AuthService.instance.getUserProfile();
    if (!mounted) return;

    // Profile null = sesi habis atau gagal dari Firestore.
    // Biarkan state dari cache yang sudah di-hydrate.
    if (profile == null) return;

    final location = profile['location'] as Map<String, dynamic>?;
    final city = (location?['city'] as String?) ?? '';
    final regency = (location?['regency'] as String?) ?? '';

    final savedIds = (profile['addedServices'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const <String>[];

    setState(() {
      _locationCity = city;
      _locationRegency = regency;
      _locationText = _formatLocation(city, regency);
      _addedServices = savedIds
          .map((id) => ServiceRegistry.findById(id))
          .whereType<AddableService>()
          .toList();
    });

    // Persist ke cache untuk akses offline berikutnya.
    await ProfileCache.saveLocation(city: city, regency: regency);
    await ProfileCache.saveAddedServices(savedIds);
  }

  String _formatLocation(String city, String regency) {
    if (city.isNotEmpty && regency.isNotEmpty) return '$city, $regency';
    if (regency.isNotEmpty) return regency;
    if (city.isNotEmpty) return city;
    return 'Lokasi belum diatur';
  }

  void _navigateToRsud() {
    FeatureUsageService.recordOpen('rsud');
    final hospital = HospitalConfig.forLocation(_locationCity, _locationRegency);
    Navigator.pushNamed(context, AppRoutes.rsudPage, arguments: hospital);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _whiteBg,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // ── Konten utama ─────────────────────────────────────────
            Positioned.fill(
              child: _selectedIndex == 1
                  ? const FavoritTab()
                  : _selectedIndex == 2
                      ? const ProfilTab()
                      : Column(
                          children: [
                            _buildHeader(),
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.only(bottom: 28),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 12),
                                    _buildSearchBar(),
                                    const SizedBox(height: 16),
                                    _buildWelcomeBanner(),
                                    if (_shortcuts.isNotEmpty) ...[
                                      const SizedBox(height: 20),
                                      _buildShortcuts(),
                                    ],
                                    const SizedBox(height: 24),
                                    _buildLayananUnggulan(),
                                    const SizedBox(height: 24),
                                    _buildBeritaArtikel(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
            ),
            // ── Maja AI — selalu 4 px di atas navbar ─────────────────
            _buildMajaAI(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: [
          Hero(
            tag: HeroTags.profileAvatar,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: const Color.fromRGBO(220, 232, 255, 1),
              child: Image.asset(
                'assets/images/avatar_placeholder.png',
                width: 44,
                height: 44,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.person_rounded,
                  color: _blue,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lokasi Saat Ini:',
                  style: TextStyle(
                    color: _textSecondary,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _locationText,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: _textPrimary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            button: true,
            label: _unreadCount > 0
                ? 'Notifikasi, $_unreadCount belum dibaca'
                : 'Notifikasi',
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.notifikasiPage)
                  .then((_) => _loadUnreadCount()),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: _textPrimary,
                      size: 20,
                    ),
                  ),
                if (_unreadCount > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text(
                        _unreadCount > 99 ? '99+' : '$_unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'PlusJakartaSans',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search Bar (Global Search) ────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Semantics(
        button: true,
        label: 'Cari layanan',
        hint: 'Buka pencarian layanan, rumah sakit, hoaks, atau data',
        child: GestureDetector(
        onTap: () =>
            Navigator.pushNamed(context, AppRoutes.globalSearchPage),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(23),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: const [
              Icon(Icons.search_rounded, color: _textSecondary, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Cari layanan, RSUD, hoaks, data…',
                  style: TextStyle(
                    color: _textSecondary,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.tune_rounded, color: _textSecondary, size: 18),
            ],
          ),
        ),
      ),
      ),
    );
  }

  // ── Welcome Banner ────────────────────────────────────────────────────────

  Widget _buildWelcomeBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _blue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat Datang,\nWarga Jatim!',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'PlusJakartaSans',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Akses berbagai layanan pemerintah Provinsi Jawa Timur dengan mudah, cepat, dan aman melalui Majadigi.',
              style: TextStyle(
                color: Colors.white70,
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Akses Cepat (Shortcut Layanan Favorit) ────────────────────────────────

  Widget _buildShortcuts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Akses Cepat',
                  style: TextStyle(
                    color: _textPrimary,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _selectedIndex = 1),
                child: const Text(
                  'Kelola',
                  style: TextStyle(
                    color: _blue,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _shortcuts.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _buildShortcutChip(_shortcuts[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildShortcutChip(_ShortcutItem item) {
    return Semantics(
      button: true,
      label: 'Akses cepat ke ${item.label}',
      child: GestureDetector(
        onTap: () {
          FeatureUsageService.recordOpen(item.trackId);
          Navigator.pushNamed(context, item.route)
              .then((_) => _loadShortcuts());
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(235, 243, 255, 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(6),
                child: Image.asset(
                  item.assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) =>
                      Icon(item.fallback, color: _blue, size: 18),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                item.label,
                style: const TextStyle(
                  color: _textPrimary,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Layanan Unggulan ──────────────────────────────────────────────────────

  Widget _buildLayananUnggulan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Layanan Unggulan',
            style: TextStyle(
              color: _textPrimary,
              fontFamily: 'PlusJakartaSans',
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _services.length + _addedServices.length + 1,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              if (index < _services.length) {
                return _buildServiceCard(_services[index]);
              }
              final addedIndex = index - _services.length;
              if (addedIndex < _addedServices.length) {
                return _buildAddedServiceCard(_addedServices[addedIndex]);
              }
              return _buildTambahLayananCard();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(_ServiceItem item) {
    final isRsud = item.label == 'RSUD';
    final displayLabel = isRsud
        ? HospitalConfig.forLocation(_locationCity, _locationRegency).name
        : item.label;

    final VoidCallback? onTap = isRsud
        ? _navigateToRsud
        : item.route != null
            ? () {
                FeatureUsageService.recordOpen(item.id);
                Navigator.pushNamed(context, item.route!);
              }
            : null;

    return Semantics(
      button: true,
      label: 'Layanan $displayLabel',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: HeroTags.serviceCard(item.id),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(235, 243, 255, 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    item.assetPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      item.fallback,
                      color: _blue,
                      size: 26,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  displayLabel,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddedServiceCard(AddableService item) {
    // Catat dengan id 'rsud' untuk RSUD apa pun agar suggestion AI menyatu.
    final String trackId = item.hospital != null ? 'rsud' : item.id;
    final VoidCallback? onTap = item.hospital != null
        ? () {
            FeatureUsageService.recordOpen(trackId);
            Navigator.pushNamed(context, AppRoutes.rsudPage,
                arguments: item.hospital);
          }
        : item.route != null
            ? () {
                FeatureUsageService.recordOpen(trackId);
                Navigator.pushNamed(context, item.route!);
              }
            : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: HeroTags.serviceCard(item.id),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(235, 243, 255, 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  item.assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(item.fallback, color: _blue, size: 26),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _textPrimary,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTambahLayananCard() {
    return Semantics(
      button: true,
      label: 'Tambah Layanan',
      hint: 'Buka daftar layanan tambahan',
      child: GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.tambahLayananPage)
          .then((_) { if (mounted) _loadUserProfile(); }),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: HeroTags.serviceCard('tambah_layanan'),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(235, 243, 255, 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  'assets/images/icon_tambah_layanan.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.add_rounded,
                    color: _blue,
                    size: 26,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Tambah Layanan',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _textPrimary,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  // ── Berita & Artikel ──────────────────────────────────────────────────────

  Widget _buildBeritaArtikel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Berita & Artikel',
                  style: TextStyle(
                    color: _textPrimary,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    color: _blue,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _artikels.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) => _buildArtikelCard(_artikels[index]),
        ),
      ],
    );
  }

  Widget _buildArtikelCard(_ArtikelItem item) {
    return Semantics(
      button: true,
      label: 'Artikel ${item.tag}: ${item.title}, ${item.date}',
      hint: 'Buka artikel di browser',
      child: GestureDetector(
      onTap: () async {
        final uri = Uri.parse(item.url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
            child: Image.asset(
              item.assetPath,
              width: 92,
              height: 92,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 92,
                height: 92,
                color: const Color.fromRGBO(220, 232, 255, 1),
                child: const Icon(Icons.article_rounded, color: _blue, size: 32),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: item.tagColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.tag,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _textPrimary,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 10, color: _textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        item.date,
                        style: const TextStyle(
                          color: _textSecondary,
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    ),
    ),
    );
  }

  // ── Maja AI ───────────────────────────────────────────────────────────────

  Widget _buildMajaAI() {
    return Positioned(
      right: 0,
      bottom: 16,
      child: Semantics(
        button: true,
        label: 'Maja AI',
        hint: 'Buka asisten Maja AI untuk bertanya seputar layanan',
        child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.majaAiChatPage),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Speech bubble ──────────────────────────────────────────
            Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              constraints: const BoxConstraints(maxWidth: 136),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo! Butuh bantuan?',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Tanya Maja AI →',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            // ── Segitiga ekor bubble ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(right: 28),
              child: CustomPaint(
                painter: _BubbleTailPainter(),
                child: const SizedBox(width: 14, height: 7),
              ),
            ),
            // ── Karakter Maja AI ───────────────────────────────────────
            ExcludeSemantics(
              child: Image.asset(
                'assets/images/maja_ai.png',
                width: 90,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  // ── Bottom Navigation Bar ─────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.07),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomNavItem(
                icon: Icons.home_rounded,
                label: 'Beranda',
                isActive: _selectedIndex == 0,
                onTap: () => setState(() => _selectedIndex = 0),
              ),
              _BottomNavItem(
                icon: Icons.bookmark_outline_rounded,
                activeIcon: Icons.bookmark_rounded,
                label: 'Favorit',
                isActive: _selectedIndex == 1,
                onTap: () => setState(() => _selectedIndex = 1),
              ),
              _BottomNavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profil',
                isActive: _selectedIndex == 2,
                onTap: () => setState(() => _selectedIndex = 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Data Models ───────────────────────────────────────────────────────────────

class _ServiceItem {
  final String id;
  final String label;
  final String assetPath;
  final IconData fallback;
  final String? route;

  const _ServiceItem({
    required this.id,
    required this.label,
    required this.assetPath,
    required this.fallback,
    this.route,
  });
}

class _ArtikelItem {
  final String tag;
  final Color tagColor;
  final String title;
  final String assetPath;
  final String date;
  final String url;

  const _ArtikelItem({
    required this.tag,
    required this.tagColor,
    required this.title,
    required this.assetPath,
    required this.date,
    required this.url,
  });
}

// ── Shortcut catalog (sinkron dengan favorit_tab) ─────────────────────────────

class _ShortcutItem {
  final String bookmarkKey;
  final String trackId;
  final String label;
  final String assetPath;
  final IconData fallback;
  final String route;

  const _ShortcutItem({
    required this.bookmarkKey,
    required this.trackId,
    required this.label,
    required this.assetPath,
    required this.fallback,
    required this.route,
  });
}

const List<_ShortcutItem> _kShortcutCatalog = [
  _ShortcutItem(
    bookmarkKey: 'fav_bapenda',
    trackId: 'bapenda',
    label: 'BAPENDA',
    assetPath: 'assets/images/layanan_bapenda.png',
    fallback: Icons.account_balance_rounded,
    route: AppRoutes.bapendaPage,
  ),
  _ShortcutItem(
    bookmarkKey: 'fav_transjatim',
    trackId: 'transjatim',
    label: 'Transjatim',
    assetPath: 'assets/images/layanan_transjatim.png',
    fallback: Icons.directions_bus_rounded,
    route: AppRoutes.transjatimPage,
  ),
  _ShortcutItem(
    bookmarkKey: 'fav_siskaperbapo',
    trackId: 'siskaperbapo',
    label: 'SISKAPERBAPO',
    assetPath: 'assets/images/layanan_siskaperbapo.png',
    fallback: Icons.storefront_rounded,
    route: AppRoutes.siskaperbapoPage,
  ),
  _ShortcutItem(
    bookmarkKey: 'fav_etibi',
    trackId: 'etibi',
    label: 'E-TIBI',
    assetPath: 'assets/images/layanan_etibi.png',
    fallback: Icons.medical_services_rounded,
    route: AppRoutes.etibiPage,
  ),
  _ShortcutItem(
    bookmarkKey: 'fav_sapabansos',
    trackId: 'sapa_bansos',
    label: 'SAPA BANSOS',
    assetPath: 'assets/images/layanan_sapa_bansos.png',
    fallback: Icons.volunteer_activism_rounded,
    route: AppRoutes.sapaBansosPage,
  ),
  _ShortcutItem(
    bookmarkKey: 'fav_klinikhoaks',
    trackId: 'klinik_hoaks',
    label: 'Klinik Hoaks',
    assetPath: 'assets/images/layanan_klinik_hoaks.png',
    fallback: Icons.fact_check_rounded,
    route: AppRoutes.klinikHoaksLandingPage,
  ),
  _ShortcutItem(
    bookmarkKey: 'fav_opendata',
    trackId: 'open_data',
    label: 'Open Data',
    assetPath: 'assets/images/layanan_open_data.png',
    fallback: Icons.dataset_rounded,
    route: AppRoutes.openDataLandingPage,
  ),
  _ShortcutItem(
    bookmarkKey: 'fav_nomordarurat',
    trackId: 'nomor_darurat',
    label: 'Nomor Darurat',
    assetPath: 'assets/images/layanan_nomor_darurat.png',
    fallback: Icons.emergency_rounded,
    route: AppRoutes.nomorDaruratLandingPage,
  ),
];

// ── Bottom Nav Item ───────────────────────────────────────────────────────────

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.activeIcon,
  });

  @override
  Widget build(BuildContext context) {
    final displayIcon = isActive ? (activeIcon ?? icon) : icon;
    return Semantics(
      button: true,
      selected: isActive,
      label: 'Tab $label',
      hint: isActive ? 'Saat ini aktif' : 'Ketuk untuk berpindah',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(displayIcon, color: isActive ? _blue : _textSecondary, size: 24),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? _blue : _textSecondary,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Segitiga ekor speech bubble ──────────────────────────────────────────────

class _BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

