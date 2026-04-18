import 'package:flutter/material.dart';

class OpenDataInformasiPage extends StatefulWidget {
  const OpenDataInformasiPage({super.key});

  @override
  State<OpenDataInformasiPage> createState() => _OpenDataInformasiPageState();
}

class _OpenDataInformasiPageState extends State<OpenDataInformasiPage> {
  bool _isOperasionalExpanded = false;
  bool _isKetentuanExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Header Background (Matched with OpenDataLandingPage)
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
                // Header
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
                          'Open Data',
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
                            // Layanan / Informasi Toggle
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
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        color: Colors.transparent,
                                        child: const Center(
                                          child: Text(
                                            'Layanan',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'PlusJakartaSans',
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF007AFF),
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Informasi',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'PlusJakartaSans',
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
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
                'https://opendata.jatimprov.go.id/',
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
                _buildNumberedItem(1, 'Pemerintah hadir lebih transparan: Masyarakat bisa mengakses informasi kebijakan dan kinerja pemerintah lebih transparan.'),
                _buildNumberedItem(2, 'Pengambilan keputusan berbasis data: Open data mendukung pengambilan keputusan lebih tepat dan akurat.'),
                _buildNumberedItem(3, 'Pemberdayaan masyarakat: Masyarakat lebih mudah mendapat gambaran situasi sosial, ekonomi, dan lingkungan di Jawa Timur. Ini akan mendorong warga Jatim untuk lebih aktif menciptakan inovasi berbasis data dan membuat keputusan strategis di lingkungannya.'),
                _buildNumberedItem(4, 'Kolaborasi multi-sektor: Memperkuat kolaborasi antara pemerintah, akademisi, dan dunia usaha melalui open data sebagai dasar pemecahan masalah yang kompleks.'),
                const SizedBox(height: 8),
                const Text(
                  'Dengan adanya Open Data Jatim, berbagai pihak dapat memanfaatkan data untuk menciptakan solusi inovatif, mendorong keterbukaan informasi, dan meningkatkan kesejahteraan masyarakat.',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'PlusJakartaSans',
                    color: Color(0xFF4B5563),
                    height: 1.5,
                  ),
                ),
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
                _buildNumberedItem(1, 'Akses website Open Data Jawa Timur', isLink: true),
                _buildNumberedItem(2, 'Cari dataset, publikasi, dan infografik dari OPD atau sesuai kategori topik, seperti sosial, ekonomi, kependudukan, dan sebagainya'),
                _buildNumberedItem(3, 'Buka metadata dataset yang dituju, lalu klik menu atur kolom sesuai kebutuhan'),
                _buildNumberedItem(4, 'Unduh data sesuai format yang diinginkan, yaitu excel, CSV, dan API'),
                _buildNumberedItem(5, 'Anda juga bisa mengakses dataset Kabupaten dan Kota di Jatim melalui menu Portal Data Kab/Kota. Lalu cari dataset dengan klik logo Kabupaten/Kota yang dituju. Pilih data yang ingin dicari, lalu klik detail dan unduh datanya.'),
                const SizedBox(height: 8),
                const Text(
                  'Penyajian data di website Open Data Jawa Timur sejalan dengan prinsip Satu Data Indonesia (SDI) yang menjamin akurasi, keterbukaan, dan ketersediaan data secara gratis serta mudah diakses oleh publik. Sesuai amanat Perpres 39/2019 dan Pergub Jatim No. 81 Tahun 2020, Satu Data Jawa Timur mendukung keterbukaan data pembangunan secara terpusat dan terintegrasi di Jawa Timur.',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'PlusJakartaSans',
                    color: Color(0xFF4B5563),
                    height: 1.5,
                  ),
                ),
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
