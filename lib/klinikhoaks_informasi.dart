import 'package:flutter/material.dart';
import 'klinikhoaks_permohonan.dart';

class KlinikHoaksInformasiPage extends StatefulWidget {
  const KlinikHoaksInformasiPage({super.key});

  @override
  State<KlinikHoaksInformasiPage> createState() => _KlinikHoaksInformasiPageState();
}

class _KlinikHoaksInformasiPageState extends State<KlinikHoaksInformasiPage> {
  bool _isOperasionalExpanded = false;
  bool _isKetentuanExpanded = true;
  final String _selectedTab = 'Informasi';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Header Background
          Container(
            width: double.infinity,
            height: 320,
            decoration: const BoxDecoration(
              color: Color(0xFF007AFF),
              image: DecorationImage(
                image: AssetImage('assets/images/header_texture.png'),
                fit: BoxFit.cover,
                opacity: 0.6,
              ),
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
                // Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                          'Klinik Hoaks',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontFamily: 'PlusJakartaSans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.bookmark_border, color: Color(0xFF007AFF), size: 26),
                              onPressed: () {},
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Content Area
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                        child: Column(
                          children: [
                            // Tabs Toggle
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0A000000),
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  _buildTabItem('Layanan'),
                                  _buildTabItem('Tiket Saya'),
                                  _buildTabItem('Informasi'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Operasional Card
                            _buildExpandableCard(
                              title: 'Operasional',
                              subtitle: 'lorem ipsum',
                              icon: Icons.access_time_filled,
                              isExpanded: _isOperasionalExpanded,
                              onTap: () {
                                setState(() {
                                  _isOperasionalExpanded = !_isOperasionalExpanded;
                                });
                              },
                              content: _buildOperasionalContent(),
                            ),
                            const SizedBox(height: 16),
                            // Ketentuan Umum Card
                            _buildExpandableCard(
                              title: 'Ketentuan Umum',
                              subtitle: 'Lorem Ipsum',
                              icon: Icons.description,
                              isExpanded: _isKetentuanExpanded,
                              onTap: () {
                                setState(() {
                                  _isKetentuanExpanded = !_isKetentuanExpanded;
                                });
                              },
                              content: _buildKetentuanUmumContent(),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildTabItem(String title) {
    bool isSelected = _selectedTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (title == 'Layanan') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const KlinikHoaksPermohonanPage(initialTab: 'Layanan')),
            );
          } else if (title == 'Tiket Saya') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const KlinikHoaksPermohonanPage(initialTab: 'Tiket Saya')),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF007AFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF4B5563),
                fontWeight: FontWeight.w600,
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
              ),
            ),
          ),
        ),
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
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
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
              decoration: const BoxDecoration(
                color: Color(0xFFEBF5FF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF007AFF), size: 24),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            subtitle: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'PlusJakartaSans',
                color: Colors.grey,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF5FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: const Color(0xFF007AFF),
                size: 20,
              ),
            ),
          ),
          if (isExpanded) content,
        ],
      ),
    );
  }

  Widget _buildOperasionalContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(
            title: 'Link Layanan',
            content: InkWell(
              onTap: () {},
              child: const Text(
                'https://klinikhoaks.jatimprov.go.id/',
                style: TextStyle(
                  color: Color(0xFF007AFF),
                  decoration: TextDecoration.underline,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoSection(
            title: 'Alamat',
            content: const Text(
              'Jl. Ahmad Yani No.242-244, Gayungan, Kec. Gayungan, Surabaya, Jawa Timur 60235',
              style: TextStyle(
                color: Color(0xFF4B5563),
                height: 1.5,
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoSection(
            title: 'Jam Operasional',
            content: Column(
              children: [
                _buildDayRow('Senin', '(00:00 - 23:59)'),
                _buildDayRow('Selasa', '(00:00 - 23:59)'),
                _buildDayRow('Rabu', '(00:00 - 23:59)'),
                _buildDayRow('Kamis', '(00:00 - 23:59)'),
                _buildDayRow('Jumat', '(00:00 - 23:59)'),
                _buildDayRow('Sabtu', '(00:00 - 23:59)'),
                _buildDayRow('Minggu', '(00:00 - 23:59)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKetentuanUmumContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          // Manfaat Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manfaat',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    fontFamily: 'PlusJakartaSans',
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                _buildNumberedItem(1, 'Membantu masyarakat memverifikasi informasi yang meragukan agar terhindar dari hoaks.'),
                _buildNumberedItem(2, 'Melindungi publik dari dampak negatif informasi palsu yang menyesatkan.'),
                _buildNumberedItem(3, 'Meningkatkan kesadaran dan literasi digital masyarakat melalui klarifikasi informasi.'),
                _buildNumberedItem(4, 'Mendukung terciptanya ruang digital yang sehat dan bebas hoaks.'),
                _buildNumberedItem(5, 'Menyediakan akses transparan terhadap hasil verifikasi informasi.'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Sistem, Mekanisme, dan Prosedur Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sistem, Mekanisme, dan Prosedur',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    fontFamily: 'PlusJakartaSans',
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                _buildNumberedItem(1, 'Akses laman https://klinikhoaks.jatimprov.go.id/', isLink: true),
                _buildNumberedItem(2, 'Masukkan kata kunci informasi atau berita yang dicari'),
                _buildNumberedItem(3, 'Sistem akan menampilkan hasil temuan sesuai kata kunci yang dicari, termasuk status dan penjelasannya.'),
                _buildNumberedItem(4, 'Jika informasi yang dicari tidak ditemukan, pengguna bisa ajukan permohonan klarifikasi sebagai berikut:'),
                _buildNumberedItem(5, 'Klik menu di laman Klinik Hoaks'),
                _buildNumberedItem(6, 'Pilih menu permohonan klarifikasi'),
                _buildNumberedItem(7, 'Isi formulir data dengan informasi yang diminta, lalu klik tombol kirim.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedItem(int number, String text, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. ',
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'PlusJakartaSans',
              color: Color(0xFF4B5563),
            ),
          ),
          Expanded(
            child: isLink
                ? InkWell(
                    onTap: () {},
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'PlusJakartaSans',
                        color: Color(0xFF4B5563),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'PlusJakartaSans',
                      color: Color(0xFF4B5563),
                      height: 1.5,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({required String title, required Widget content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
              fontSize: 14,
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

  Widget _buildDayRow(String day, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.circle, size: 6, color: Color(0xFF1F2937)),
          const SizedBox(width: 10),
          Text(
            '$day ',
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'PlusJakartaSans',
              color: Color(0xFF1F2937),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'PlusJakartaSans',
              color: Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }
}
