import 'package:flutter/material.dart';

class KlinikHoaksLihatDetail extends StatelessWidget {
  const KlinikHoaksLihatDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Header Background
          Container(
            width: double.infinity,
            height: 250,
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
                          'Tiket Saya',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontFamily: 'PlusJakartaSans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
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
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ticket Info Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('Nomor Tiket'),
                                      _buildDetailContainer('#KH-20260329'),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('Status'),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFDB022),
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'Sedang Diproses',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'PlusJakartaSans',
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildLabel('Topik'),
                            _buildDetailContainer('Isu Bansos Jatim 2026'),
                            const SizedBox(height: 20),
                            _buildLabel('Isi Laporan'),
                            _buildDetailContainer(
                              'Saya menerima pesan berantai di grup WhatsApp keluarga yang menyebutkan ada pembagian bansos tunai dari Pemprov Jatim sebesar Rp 600.000. Untuk mendapatkannya, warga diminta mengklik tautan dan mengisi data KTP serta nomor rekening. Saya curiga ini adalah penipuan karena domain website bukan .go.id.',
                              maxLines: 8,
                            ),
                            const SizedBox(height: 20),
                            _buildLabel('Link Bukti/Alamat Website'),
                            _buildDetailContainer('http://pendaftaran-bansos-jatim-2026.xyz/login'),
                            const SizedBox(height: 20),
                            _buildLabel('Bukti File'),
                            _buildDetailContainer('SS_Web_Phishing.jpg'),
                            const SizedBox(height: 40),
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

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'PlusJakartaSans',
          color: Color(0xFF1F2937),
        ),
      ),
    );
  }

  Widget _buildDetailContainer(String text, {int maxLines = 1}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'PlusJakartaSans',
          color: Color(0xFF4B5563),
          height: 1.5,
        ),
      ),
    );
  }
}
