import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/empty_state.dart';

class OpenDataDetailPage extends StatelessWidget {
  final String dataRoute;
  const OpenDataDetailPage({super.key, required this.dataRoute});

  static const _blue = Color(0xFF007AFF);

  @override
  Widget build(BuildContext context) {
    final c = _content[dataRoute];
    if (c == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: _blue,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        body: EmptyState(
          icon: Icons.dataset_outlined,
          title: 'Data tidak ditemukan',
          subtitle:
              'Halaman detail untuk dataset ini belum tersedia.\nKembali ke daftar dan pilih dataset lain.',
          actionLabel: 'Kembali',
          onAction: () => Navigator.pop(context),
        ),
      );
    }

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
                          'Detail Data',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(c),
                          const SizedBox(height: 20),
                          _buildDescription(c),
                          const SizedBox(height: 20),
                          if (c.stats.isNotEmpty) ...[
                            _buildStats(c),
                            const SizedBox(height: 20),
                          ],
                          if (c.tableHeaders.isNotEmpty) ...[
                            _buildTable(c),
                            const SizedBox(height: 20),
                          ],
                          _buildDownloadButton(context, c),
                        ],
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

  Widget _buildHeader(_Content c) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: c.iconColor.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(c.iconData, color: c.iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _typeBadge(c.type),
                    const SizedBox(height: 4),
                    Text(c.category, style: const TextStyle(color: Color(0xFF6B7280), fontFamily: 'PlusJakartaSans', fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(c.title, style: const TextStyle(color: Color(0xFF1F2937), fontFamily: 'PlusJakartaSans', fontSize: 16, fontWeight: FontWeight.w700, height: 1.4)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 12, color: Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Text(c.date, style: const TextStyle(color: Color(0xFF6B7280), fontFamily: 'PlusJakartaSans', fontSize: 12)),
              const SizedBox(width: 12),
              const Icon(Icons.folder_outlined, size: 12, color: Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Text(c.source, style: const TextStyle(color: Color(0xFF6B7280), fontFamily: 'PlusJakartaSans', fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _typeBadge(String type) {
    final color = _typeColor(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
      child: Text(type, style: TextStyle(color: color, fontFamily: 'PlusJakartaSans', fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildDescription(_Content c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF5FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(c.description, style: const TextStyle(color: Color(0xFF1D4ED8), fontFamily: 'PlusJakartaSans', fontSize: 13, height: 1.6)),
    );
  }

  Widget _buildStats(_Content c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ringkasan Data', style: TextStyle(color: Color(0xFF1F2937), fontFamily: 'PlusJakartaSans', fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.6,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: c.stats.map((s) => _buildStatBox(s)).toList(),
        ),
      ],
    );
  }

  Widget _buildStatBox(_Stat s) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(s.value, style: TextStyle(color: s.color ?? _blue, fontFamily: 'PlusJakartaSans', fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(s.label, style: const TextStyle(color: Color(0xFF6B7280), fontFamily: 'PlusJakartaSans', fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildTable(_Content c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(c.tableTitle ?? 'Data', style: const TextStyle(color: Color(0xFF1F2937), fontFamily: 'PlusJakartaSans', fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 4))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Table(
              columnWidths: const {0: FlexColumnWidth(2.2), 1: FlexColumnWidth(1)},
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFF007AFF)),
                  children: c.tableHeaders.map((h) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Text(h, style: const TextStyle(color: Colors.white, fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w700)),
                  )).toList(),
                ),
                ...c.tableRows.asMap().entries.map((entry) {
                  final isEven = entry.key.isEven;
                  return TableRow(
                    decoration: BoxDecoration(color: isEven ? const Color(0xFFF9FAFB) : Colors.white),
                    children: entry.value.map((cell) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Text(cell, style: const TextStyle(color: Color(0xFF1F2937), fontFamily: 'PlusJakartaSans', fontSize: 12)),
                    )).toList(),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadButton(BuildContext context, _Content c) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => _launchUrl(c.downloadUrl),
        icon: const Icon(Icons.download_rounded, color: Colors.white, size: 20),
        label: const Text('Unduh Dataset', style: TextStyle(color: Colors.white, fontFamily: 'PlusJakartaSans', fontSize: 15, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _blue,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'Dataset':    return const Color(0xFF2563EB);
      case 'Artikel':    return const Color(0xFF16A34A);
      case 'Infografis': return const Color(0xFFEA580C);
      case 'Publikasi':  return const Color(0xFF0891B2);
      case 'Statistik':  return const Color(0xFF7C3AED);
      case 'Berita':     return const Color(0xFFB45309);
      default:           return const Color(0xFF6B7280);
    }
  }

  // ── Content Data ────────────────────────────────────────────────────────────

  static final Map<String, _Content> _content = {
    'penduduk': _Content(
      title: 'Jumlah Penduduk Jawa Timur Per Kabupaten/Kota 2024',
      date: '01 Januari 2025',
      category: 'Kependudukan',
      type: 'Dataset',
      source: 'BPS Jawa Timur',
      iconData: Icons.people_outline,
      iconColor: Color(0xFF7C3AED),
      description: 'Dataset jumlah penduduk 38 kabupaten/kota di Provinsi Jawa Timur berdasarkan hasil proyeksi penduduk tahun 2024. Data mencakup total penduduk, kepadatan, serta rasio jenis kelamin.',
      stats: [
        _Stat('41,16 jt', 'Total Penduduk Jatim', color: Color(0xFF7C3AED)),
        _Stat('38', 'Kab/Kota', color: Color(0xFF0891B2)),
        _Stat('855/km²', 'Kepadatan Rata-rata', color: Color(0xFF059669)),
        _Stat('99,7', 'Rasio Jenis Kelamin', color: Color(0xFFEA580C)),
      ],
      tableTitle: 'Penduduk 10 Kota/Kabupaten Terbesar',
      tableHeaders: ['Kota / Kabupaten', 'Penduduk'],
      tableRows: [
        ['Kota Surabaya', '2.980.000'],
        ['Kab. Malang', '2.680.000'],
        ['Kab. Jember', '2.440.000'],
        ['Kab. Sidoarjo', '2.350.000'],
        ['Kab. Banyuwangi', '1.720.000'],
        ['Kab. Kediri', '1.680.000'],
        ['Kab. Pasuruan', '1.580.000'],
        ['Kab. Gresik', '1.380.000'],
        ['Kab. Lamongan', '1.340.000'],
        ['Kab. Mojokerto', '1.230.000'],
      ],
      downloadUrl: 'https://opendata.jatimprov.go.id/',
    ),

    'kemiskinan': _Content(
      title: 'Angka Kemiskinan Jawa Timur 2020–2024',
      date: '15 Maret 2025',
      category: 'Sosial',
      type: 'Statistik',
      source: 'BPS Jawa Timur',
      iconData: Icons.trending_down_outlined,
      iconColor: Color(0xFFDC2626),
      description: 'Data perkembangan tingkat kemiskinan Provinsi Jawa Timur periode 2020–2024 berdasarkan survei sosial ekonomi nasional (Susenas) yang dilaksanakan setiap tahun oleh BPS.',
      stats: [
        _Stat('10,16%', 'Tingkat Kemiskinan 2024', color: Color(0xFFDC2626)),
        _Stat('4,2 jt', 'Penduduk Miskin', color: Color(0xFFEA580C)),
        _Stat('-0,58%', 'Penurunan vs 2023', color: Color(0xFF059669)),
        _Stat('11,40%', 'Rata-rata 2020–2024', color: Color(0xFF7C3AED)),
      ],
      tableTitle: 'Tren Angka Kemiskinan 2020–2024',
      tableHeaders: ['Tahun', 'Persentase'],
      tableRows: [
        ['2020', '11,46%'],
        ['2021', '11,40%'],
        ['2022', '10,86%'],
        ['2023', '10,74%'],
        ['2024', '10,16%'],
      ],
      downloadUrl: 'https://opendata.jatimprov.go.id/',
    ),

    'ipm': _Content(
      title: 'Indeks Pembangunan Manusia (IPM) Jatim 2024',
      date: '20 Februari 2025',
      category: 'Sosial',
      type: 'Publikasi',
      source: 'BPS Jawa Timur',
      iconData: Icons.school_outlined,
      iconColor: Color(0xFF0891B2),
      description: 'Indeks Pembangunan Manusia (IPM) mengukur capaian pembangunan manusia berbasis sejumlah komponen dasar kualitas hidup: kesehatan, pendidikan, dan standar hidup layak. Publikasi IPM Jawa Timur tahun 2024.',
      stats: [
        _Stat('74,65', 'IPM Jawa Timur 2024', color: Color(0xFF0891B2)),
        _Stat('+0,72', 'Kenaikan vs 2023', color: Color(0xFF059669)),
        _Stat('73,55', 'Rata-rata Nasional', color: Color(0xFF7C3AED)),
        _Stat('Tinggi', 'Kategori IPM', color: Color(0xFFEA580C)),
      ],
      tableTitle: 'IPM 5 Kabupaten/Kota Teratas 2024',
      tableHeaders: ['Kota / Kabupaten', 'Nilai IPM'],
      tableRows: [
        ['Kota Malang', '83,80'],
        ['Kota Surabaya', '83,15'],
        ['Kota Madiun', '82,44'],
        ['Kota Blitar', '81,36'],
        ['Kota Kediri', '80,91'],
      ],
      downloadUrl: 'https://opendata.jatimprov.go.id/',
    ),

    'apbd': _Content(
      title: 'Realisasi APBD Jawa Timur Tahun 2024',
      date: '28 Februari 2025',
      category: 'Keuangan',
      type: 'Dataset',
      source: 'BPKAD Jawa Timur',
      iconData: Icons.account_balance_outlined,
      iconColor: Color(0xFF059669),
      description: 'Dataset realisasi anggaran pendapatan dan belanja daerah (APBD) Provinsi Jawa Timur tahun anggaran 2024. Meliputi pendapatan asli daerah, dana transfer, dan realisasi belanja.',
      stats: [
        _Stat('Rp 37,2 T', 'Total Pendapatan', color: Color(0xFF059669)),
        _Stat('Rp 34,8 T', 'Total Belanja', color: Color(0xFFDC2626)),
        _Stat('94,1%', 'Serapan Anggaran', color: Color(0xFF0891B2)),
        _Stat('Rp 2,4 T', 'Surplus Anggaran', color: Color(0xFF7C3AED)),
      ],
      tableTitle: 'Rincian Realisasi APBD 2024',
      tableHeaders: ['Komponen', 'Realisasi'],
      tableRows: [
        ['Pendapatan Asli Daerah', 'Rp 12,4 T'],
        ['Dana Transfer Pusat', 'Rp 20,1 T'],
        ['Lain-lain Pendapatan', 'Rp 4,7 T'],
        ['Belanja Operasi', 'Rp 22,3 T'],
        ['Belanja Modal', 'Rp 8,6 T'],
        ['Belanja Transfer', 'Rp 3,9 T'],
      ],
      downloadUrl: 'https://opendata.jatimprov.go.id/',
    ),

    'faskes': _Content(
      title: 'Sebaran Fasilitas Kesehatan Jawa Timur 2024',
      date: '10 Januari 2025',
      category: 'Kesehatan',
      type: 'Dataset',
      source: 'Dinkes Jawa Timur',
      iconData: Icons.local_hospital_outlined,
      iconColor: Color(0xFFE11D48),
      description: 'Dataset sebaran fasilitas pelayanan kesehatan di seluruh wilayah Provinsi Jawa Timur tahun 2024, mencakup rumah sakit, puskesmas, klinik, apotek, dan laboratorium kesehatan.',
      stats: [
        _Stat('376', 'Rumah Sakit', color: Color(0xFFE11D48)),
        _Stat('970', 'Puskesmas', color: Color(0xFF0891B2)),
        _Stat('3.280', 'Klinik', color: Color(0xFF059669)),
        _Stat('6.142', 'Apotek', color: Color(0xFF7C3AED)),
      ],
      tableTitle: 'Jumlah Faskes per Jenis',
      tableHeaders: ['Jenis Fasilitas', 'Jumlah'],
      tableRows: [
        ['Rumah Sakit Umum', '289'],
        ['Rumah Sakit Khusus', '87'],
        ['Puskesmas (rawat inap)', '436'],
        ['Puskesmas (non-RI)', '534'],
        ['Klinik Pratama', '2.640'],
        ['Klinik Utama', '640'],
        ['Laboratorium', '312'],
      ],
      downloadUrl: 'https://opendata.jatimprov.go.id/',
    ),

    'pariwisata': _Content(
      title: 'Statistik Pariwisata Jawa Timur Q4 2024',
      date: '05 April 2025',
      category: 'Pariwisata',
      type: 'Statistik',
      source: 'Dispar Jawa Timur',
      iconData: Icons.beach_access_outlined,
      iconColor: Color(0xFF0284C7),
      description: 'Statistik kunjungan wisatawan nusantara dan mancanegara ke destinasi wisata di Provinsi Jawa Timur pada kuartal keempat tahun 2024 (Oktober – Desember).',
      stats: [
        _Stat('18,4 jt', 'Wisatawan Q4 2024', color: Color(0xFF0284C7)),
        _Stat('142 rb', 'Wisman Q4 2024', color: Color(0xFFEA580C)),
        _Stat('+12,3%', 'Pertumbuhan YoY', color: Color(0xFF059669)),
        _Stat('3,2 hari', 'Rata-rata Menginap', color: Color(0xFF7C3AED)),
      ],
      tableTitle: '5 Destinasi Terpopuler Q4 2024',
      tableHeaders: ['Destinasi', 'Kunjungan'],
      tableRows: [
        ['Bromo Tengger Semeru', '1.240.000'],
        ['Kawah Ijen', '890.000'],
        ['Pantai Banyuwangi', '760.000'],
        ['Gunung Kelud', '580.000'],
        ['Taman Safari Prigen', '470.000'],
      ],
      downloadUrl: 'https://opendata.jatimprov.go.id/',
    ),

    'inflasi': _Content(
      title: 'Tren Inflasi Harga Pangan Jawa Timur 2024',
      date: '12 Maret 2025',
      category: 'Ekonomi',
      type: 'Berita',
      source: 'BPS & BI Jawa Timur',
      iconData: Icons.show_chart,
      iconColor: Color(0xFFB45309),
      description: 'Analisis tren inflasi harga bahan pangan di Provinsi Jawa Timur sepanjang tahun 2024, dengan fokus pada komoditas volatile food yang paling berpengaruh terhadap inflasi daerah.',
      stats: [
        _Stat('2,84%', 'Inflasi Pangan 2024', color: Color(0xFFB45309)),
        _Stat('3,12%', 'Inflasi Nasional 2024', color: Color(0xFFDC2626)),
        _Stat('Jan', 'Bulan Tertinggi', color: Color(0xFFEA580C)),
        _Stat('-0,28%', 'Bawah Nasional', color: Color(0xFF059669)),
      ],
      tableTitle: 'Inflasi Bulanan Pangan 2024',
      tableHeaders: ['Bulan', 'Inflasi (%)'],
      tableRows: [
        ['Januari', '0,58'],
        ['Februari', '0,22'],
        ['Maret', '0,18'],
        ['April', '-0,05'],
        ['Mei', '0,14'],
        ['Juni', '0,31'],
        ['Juli', '0,09'],
        ['Agustus', '-0,12'],
        ['September', '0,17'],
        ['Oktober', '0,25'],
        ['November', '0,43'],
        ['Desember', '0,64'],
      ],
      downloadUrl: 'https://opendata.jatimprov.go.id/',
    ),

    'infrastruktur': _Content(
      title: 'Data Infrastruktur Jalan Provinsi Jawa Timur 2024',
      date: '03 Maret 2025',
      category: 'Infrastruktur',
      type: 'Dataset',
      source: 'Dinas PU Jawa Timur',
      iconData: Icons.alt_route_outlined,
      iconColor: Color(0xFF475569),
      description: 'Dataset kondisi dan panjang jaringan jalan provinsi di Jawa Timur tahun 2024, mencakup klasifikasi berdasarkan kondisi jalan (baik, sedang, rusak ringan, rusak berat).',
      stats: [
        _Stat('3.983 km', 'Total Panjang Jalan', color: Color(0xFF475569)),
        _Stat('72,4%', 'Kondisi Baik', color: Color(0xFF059669)),
        _Stat('18,6%', 'Kondisi Sedang', color: Color(0xFFB45309)),
        _Stat('9,0%', 'Kondisi Rusak', color: Color(0xFFDC2626)),
      ],
      tableTitle: 'Kondisi Jalan Provinsi 2024',
      tableHeaders: ['Kondisi', 'Panjang (km)'],
      tableRows: [
        ['Baik', '2.883'],
        ['Sedang', '741'],
        ['Rusak Ringan', '247'],
        ['Rusak Berat', '112'],
        ['Total', '3.983'],
      ],
      downloadUrl: 'https://opendata.jatimprov.go.id/',
    ),

    'tpt': _Content(
      title: 'Tingkat Pengangguran Terbuka (TPT) Jatim 2024',
      date: '22 Februari 2025',
      category: 'Ketenagakerjaan',
      type: 'Statistik',
      source: 'BPS Jawa Timur',
      iconData: Icons.work_outline,
      iconColor: Color(0xFF9333EA),
      description: 'Data tingkat pengangguran terbuka (TPT) Jawa Timur tahun 2024 berdasarkan Survei Angkatan Kerja Nasional (Sakernas), dirinci menurut jenis kelamin, kelompok umur, dan tingkat pendidikan.',
      stats: [
        _Stat('4,52%', 'TPT Jawa Timur 2024', color: Color(0xFF9333EA)),
        _Stat('4,82%', 'TPT Nasional 2024', color: Color(0xFFDC2626)),
        _Stat('19,8 jt', 'Angkatan Kerja', color: Color(0xFF0891B2)),
        _Stat('-0,33%', 'Turun vs 2023', color: Color(0xFF059669)),
      ],
      tableTitle: 'TPT Berdasarkan Pendidikan Terakhir',
      tableHeaders: ['Pendidikan', 'TPT (%)'],
      tableRows: [
        ['Tidak tamat SD', '2,14'],
        ['SD / Sederajat', '2,87'],
        ['SMP / Sederajat', '4,16'],
        ['SMA / Sederajat', '7,24'],
        ['SMK', '9,42'],
        ['Diploma I/II/III', '5,38'],
        ['Universitas', '5,92'],
      ],
      downloadUrl: 'https://opendata.jatimprov.go.id/',
    ),
  };
}

// ── Data classes ──────────────────────────────────────────────────────────────

class _Content {
  final String title;
  final String date;
  final String category;
  final String type;
  final String source;
  final IconData iconData;
  final Color iconColor;
  final String description;
  final List<_Stat> stats;
  final String? tableTitle;
  final List<String> tableHeaders;
  final List<List<String>> tableRows;
  final String downloadUrl;

  const _Content({
    required this.title,
    required this.date,
    required this.category,
    required this.type,
    required this.source,
    required this.iconData,
    required this.iconColor,
    required this.description,
    this.stats = const [],
    this.tableTitle,
    this.tableHeaders = const [],
    this.tableRows = const [],
    required this.downloadUrl,
  });
}

class _Stat {
  final String value;
  final String label;
  final Color? color;

  const _Stat(this.value, this.label, {this.color});
}
