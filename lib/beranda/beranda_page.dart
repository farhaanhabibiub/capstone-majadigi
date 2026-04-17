import 'package:flutter/material.dart';
import '../app_route.dart';
import '../auth_service.dart';
import '../rsud/hospital_config.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  int _selectedIndex = 0;
  String _locationText = '';
  String _locationCity = '';
  String _locationRegency = '';
  bool _isLoadingProfile = true;

  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _whiteBg = Color.fromRGBO(248, 248, 245, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);

  static const List<_ServiceItem> _services = [
    _ServiceItem(
      label: 'BAPENDA',
      assetPath: 'assets/images/layanan_bapenda.png',
      fallback: Icons.account_balance_rounded,
      route: AppRoutes.bapendaPage,
    ),
    _ServiceItem(
      label: 'RSJD',
      assetPath: 'assets/images/layanan_rsjd.png',
      fallback: Icons.local_hospital_rounded,
    ),
    _ServiceItem(
      label: 'Transportasi',
      assetPath: 'assets/images/layanan_transportasi.png',
      fallback: Icons.directions_bus_rounded,
    ),
    _ServiceItem(
      label: 'SIKAMPERBATO',
      assetPath: 'assets/images/layanan_sikamperbato.png',
      fallback: Icons.security_rounded,
    ),
    _ServiceItem(
      label: 'Nomor Darurat',
      assetPath: 'assets/images/layanan_nomor_darurat.png',
      fallback: Icons.emergency_rounded,
    ),
  ];


  static const List<_ArtikelItem> _artikels = [
    _ArtikelItem(
      title: 'BAPENDA Jatim Luncurkan Platform Digital',
      assetPath: 'assets/images/artikel_1.png',
      date: '12 Apr 2026',
    ),
    _ArtikelItem(
      title: 'Update Aturan Pajak Kendaraan Bermotor 2026',
      assetPath: 'assets/images/artikel_2.png',
      date: '10 Apr 2026',
    ),
    _ArtikelItem(
      title: 'Integrasi Layanan Kesehatan RSJD Di Surabaya',
      assetPath: 'assets/images/artikel_3.png',
      date: '8 Apr 2026',
    ),
  ];

  void _navigateToRsud() {
    final hospital = HospitalConfig.forLocation(_locationCity, _locationRegency);
    Navigator.pushNamed(context, AppRoutes.rsudPage, arguments: hospital);
  }

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final profile = await AuthService.instance.getUserProfile();
    if (!mounted) return;

    setState(() {
      _isLoadingProfile = false;
      final location = profile?['location'] as Map<String, dynamic>?;
      if (location != null) {
        final city = location['city'] as String? ?? '';
        final regency = location['regency'] as String? ?? '';
        _locationCity = city;
        _locationRegency = regency;
        if (city.isNotEmpty && regency.isNotEmpty) {
          _locationText = '$city, $regency';
        } else if (regency.isNotEmpty) {
          _locationText = regency;
        } else if (city.isNotEmpty) {
          _locationText = city;
        } else {
          _locationText = 'Lokasi belum diatur';
        }
      } else {
        _locationText = 'Lokasi belum diatur';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _whiteBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildWelcomeBanner(),
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
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color.fromRGBO(220, 232, 255, 1),
            child: Image.asset(
              'assets/images/avatar_placeholder.png',
              width: 44,
              height: 44,
              errorBuilder: (_, _, _) => const Icon(
                Icons.person_rounded,
                color: _blue,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Lokasi
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
                        _isLoadingProfile
                            ? '...'
                            : (_locationText.isEmpty
                                ? 'Lokasi belum diatur'
                                : _locationText),
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
          // Bell notifikasi
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.07),
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
        ],
      ),
    );
  }

  // ── Banner ────────────────────────────────────────────────────────────────

  Widget _buildWelcomeBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/images/beranda_banner_illustration.png',
          width: double.infinity,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }

  // ── Layanan Unggulan ──────────────────────────────────────────────────────

  Widget _buildLayananUnggulan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Expanded(
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
        // Grid layanan (3 kolom, bungkus otomatis)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _services.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              return _buildServiceCard(_services[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(_ServiceItem item) {
    VoidCallback? onTap;
    if (item.label == 'RSJD') {
      onTap = _navigateToRsud;
    } else if (item.route != null) {
      onTap = () => Navigator.pushNamed(context, item.route!);
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
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
                errorBuilder: (_, _, _) => Icon(
                  item.fallback,
                  color: _blue,
                  size: 26,
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

  // ── Berita & Artikel ──────────────────────────────────────────────────────

  Widget _buildBeritaArtikel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section
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
        // List artikel
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _artikels.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            return _buildArtikelCard(_artikels[index]);
          },
        ),
      ],
    );
  }

  Widget _buildArtikelCard(_ArtikelItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(14),
            ),
            child: Image.asset(
              item.assetPath,
              width: 92,
              height: 92,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 92,
                height: 92,
                color: const Color.fromRGBO(220, 232, 255, 1),
                child: const Icon(
                  Icons.article_rounded,
                  color: _blue,
                  size: 32,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Konten
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'MAJADIGI',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Judul
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
                  // Tanggal
                  Text(
                    item.date,
                    style: const TextStyle(
                      color: _textSecondary,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
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
                icon: Icons.grid_view_rounded,
                label: 'Layanan',
                isActive: _selectedIndex == 1,
                onTap: () => setState(() => _selectedIndex = 1),
              ),
              _BottomNavItem(
                icon: Icons.notifications_outlined,
                label: 'Notifikasi',
                isActive: _selectedIndex == 2,
                onTap: () => setState(() => _selectedIndex = 2),
              ),
              _BottomNavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profil',
                isActive: _selectedIndex == 3,
                onTap: () => setState(() => _selectedIndex = 3),
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
  final String label;
  final String assetPath;
  final IconData fallback;
  final String? route;

  const _ServiceItem({
    required this.label,
    required this.assetPath,
    required this.fallback,
    this.route,
  });
}

class _ArtikelItem {
  final String title;
  final String assetPath;
  final String date;

  const _ArtikelItem({
    required this.title,
    required this.assetPath,
    required this.date,
  });
}

// ── Bottom Nav Item ───────────────────────────────────────────────────────────

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
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
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? _blue : _textSecondary,
              size: 24,
            ),
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
    );
  }
}
