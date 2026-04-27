import 'package:flutter/material.dart';
import '../app_route.dart';
import '../rsud/hospital_config.dart';

enum SearchCategory {
  layanan,
  rsud,
  fitur,
  openData,
  profil,
}

extension SearchCategoryX on SearchCategory {
  String get label {
    switch (this) {
      case SearchCategory.layanan:
        return 'Layanan';
      case SearchCategory.rsud:
        return 'RSUD';
      case SearchCategory.fitur:
        return 'Sub-Fitur';
      case SearchCategory.openData:
        return 'Open Data';
      case SearchCategory.profil:
        return 'Profil';
    }
  }

  IconData get icon {
    switch (this) {
      case SearchCategory.layanan:
        return Icons.apps_rounded;
      case SearchCategory.rsud:
        return Icons.local_hospital_rounded;
      case SearchCategory.fitur:
        return Icons.tune_rounded;
      case SearchCategory.openData:
        return Icons.dataset_rounded;
      case SearchCategory.profil:
        return Icons.person_rounded;
    }
  }
}

class SearchableItem {
  final String id;
  final String title;
  final String subtitle;
  final SearchCategory category;
  final IconData icon;
  final List<String> keywords;
  final String? route;
  final Object? routeArguments;

  const SearchableItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.icon,
    this.keywords = const [],
    this.route,
    this.routeArguments,
  });
}

