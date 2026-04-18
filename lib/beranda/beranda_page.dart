import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../app_route.dart';

class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _whiteBg = Color.fromRGBO(248, 248, 245, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);

  static const List<_ServiceItem> _services = [
    _ServiceItem(
      id: 'transjatim',
      label: 'Transjatim',
      description: 'Beli tiket & cek rute bus Jawa Timur',
      icon: Icons.directions_bus_rounded,
      color: Color.fromRGBO(0, 101, 255, 1),
      bgColor: Color.fromRGBO(235, 243, 255, 1),
      route: AppRoutes.transjatimPage,
    ),
    _ServiceItem(
      id: 'opendata',
      label: 'Open Data',
      description: 'Data & informasi publik Jawa Timur',
      icon: Icons.bar_chart_rounded,
      color: Color.fromRGBO(34, 197, 94, 1),
      bgColor: Color.fromRGBO(240, 253, 244, 1),
      route: AppRoutes.openDataLandingPage,
    ),
    _ServiceItem(
      id: 'klinikhoaks',
      label: 'Klinik Hoaks',
      description: 'Laporkan & cek kebenaran informasi',
      icon: Icons.fact_check_rounded,
      color: Color.fromRGBO(234, 88, 12, 1),
      bgColor: Color.fromRGBO(255, 247, 237, 1),
      route: AppRoutes.klinikHoaksLandingPage,
    ),
    _ServiceItem(
      id: 'nomordarurat',
      label: 'Nomor Darurat',
      description: 'Akses cepat nomor layanan darurat',
      icon: Icons.emergency_rounded,
      color: Color.fromRGBO(220, 38, 38, 1),
      bgColor: Color.fromRGBO(254, 242, 242, 1),
      route: AppRoutes.nomorDaruratLandingPage,
    ),
  ];

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? 'Pengguna';
    final firstName = name.split(' ').first;

    return Scaffold(
      backgroundColor: _whiteBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, firstName)),
            SliverToBoxAdapter(child: _buildBanner()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Layanan',
                      style: TextStyle(
                        color: _textPrimary,
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${_services.length} layanan tersedia',
                      style: const TextStyle(
                        color: _textSecondary,
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _ServiceCard(service: _services[i]),
                  childCount: _services.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String firstName) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: const BoxDecoration(
        color: _blue,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_greeting()},',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  firstName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Apa yang bisa kami bantu hari ini?',
                  style: TextStyle(
                    color: Colors.white70,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color.fromRGBO(0, 80, 220, 1), Color.fromRGBO(0, 140, 255, 1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Jawa Timur Digital',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Layanan Publik\nDalam Genggaman',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Akses semua layanan Provinsi Jawa Timur dengan mudah.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_city_rounded, color: Colors.white, size: 36),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final _ServiceItem service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, service.route),
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: service.bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(service.icon, color: service.color, size: 24),
            ),
            const Spacer(),
            Text(
              service.label,
              style: const TextStyle(
                color: Color.fromRGBO(32, 32, 32, 1),
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              service.description,
              style: const TextStyle(
                color: Color.fromRGBO(120, 120, 120, 1),
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceItem {
  final String id;
  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String route;

  const _ServiceItem({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.route,
  });
}
