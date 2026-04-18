import 'package:flutter/material.dart';

class OpenDataDapurMBGPage extends StatelessWidget {
  const OpenDataDapurMBGPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Blue Header
          Container(
            width: double.infinity,
            height: 120,
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
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Cari Data',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontFamily: 'PlusJakartaSans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // To balance the back button
                  ],
                ),
              ),
            ),
          ),
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cara buat dapur MBG',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildMetaInfo(Icons.calendar_today, '07 Oktober 2021'),
                      const SizedBox(width: 16),
                      _buildMetaInfo(Icons.book, 'Ekonomi'),
                      const SizedBox(width: 16),
                      _buildMetaInfo(Icons.filter_list, 'Artikel'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/dapurmbg.png',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Pembangunan dapur Makan Bergizi Gratis (MBG) harus mengutamakan alur kerja linear yang memisahkan zona bersih dan kotor guna mencegah kontaminasi silang. Area ini wajib dilengkapi dengan ruang penyimpanan suhu terkontrol, meja preparasi stainless steel, serta sistem drainase dan ventilasi industri yang mumpuni untuk menangani pengolahan makanan skala besar secara higienis.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'PlusJakartaSans',
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aspek operasional difokuskan pada efisiensi distribusi dan sterilitas pengemasan untuk menjaga kualitas gizi hingga ke tangan penerima. Manajemen limbah yang terpadu dan ketersediaan fasilitas sanitasi bagi personel menjadi standar mutlak agar seluruh proses produksi, dari dapur hingga penyajian, tetap memenuhi kriteria keamanan pangan nasional secara konsisten.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'PlusJakartaSans',
                      color: Colors.black87,
                      height: 1.6,
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

  Widget _buildMetaInfo(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black87),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'PlusJakartaSans',
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}