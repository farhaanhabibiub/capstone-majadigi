import 'package:flutter/material.dart';
import 'app_route.dart';
import 'open_data_datasebaran.dart';

class OpenDataListPage extends StatefulWidget {
  const OpenDataListPage({super.key});

  @override
  State<OpenDataListPage> createState() => _OpenDataListPageState();
}

class _OpenDataListPageState extends State<OpenDataListPage> {
  final List<String> _categories = [
    'Semua',
    'Dataset',
    'Artikel',
    'Infografis',
    'Publikasi',
    'Statistik',
    'Berita'
  ];
  String _selectedCategory = 'Semua';

  final List<Map<String, dynamic>> _dataItems = [
    {
      'title': 'Cara buat dapur MBG',
      'date': '07 Oktober 2021',
      'category': 'Ekonomi',
      'type': 'Artikel',
    },
    {
      'title': 'Ayo pasok bahan panganmu!!!',
      'date': '07 Oktober 2021',
      'category': 'Ekonomi',
      'type': 'Infografis',
    },
    {
      'title': 'Data Sebaran UMKM Berdasarkan Sektor Per Kecamatan Tahun 2025',
      'date': '07 Oktober 2021',
      'category': 'Ekonomi',
      'type': 'Dataset',
    },
    {
      'title': 'Cara buat dapur MBG',
      'date': '07 Oktober 2021',
      'category': 'Ekonomi',
      'type': 'Artikel',
    },
    {
      'title': 'Cara buat dapur MBG',
      'date': '07 Oktober 2021',
      'category': 'Ekonomi',
      'type': 'Artikel',
    },
    {
      'title': 'Cara buat dapur MBG',
      'date': '07 Oktober 2021',
      'category': 'Ekonomi',
      'type': 'Artikel',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Simplified Header using BoxDecoration for better renderer stability
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF),
              image: const DecorationImage(
                image: AssetImage('assets/images/header_texture.png'),
                fit: BoxFit.cover,
                opacity: 0.6,
              ),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF007AFF), Color(0xFF0062D1)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // App Bar
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
                          'Cari Data',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontFamily: 'PlusJakartaSans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(width: 44),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Main Content Area
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Bar
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: const Color(0xFF007AFF).withOpacity(0.5)),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0D000000), // Hex for 0.05 opacity black
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const TextField(
                              decoration: InputDecoration(
                                hintText: 'Cari Sesuatu...',
                                hintStyle: TextStyle(
                                  color: Color(0xFF007AFF),
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 15,
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                                border: InputBorder.none,
                                suffixIcon: Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: Icon(Icons.search, color: Color(0xFF007AFF), size: 28),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            'Hasil Pencarian',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'PlusJakartaSans',
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Categories Horizontal List
                        SizedBox(
                          height: 44,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _categories.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final category = _categories[index];
                              final isSelected = _selectedCategory == category;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedCategory = category),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 28),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF007AFF) : const Color(0xFF8E8E93),
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: Center(
                                    child: Text(
                                      category,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'PlusJakartaSans',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Data Items List
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: _dataItems.length,
                            itemBuilder: (context, index) {
                              final item = _dataItems[index];
                              return GestureDetector(
                                onTap: () {
                                  if (item['title'] == 'Cara buat dapur MBG') {
                                    Navigator.pushNamed(context, AppRoutes.openDataDapurMBGPage);
                                  } else if (item['title'] == 'Ayo pasok bahan panganmu!!!') {
                                    Navigator.pushNamed(context, AppRoutes.openDataAyoPasokPage);
                                  } else if (item['title'] == 'Data Sebaran UMKM Berdasarkan Sektor Per Kecamatan Tahun 2025') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const OpenDataDataSebaranPage()),
                                    );
                                  }
                                },
                                child: _buildResultCard(item),
                              );
                            },
                          ),
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

  Widget _buildResultCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000), // Hex for 0.02 opacity black
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Color(0xFFD1D1D6),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildMetaInfo(Icons.calendar_today_outlined, item['date']),
                    const SizedBox(width: 12),
                    _buildMetaInfo(Icons.business_outlined, item['category']),
                    const SizedBox(width: 12),
                    _buildMetaInfo(Icons.filter_list, item['type']),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF3A3A3C)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            fontFamily: 'PlusJakartaSans',
            color: Color(0xFF3A3A3C),
          ),
        ),
      ],
    );
  }
}