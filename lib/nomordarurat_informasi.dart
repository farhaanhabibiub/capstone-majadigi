import 'package:flutter/material.dart';
import 'nomordarurat_landing_page.dart';

class NomorDaruratInformasiPage extends StatefulWidget {
  const NomorDaruratInformasiPage({super.key});

  @override
  State<NomorDaruratInformasiPage> createState() => _NomorDaruratInformasiPageState();
}

class _NomorDaruratInformasiPageState extends State<NomorDaruratInformasiPage> {
  bool _isTentangExpanded = true;
  bool _isOperasionalExpanded = true;
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
                          'Nomor Darurat',
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
                            // Tentang Nomor Darurat Card
                            _buildExpandableCard(
                              title: 'Tentang Nomor Darurat',
                              subtitle: 'Lorem Ipsum',
                              icon: Icons.info_outline,
                              isExpanded: _isTentangExpanded,
                              onTap: () => setState(() => _isTentangExpanded = !_isTentangExpanded),
                              content: _buildTentangContent(),
                            ),
                            const SizedBox(height: 16),
                            // Operasional Card
                            _buildExpandableCard(
                              title: 'Operasional',
                              subtitle: 'lorem ipsum',
                              icon: Icons.access_time_filled,
                              isExpanded: _isOperasionalExpanded,
                              onTap: () => setState(() => _isOperasionalExpanded = !_isOperasionalExpanded),
                              content: _buildOperasionalContent(),
                            ),
                            const SizedBox(height: 16),
                            // Ketentuan Umum Card
                            _buildExpandableCard(
                              title: 'Ketentuan Umum',
                              subtitle: 'Lorem Ipsum',
                              icon: Icons.description,
                              isExpanded: _isKetentuanExpanded,
                              onTap: () => setState(() => _isKetentuanExpanded = !_isKetentuanExpanded),
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

  Widget _buildTentangContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Nomor darurat merupakan layanan cepat tanggap dari pemerintah atau instansi terkait untuk memberikan bantuan kepada masyarakat. Nomor ini dapat dihubungi saat warga menghadapi situasi mendesak, berbahaya, atau yang mengancam nyawa—seperti kecelakaan, kebakaran, bencana alam, gangguan keamanan, hingga kondisi medis gawat darurat.',
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'PlusJakartaSans',
            color: Color(0xFF4B5563),
            height: 1.6,
          ),
        ),
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
            title: 'Alamat',
            content: const Text(
              'Seluruh Daerah di Jawa Timur',
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
                const Text(
                  'Layanan nomor darurat memberikan akses cepat dan mudah untuk mencari pertolongan saat seseorang mengalami atau mengetahui situasi darurat seperti kebakaran, banjir, kecelakaan lalu lintas, kriminalitas, dan lainnya. Dengan begitu, layanan ini diharapkan mampu mempercepat penanganan keadaan darurat dan meminimalisir dampak buruk yang muncul akibat situasi darurat. Layanan nomor darurat beroperasi 24 jam sehari, dan 7 hari seminggu. Sehingga masyarakat bisa mengaksesnya kapanpun dan dari manapun.',
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
                const Text(
                  'Kontak darurat biasanya lebih pendek atau sedikit dengan tujuan agar mudah diingat. Pastikan Anda menyimpan daftar kontak darurat di ponsel Anda atau tempat yang mudah dijangkau. Terakhir, pastikan Anda memberikan informasi secara jelas mengenai kejadian dan lokasinya agar petugas bisa mengeksekusinya lebih cepat.',
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
