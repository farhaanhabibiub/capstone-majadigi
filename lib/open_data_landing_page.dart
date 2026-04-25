import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'common/favorite_mixin.dart';
import 'open_data_list_page.dart';
import 'theme/app_theme.dart';

class OpenDataLandingPage extends StatefulWidget {
  const OpenDataLandingPage({super.key});

  @override
  State<OpenDataLandingPage> createState() => _OpenDataLandingPageState();
}

class _OpenDataLandingPageState extends State<OpenDataLandingPage>
    with FavoriteMixin {
  int _selectedTab = 0;
  bool _isOperasionalExpanded = true;
  bool _isKetentuanExpanded = true;

  @override
  String get favoriteKey => 'fav_opendata';

  @override
  String get favoriteLabel => 'Open Data';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 320,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF007AFF), Color(0xFF0062D1)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SizedBox(
                    height: 56,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const Text(
                          'Open Data',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontFamily: 'PlusJakartaSans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                isFavorite
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                                color: AppTheme.primary,
                                size: 22,
                              ),
                              onPressed: toggleFavorite,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildTabSwitcher(),
                        Expanded(
                          child: _selectedTab == 0
                              ? _buildLayananTab()
                              : _buildInformasiTab(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            _tabItem('Layanan', 0),
            _tabItem('Informasi', 1),
          ],
        ),
      ),
    );
  }

  Widget _tabItem(String label, int index) {
    final selected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF4B5563),
                fontWeight: FontWeight.w600,
                fontFamily: 'PlusJakartaSans',
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Tab Layanan ────────────────────────────────────────────────────────────

  Widget _buildLayananTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Color(0xFFEBF5FF), shape: BoxShape.circle),
              child: const Icon(Icons.search, color: AppTheme.primary, size: 28),
            ),
            const SizedBox(height: 20),
            const Text(
              'Cari Data',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Temukan kumpulan data yang Anda butuhkan mulai dari data mentah, kependudukan, kesehatan, ekonomi, dan lain-lainnya.',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'PlusJakartaSans',
                color: Colors.grey,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OpenDataListPage()),
                ),
                child: const Text(
                  'Cari Data Sekarang',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab Informasi ──────────────────────────────────────────────────────────

  Widget _buildInformasiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildExpandableCard(
            title: 'Operasional',
            subtitle: 'Akses portal & informasi layanan',
            icon: Icons.access_time_filled,
            isExpanded: _isOperasionalExpanded,
            onTap: () => setState(() => _isOperasionalExpanded = !_isOperasionalExpanded),
            content: _buildOperasionalContent(),
          ),
          const SizedBox(height: 16),
          _buildExpandableCard(
            title: 'Ketentuan Umum',
            subtitle: 'Manfaat & prosedur penggunaan',
            icon: Icons.description,
            isExpanded: _isKetentuanExpanded,
            onTap: () => setState(() => _isKetentuanExpanded = !_isKetentuanExpanded),
            content: _buildKetentuanContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            onTap: onTap,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: Color(0xFFEBF5FF), shape: BoxShape.circle),
              child: Icon(icon, color: AppTheme.primary, size: 22),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            subtitle: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'PlusJakartaSans',
                color: Colors.grey,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Color(0xFFEBF5FF), shape: BoxShape.circle),
              child: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: AppTheme.primary,
                size: 18,
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
              child: content,
            ),
        ],
      ),
    );
  }

  Widget _buildOperasionalContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoSection(
          'Link Layanan',
          GestureDetector(
            onTap: () => _launchUrl('https://opendata.jatimprov.go.id/'),
            child: const Text(
              'opendata.jatimprov.go.id',
              style: TextStyle(
                color: AppTheme.primary,
                decoration: TextDecoration.underline,
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _infoSection(
          'Alamat',
          const Text(
            'Jl. Ahmad Yani No.242-244, Gayungan, Surabaya, Jawa Timur 60235',
            style: TextStyle(
              color: Color(0xFF4B5563),
              height: 1.5,
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _infoSection(
          'Akses Portal',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF5FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cloud_outlined, color: AppTheme.primary, size: 15),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Portal web dapat diakses 24 jam / 7 hari',
                        style: TextStyle(
                          color: Color(0xFF1D4ED8),
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pertanyaan & aduan melalui email pada jam kerja:\nSenin–Jumat, 08:00–16:00 WIB',
                style: TextStyle(
                  color: Color(0xFF4B5563),
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKetentuanContent() {
    return Column(
      children: [
        _ketentuanSection('Manfaat', [
          'Transparansi pemerintah: masyarakat dapat mengakses informasi kebijakan dan kinerja pemerintah secara terbuka.',
          'Pengambilan keputusan berbasis data yang lebih tepat dan akurat.',
          'Pemberdayaan masyarakat Jatim untuk berinovasi dan membuat keputusan strategis di lingkungannya.',
          'Kolaborasi multi-sektor antara pemerintah, akademisi, dan dunia usaha.',
        ]),
        const SizedBox(height: 12),
        _ketentuanSection('Sistem, Mekanisme, dan Prosedur', [
          'Akses aplikasi MajaDigitalJatim dan pilih fitur Open Data.',
          'Pilih tab "Layanan" lalu tekan "Cari Data Sekarang".',
          'Gunakan kolom pencarian atau filter kategori untuk menemukan data.',
          'Buka detail data yang dituju, baca deskripsi dan metadata.',
          'Tekan "Unduh Dataset" untuk mengunduh atau kunjungi portal resmi Open Data Jatim.',
        ]),
      ],
    );
  }

  Widget _infoSection(String title, Widget content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              fontFamily: 'PlusJakartaSans',
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 6),
          content,
        ],
      ),
    );
  }

  Widget _ketentuanSection(String title, List<String> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              fontFamily: 'PlusJakartaSans',
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(
            items.length,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${i + 1}. ',
                      style: const TextStyle(
                          fontSize: 13, fontFamily: 'PlusJakartaSans', color: Color(0xFF4B5563))),
                  Expanded(
                    child: Text(
                      items[i],
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'PlusJakartaSans',
                        color: Color(0xFF4B5563),
                        height: 1.5,
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

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
