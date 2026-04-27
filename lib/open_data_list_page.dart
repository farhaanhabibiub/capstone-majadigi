import 'package:flutter/material.dart';
import 'open_data_datasebaran.dart';
import 'open_data_dapurmbg.dart';
import 'open_data_ayopasok.dart';
import 'open_data_detail_page.dart';
import 'widgets/empty_state.dart';

class OpenDataListPage extends StatefulWidget {
  const OpenDataListPage({super.key});

  @override
  State<OpenDataListPage> createState() => _OpenDataListPageState();
}

class _OpenDataListPageState extends State<OpenDataListPage> {
  static const _blue = Color(0xFF007AFF);

  final _searchController = TextEditingController();
  String _selectedCategory = 'Semua';

  static const _categories = [
    'Semua', 'Dataset', 'Artikel', 'Infografis', 'Publikasi', 'Statistik', 'Berita',
  ];

  static const _allItems = <Map<String, dynamic>>[
    {
      'title': 'Data Sebaran UMKM Per Kecamatan Tahun 2025',
      'date': '31 Maret 2025',
      'category': 'Ekonomi',
      'type': 'Dataset',
      'iconData': Icons.table_chart_outlined,
      'iconColor': Color(0xFF2563EB),
      'route': 'datasebaran',
    },
    {
      'title': 'Cara Membuat Dapur Makan Bergizi Gratis (MBG)',
      'date': '07 Oktober 2024',
      'category': 'Sosial',
      'type': 'Artikel',
      'iconData': Icons.article_outlined,
      'iconColor': Color(0xFF16A34A),
      'route': 'dapurmbg',
    },
    {
      'title': 'Ayo Pasok Bahan Pangan ke Program MBG',
      'date': '07 Oktober 2024',
      'category': 'Ekonomi',
      'type': 'Infografis',
      'iconData': Icons.bar_chart_outlined,
      'iconColor': Color(0xFFEA580C),
      'route': 'ayopasok',
    },
    {
      'title': 'Jumlah Penduduk Jawa Timur Per Kabupaten/Kota 2024',
      'date': '01 Januari 2025',
      'category': 'Kependudukan',
      'type': 'Dataset',
      'iconData': Icons.people_outline,
      'iconColor': Color(0xFF7C3AED),
      'route': 'penduduk',
    },
    {
      'title': 'Angka Kemiskinan Jawa Timur 2020–2024',
      'date': '15 Maret 2025',
      'category': 'Sosial',
      'type': 'Statistik',
      'iconData': Icons.trending_down_outlined,
      'iconColor': Color(0xFFDC2626),
      'route': 'kemiskinan',
    },
    {
      'title': 'Indeks Pembangunan Manusia (IPM) Jatim 2024',
      'date': '20 Februari 2025',
      'category': 'Sosial',
      'type': 'Publikasi',
      'iconData': Icons.school_outlined,
      'iconColor': Color(0xFF0891B2),
      'route': 'ipm',
    },
    {
      'title': 'Realisasi APBD Jawa Timur Tahun 2024',
      'date': '28 Februari 2025',
      'category': 'Keuangan',
      'type': 'Dataset',
      'iconData': Icons.account_balance_outlined,
      'iconColor': Color(0xFF059669),
      'route': 'apbd',
    },
    {
      'title': 'Sebaran Fasilitas Kesehatan Jawa Timur 2024',
      'date': '10 Januari 2025',
      'category': 'Kesehatan',
      'type': 'Dataset',
      'iconData': Icons.local_hospital_outlined,
      'iconColor': Color(0xFFE11D48),
      'route': 'faskes',
    },
    {
      'title': 'Statistik Pariwisata Jawa Timur Q4 2024',
      'date': '05 April 2025',
      'category': 'Pariwisata',
      'type': 'Statistik',
      'iconData': Icons.beach_access_outlined,
      'iconColor': Color(0xFF0284C7),
      'route': 'pariwisata',
    },
    {
      'title': 'Tren Inflasi Harga Pangan Jawa Timur 2024',
      'date': '12 Maret 2025',
      'category': 'Ekonomi',
      'type': 'Berita',
      'iconData': Icons.show_chart,
      'iconColor': Color(0xFFB45309),
      'route': 'inflasi',
    },
    {
      'title': 'Data Infrastruktur Jalan Provinsi Jawa Timur 2024',
      'date': '03 Maret 2025',
      'category': 'Infrastruktur',
      'type': 'Dataset',
      'iconData': Icons.alt_route_outlined,
      'iconColor': Color(0xFF475569),
      'route': 'infrastruktur',
    },
    {
      'title': 'Tingkat Pengangguran Terbuka (TPT) Jatim 2024',
      'date': '22 Februari 2025',
      'category': 'Ketenagakerjaan',
      'type': 'Statistik',
      'iconData': Icons.work_outline,
      'iconColor': Color(0xFF9333EA),
      'route': 'tpt',
    },
  ];