class SearchIndex {
  static final List<SearchableItem> all = [
    // ── Layanan utama ──────────────────────────────────────────────────────
    const SearchableItem(
      id: 'bapenda',
      title: 'BAPENDA',
      subtitle: 'Pajak kendaraan, NJKB, info pajak',
      category: SearchCategory.layanan,
      icon: Icons.account_balance_rounded,
      keywords: ['pajak', 'kendaraan', 'samsat', 'pkb', 'bbnkb', 'njkb'],
      route: AppRoutes.bapendaPage,
    ),
    const SearchableItem(
      id: 'transjatim',
      title: 'Transjatim',
      subtitle: 'Jadwal & tiket bus Trans Jatim',
      category: SearchCategory.layanan,
      icon: Icons.directions_bus_rounded,
      keywords: ['transportasi', 'bus', 'tiket', 'koridor', 'rute'],
      route: AppRoutes.transjatimPage,
    ),
    const SearchableItem(
      id: 'siskaperbapo',
      title: 'SISKAPERBAPO',
      subtitle: 'Sistem informasi harga bahan pokok',
      category: SearchCategory.layanan,
      icon: Icons.storefront_rounded,
      keywords: [
        'harga', 'sembako', 'pasar', 'bahan pokok', 'inflasi', 'pangan',
      ],
      route: AppRoutes.siskaperbapoPage,
    ),
    const SearchableItem(
      id: 'sapa_bansos',
      title: 'SAPA BANSOS',
      subtitle: 'Cek bantuan sosial & program',
      category: SearchCategory.layanan,
      icon: Icons.volunteer_activism_rounded,
      keywords: ['bantuan', 'sosial', 'pkh', 'bpnt', 'subsidi', 'kemiskinan'],
      route: AppRoutes.sapaBansosPage,
    ),
    const SearchableItem(
      id: 'etibi',
      title: 'E-TIBI',
      subtitle: 'Layanan ketertiban & pengaduan',
      category: SearchCategory.layanan,
      icon: Icons.medical_services_rounded,
      keywords: ['ketertiban', 'pengaduan', 'satpol', 'pp'],
      route: AppRoutes.etibiPage,
    ),
    const SearchableItem(
      id: 'klinik_hoaks',
      title: 'Klinik Hoaks',
      subtitle: 'Lapor & cek berita hoaks',
      category: SearchCategory.layanan,
      icon: Icons.fact_check_rounded,
      keywords: [
        'hoaks', 'hoax', 'berita', 'palsu', 'bohong', 'verifikasi', 'fakta',
      ],
      route: AppRoutes.klinikHoaksLandingPage,
    ),
    const SearchableItem(
      id: 'open_data',
      title: 'Open Data',
      subtitle: 'Dataset, statistik & publikasi Jatim',
      category: SearchCategory.layanan,
      icon: Icons.dataset_rounded,
      keywords: ['data', 'dataset', 'statistik', 'publikasi', 'infografis'],
      route: AppRoutes.openDataLandingPage,
    ),
    const SearchableItem(
      id: 'nomor_darurat',
      title: 'Nomor Darurat',
      subtitle: 'Kontak penting & gawat darurat',
      category: SearchCategory.layanan,
      icon: Icons.emergency_rounded,
      keywords: [
        'darurat', 'sos', 'polisi', 'pemadam', 'ambulans', 'kebakaran',
        '112', '110', '113',
      ],
      route: AppRoutes.nomorDaruratLandingPage,
    ),
    const SearchableItem(
      id: 'maja_ai',
      title: 'Maja AI',
      subtitle: 'Asisten virtual layanan publik',
      category: SearchCategory.layanan,
      icon: Icons.smart_toy_rounded,
      keywords: ['ai', 'chatbot', 'asisten', 'tanya', 'gemini', 'bantuan'],
      route: AppRoutes.majaAiChatPage,
    ),

    // ── RSUD ───────────────────────────────────────────────────────────────
    SearchableItem(
      id: 'rsud_daha_husada',
      title: 'RSUD Daha Husada',
      subtitle: 'Rumah sakit umum daerah — Kediri',
      category: SearchCategory.rsud,
      icon: Icons.local_hospital_rounded,
      keywords: const [
        'rsud', 'rumah sakit', 'hospital', 'kediri', 'daha', 'husada',
      ],
      route: AppRoutes.rsudPage,
      routeArguments: HospitalConfig.dahaHusada,
    ),
    SearchableItem(
      id: 'rsud_saiful_anwar',
      title: 'RSUD Saiful Anwar',
      subtitle: 'Rumah sakit umum daerah — Malang',
      category: SearchCategory.rsud,
      icon: Icons.local_hospital_rounded,
      keywords: const [
        'rsud', 'rumah sakit', 'hospital', 'malang', 'saiful', 'anwar', 'rssa',
      ],
      route: AppRoutes.rsudPage,
      routeArguments: HospitalConfig.saifulAnwar,
    ),
    SearchableItem(
      id: 'rsud_karsa_husada',
      title: 'RSUD Karsa Husada',
      subtitle: 'Rumah sakit umum daerah — Batu',
      category: SearchCategory.rsud,
      icon: Icons.local_hospital_rounded,
      keywords: const [
        'rsud', 'rumah sakit', 'hospital', 'batu', 'karsa', 'husada',
      ],
      route: AppRoutes.rsudPage,
      routeArguments: HospitalConfig.karsaHusada,
    ),
    SearchableItem(
      id: 'rsud_prov_jatim',
      title: 'RSUD Prov. Jawa Timur',
      subtitle: 'Rumah sakit umum daerah — Surabaya',
      category: SearchCategory.rsud,
      icon: Icons.local_hospital_rounded,
      keywords: const [
        'rsud', 'rumah sakit', 'hospital', 'surabaya', 'jatim', 'provinsi',
      ],
      route: AppRoutes.rsudPage,
      routeArguments: HospitalConfig.provJatim,
    ),

    // ── Sub-fitur ──────────────────────────────────────────────────────────
    const SearchableItem(
      id: 'info_pajak',
      title: 'Info Pajak Kendaraan',
      subtitle: 'Cek tagihan PKB lewat plat nomor',
      category: SearchCategory.fitur,
      icon: Icons.receipt_long_rounded,
      keywords: [
        'pajak', 'kendaraan', 'plat', 'nomor', 'pkb', 'samsat', 'bapenda',
      ],
      route: AppRoutes.infoPajakPage,
    ),
    const SearchableItem(
      id: 'estimasi_njkb',
      title: 'Estimasi NJKB',
      subtitle: 'Hitung Nilai Jual Kendaraan Bermotor',
      category: SearchCategory.fitur,
      icon: Icons.calculate_rounded,
      keywords: ['njkb', 'estimasi', 'pajak', 'kendaraan', 'bapenda'],
      route: AppRoutes.estimasiNjkbPage,
    ),
    const SearchableItem(
      id: 'lapor_hoaks',
      title: 'Lapor Hoaks',
      subtitle: 'Kirim laporan berita hoaks',
      category: SearchCategory.fitur,
      icon: Icons.report_rounded,
      keywords: ['lapor', 'hoaks', 'hoax', 'pengaduan', 'berita palsu'],
      route: AppRoutes.klinikHoaksPermohonanPage,
    ),
    const SearchableItem(
      id: 'cari_nomor_darurat',
      title: 'Cari Nomor Darurat',
      subtitle: 'Cari kontak instansi darurat per kota',
      category: SearchCategory.fitur,
      icon: Icons.search_rounded,
      keywords: [
        'darurat', 'nomor', 'polisi', 'damkar', 'pemadam', 'sar', 'pln',
      ],
      route: AppRoutes.nomorDaruratCariNomorPage,
    ),
    const SearchableItem(
      id: 'tambah_layanan',
      title: 'Tambah Layanan',
      subtitle: 'Sesuaikan layanan favorit di beranda',
      category: SearchCategory.fitur,
      icon: Icons.add_circle_outline_rounded,
      keywords: ['tambah', 'layanan', 'kustom', 'pin', 'beranda'],
      route: AppRoutes.tambahLayananPage,
    ),
    const SearchableItem(
      id: 'notifikasi',
      title: 'Notifikasi',
      subtitle: 'Pemberitahuan & pengumuman',
      category: SearchCategory.fitur,
      icon: Icons.notifications_rounded,
      keywords: ['notifikasi', 'pengumuman', 'inbox', 'pemberitahuan'],
      route: AppRoutes.notifikasiPage,
    ),

    // ── Open Data populer ──────────────────────────────────────────────────
    const SearchableItem(
      id: 'opendata_dapur_mbg',
      title: 'Dapur Makan Bergizi Gratis (MBG)',
      subtitle: 'Open Data · Artikel sosial',
      category: SearchCategory.openData,
      icon: Icons.restaurant_rounded,
      keywords: [
        'mbg', 'dapur', 'makan', 'bergizi', 'gratis', 'gizi', 'sosial',
      ],
      route: AppRoutes.openDataDapurMBGPage,
    ),
    const SearchableItem(
      id: 'opendata_ayo_pasok',
      title: 'Ayo Pasok Bahan Pangan',
      subtitle: 'Open Data · Program MBG',
      category: SearchCategory.openData,
      icon: Icons.agriculture_rounded,
      keywords: [
        'pasok', 'pangan', 'mbg', 'umkm', 'pemasok', 'petani', 'pertanian',
      ],
      route: AppRoutes.openDataAyoPasokPage,
    ),
    const SearchableItem(
      id: 'opendata_list',
      title: 'Daftar Open Data Jatim',
      subtitle: 'Dataset, statistik, infografis',
      category: SearchCategory.openData,
      icon: Icons.list_alt_rounded,
      keywords: [
        'data', 'dataset', 'statistik', 'umkm', 'penduduk', 'apbd', 'ipm',
        'kemiskinan', 'pariwisata', 'inflasi', 'faskes', 'kesehatan',
      ],
      route: AppRoutes.openDataListPage,
    ),

    // ── Profil ─────────────────────────────────────────────────────────────
    const SearchableItem(
      id: 'ubah_profil',
      title: 'Ubah Profil',
      subtitle: 'Perbarui nama, foto & data diri',
      category: SearchCategory.profil,
      icon: Icons.edit_rounded,
      keywords: ['profil', 'edit', 'ubah', 'nama', 'foto'],
      route: AppRoutes.ubahProfilPage,
    ),
    const SearchableItem(
      id: 'keamanan_akun',
      title: 'Keamanan Akun',
      subtitle: 'Ganti password, verifikasi email',
      category: SearchCategory.profil,
      icon: Icons.shield_rounded,
      keywords: [
        'keamanan', 'password', 'sandi', 'akun', 'login', '2fa', 'verifikasi',
      ],
      route: AppRoutes.keamananAkunPage,
    ),
  ];

  /// Cari item berdasarkan query string. Pencocokan case-insensitive
  /// terhadap title, subtitle, dan keywords. Hasil di-rank: title prefix
  /// > title contains > keyword exact > subtitle/keyword contains.
  static List<SearchableItem> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];

    final scored = <_ScoredItem>[];
    for (final item in all) {
      final title = item.title.toLowerCase();
      final subtitle = item.subtitle.toLowerCase();

      int score = 0;
      if (title == q) {
        score = 100;
      } else if (title.startsWith(q)) {
        score = 80;
      } else if (title.contains(q)) {
        score = 60;
      } else if (item.keywords.any((k) => k.toLowerCase() == q)) {
        score = 50;
      } else if (item.keywords.any((k) => k.toLowerCase().contains(q))) {
        score = 30;
      } else if (subtitle.contains(q)) {
        score = 20;
      }

      if (score > 0) scored.add(_ScoredItem(item, score));
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.map((e) => e.item).toList();
  }
}

class _ScoredItem {
  final SearchableItem item;
  final int score;
  const _ScoredItem(this.item, this.score);
}
