import 'package:flutter/material.dart';
import 'klinikhoaks_landing_page.dart';
import 'klinikhoaks_detailtiket.dart';
import 'klinikhoaks_informasi.dart';

class KlinikHoaksPermohonanPage extends StatefulWidget {
  final String initialTab;
  const KlinikHoaksPermohonanPage({super.key, this.initialTab = 'Layanan'});

  @override
  State<KlinikHoaksPermohonanPage> createState() => _KlinikHoaksPermohonanPageState();
}

class _KlinikHoaksPermohonanPageState extends State<KlinikHoaksPermohonanPage> {
  late String _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

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
                            // Content based on tab selection
                            if (_selectedTab == 'Layanan')
                              _buildPermohonanCard()
                            else if (_selectedTab == 'Tiket Saya')
                              _buildEmptyStateCard(),
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
          if (title == 'Informasi') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const KlinikHoaksInformasiPage()),
            );
          } else {
            setState(() {
              _selectedTab = title;
            });
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

  Widget _buildPermohonanCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFEBF5FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.description,
              color: Color(0xFF007AFF),
              size: 30,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Permohonan Klarifikasi',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Kirimkan detail informasi yang kamu dapat, akan kami bantu cari klarifikasinya dalam 1x24 jam.',
            style: TextStyle(
              fontSize: 15,
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w500,
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
                side: const BorderSide(color: Color(0xFF007AFF), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const KlinikHoaksLandingPage(),
                  ),
                );
              },
              child: const Text(
                'Ajukan Laporan',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF007AFF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
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
          // Illustration Image (kacapembesar.jpg)
          SizedBox(
            height: 180,
            child: Image.asset(
              'assets/images/kacapembesar.jpg',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Belum Ada Tiket',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Maaf, sepertinya Anda belum pernah mengirimkan laporan atau nomor tiket tidak terdaftar di sistem kami.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w500,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF007AFF), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              onPressed: () {
                // Flow like before: Empty state button goes to ticket list
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const KlinikHoaksDetailTiketPage(),
                  ),
                );
              },
              child: const Text(
                'Ajukan Laporan',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF007AFF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