  List<Map<String, dynamic>> get _filteredItems {
    final query = _searchController.text.trim().toLowerCase();
    return _allItems.where((item) {
      final matchesSearch =
          query.isEmpty || (item['title'] as String).toLowerCase().contains(query);
      final matchesCategory =
          _selectedCategory == 'Semua' || item['type'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openItem(Map<String, dynamic> item) {
    final route = item['route'] as String?;
    if (route == 'datasebaran') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const OpenDataDataSebaranPage()));
    } else if (route == 'dapurmbg') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const OpenDataDapurMBGPage()));
    } else if (route == 'ayopasok') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const OpenDataAyoPasokPage()));
    } else if (route != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => OpenDataDetailPage(dataRoute: route)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data "${item['title']}" akan segera tersedia'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 250,
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
                          'Cari Data',
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
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: _blue.withValues(alpha: 0.3),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0D000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14,
                                color: Color(0xFF1F2937),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Cari dataset, artikel, infografis...',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 14,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                                border: InputBorder.none,
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.close,
                                            color: Colors.grey, size: 20),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {});
                                        },
                                      )
                                    : const Padding(
                                        padding: EdgeInsets.only(right: 8),
                                        child: Icon(Icons.search,
                                            color: _blue, size: 26),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 24, bottom: 12),
                          child: Text(
                            items.isEmpty
                                ? 'Tidak ditemukan hasil'
                                : '${items.length} hasil ditemukan',
                            style: const TextStyle(
                              fontSize: 15,
                              fontFamily: 'PlusJakartaSans',
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                          child: ListView.separated(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 8),
                            itemBuilder: (_, i) {
                              final cat = _categories[i];
                              final isSelected = _selectedCategory == cat;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedCategory = cat),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? _blue
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? _blue
                                          : const Color(0xFFE0E0E0),
                                    ),
                                  ),
                                  child: Text(
                                    cat,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF4B5563),
                                      fontFamily: 'PlusJakartaSans',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: items.isEmpty
                              ? _buildEmptyState()
                              : ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 8, 16, 24),
                                  itemCount: items.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (_, i) =>
                                      _buildCard(items[i]),
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

  Widget _buildEmptyState() {
    return const EmptyState(
      icon: Icons.search_off_rounded,
      title: 'Hasil pencarian tidak ditemukan',
      subtitle:
          'Tidak ada open data yang cocok dengan filter saat ini.\nCoba ubah kata kunci atau pilih kategori lain.',
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    final iconData = item['iconData'] as IconData;
    final iconColor = item['iconColor'] as Color;

    return GestureDetector(
      onTap: () => _openItem(item),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 4,
                    children: [
                      _meta(Icons.calendar_today_outlined, item['date'] as String),
                      _meta(Icons.business_outlined, item['category'] as String),
                      _metaBadge(item['type'] as String),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: const Color(0xFF6B7280)),
        const SizedBox(width: 3),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontFamily: 'PlusJakartaSans',
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _metaBadge(String type) {
    final color = _typeColor(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 10,
          fontFamily: 'PlusJakartaSans',
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'Dataset':     return const Color(0xFF2563EB);
      case 'Artikel':     return const Color(0xFF16A34A);
      case 'Infografis':  return const Color(0xFFEA580C);
      case 'Publikasi':   return const Color(0xFF0891B2);
      case 'Statistik':   return const Color(0xFF7C3AED);
      case 'Berita':      return const Color(0xFFB45309);
      default:            return const Color(0xFF6B7280);
    }
  }
}
