import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_route.dart';
import 'hospital_config.dart';

class RsudPage extends StatefulWidget {
  final HospitalConfig hospital;
  const RsudPage({super.key, required this.hospital});

  @override
  State<RsudPage> createState() => _RsudPageState();
}

class _RsudPageState extends State<RsudPage> {
  int _selectedTab = 0;
  bool _operasionalExpanded = true;
  bool _ketentuanExpanded = false;
  bool _isFavorite = false;

  String get _favKey => 'fav_rsud_${widget.hospital.id}';

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _isFavorite = prefs.getBool(_favKey) ?? false);
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final next = !_isFavorite;
    await prefs.setBool(_favKey, next);
    if (!mounted) return;
    setState(() => _isFavorite = next);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: next
            ? const Color.fromRGBO(0, 101, 255, 1)
            : const Color.fromRGBO(100, 100, 100, 1),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            Icon(
              next ? Icons.bookmark_rounded : Icons.bookmark_remove_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                next
                    ? '${widget.hospital.name} ditambahkan ke favorit'
                    : '${widget.hospital.name} dihapus dari favorit',
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _whiteBg = Color.fromRGBO(248, 248, 245, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);

  // ── Per-hospital Operasional data ─────────────────────────────────────────

  String get _hospitalUrl => const {
        'saiful_anwar': 'https://rsusaifulanwar.jatimprov.go.id/v2/',
        'karsa_husada': 'https://www.rsukarsahusadabatu.jatimprov.go.id/',
        'prov_jatim': 'https://app.rsuhaji.jatimprov.go.id/',
        'daha_husada': 'https://rsuddahahusada.jatimprov.go.id/',
      }[_id] ??
      'https://rsuddahahusada.jatimprov.go.id/';

  String get _alamat => const {
        'saiful_anwar':
            'Jl. Jaksa Agung Suprapto No.2, Klojen, Kota Malang, Jawa Timur 65112',
        'karsa_husada':
            'Jl. A. Yani No.10-13, Ngaglik, Kota Batu, Jawa Timur 65311',
        'prov_jatim':
            'Jl. Manyar Kertoadi No.10, Klampis Ngasem, Kec. Sukolilo, Surabaya, Jawa Timur 60116',
        'daha_husada':
            'Jl. Veteran No.48, Mojoroto, Kec. Mojoroto, Kota Kediri 64112',
      }[_id] ??
      '';

  List<String> get _jamOperasional {
    switch (_id) {
      case 'saiful_anwar':
        return [
          'Senin – Kamis  (07:00 – 13:00)',
          'Jumat          (07:00 – 14:00)',
          'IGD            (24 Jam)',
        ];
      case 'karsa_husada':
        return [
          'Senin – Jumat  (07:30 – 14:00)',
          'IGD            (24 Jam)',
        ];
      case 'prov_jatim':
        return [
          'Senin – Jumat  (07:00 – 14:00)',
          'IGD            (24 Jam)',
        ];
      default: // daha_husada
        return [
          'Senin  (07:00 – 21:00)',
          'Selasa (07:00 – 21:00)',
          'Rabu   (07:00 – 21:00)',
          'Kamis  (07:00 – 21:00)',
          'Jumat  (07:00 – 21:00)',
        ];
    }
  }

  List<_SocialMediaItem> get _socialMediaItems {
    switch (_id) {
      case 'saiful_anwar':
        return [
          _SocialMediaItem(
            icon: Icons.camera_alt_outlined,
            label: 'Instagram',
            url: 'https://www.instagram.com/rssaifulanwar',
          ),
          _SocialMediaItem(
            icon: Icons.facebook_rounded,
            label: 'Facebook',
            url: 'https://www.facebook.com/rssaifulanwar',
          ),
          _SocialMediaItem(
            icon: Icons.play_circle_outline_rounded,
            label: 'Youtube',
            url: 'https://www.youtube.com/@rssaifulanwar',
          ),
        ];
      case 'karsa_husada':
        return [
          _SocialMediaItem(
            icon: Icons.camera_alt_outlined,
            label: 'Instagram',
            url: 'https://www.instagram.com/rsudkarsahusada',
          ),
          _SocialMediaItem(
            icon: Icons.facebook_rounded,
            label: 'Facebook',
            url: 'https://www.facebook.com/rsukarsahusadabatu',
          ),
          _SocialMediaItem(
            icon: Icons.play_circle_outline_rounded,
            label: 'Youtube',
            url: 'https://www.youtube.com/@rsukarsahusadabatu',
          ),
        ];
      case 'prov_jatim':
        return [
          _SocialMediaItem(
            icon: Icons.camera_alt_outlined,
            label: 'Instagram',
            url: 'https://www.instagram.com/rsudhaji',
          ),
          _SocialMediaItem(
            icon: Icons.facebook_rounded,
            label: 'Facebook',
            url: 'https://www.facebook.com/rsudhajiprovinsijawatimur',
          ),
          _SocialMediaItem(
            icon: Icons.play_circle_outline_rounded,
            label: 'Youtube',
            url: 'https://www.youtube.com/@rsudhajiprovinsijawatimur6268',
          ),
        ];
      default: // daha_husada
        return [
          _SocialMediaItem(
            icon: Icons.camera_alt_outlined,
            label: 'Instagram',
            url: 'https://www.instagram.com/rsud.dahahusada',
          ),
          _SocialMediaItem(
            icon: Icons.facebook_rounded,
            label: 'Facebook',
            url: 'https://www.facebook.com/rsud.dh',
          ),
          _SocialMediaItem(
            icon: Icons.play_circle_outline_rounded,
            label: 'Youtube',
            url: 'https://www.youtube.com/@rsuddahahusada6821',
          ),
        ];
    }
  }

  // ── Per-hospital Ketentuan data ───────────────────────────────────────────

  String get _ketentuanIntro {
    switch (_id) {
      case 'saiful_anwar':
        return 'RSUD Dr. Saiful Anwar merupakan Rumah Sakit Umum Daerah kelas A milik Pemerintah Provinsi Jawa Timur yang bertugas memberikan pelayanan kesehatan perorangan secara paripurna. Fungsi yang diemban antara lain:';
      case 'karsa_husada':
        return 'RSU Karsa Husada Batu merupakan Rumah Sakit Umum Daerah kelas B milik Pemerintah Provinsi Jawa Timur yang menyelenggarakan berbagai pelayanan kesehatan. Fungsi yang diemban antara lain:';
      case 'prov_jatim':
        return 'RSUD Haji Provinsi Jawa Timur merupakan rumah sakit umum milik Pemerintah Provinsi Jawa Timur yang berkomitmen memberikan pelayanan kesehatan prima. Tugas dan fungsi utama rumah sakit ini meliputi:';
      default: // daha_husada
        return 'RSUD Daha Husada mempunyai tugas melaksanakan sebagian tugas Dinas Kesehatan di bidang promotif, preventif, kuratif, rehabilitatif, penelitian pengembangan, dan melaksanakan UKM Strata II di wilayah kerjanya. Untuk melaksanakan tugas tersebut, RSUD Daha Husada mempunyai fungsi, diantaranya:';
    }
  }

  List<String> get _manfaatList {
    switch (_id) {
      case 'saiful_anwar':
        return [
          'Pelayanan medis spesialistik dan subspesialistik lengkap',
          'Pelayanan gawat darurat 24 jam',
          'Pelayanan bedah jantung terbuka dan transplantasi ginjal',
          'Pelayanan rawat inap, ICU, ICCU, dan NICU',
          'Pelayanan hemodialisis dan onkologi',
          'Pelayanan laboratorium terintegrasi',
          'Penyelenggaraan pendidikan, penelitian, dan pengembangan ilmu kesehatan',
          'Pelayanan rujukan tingkat lanjut dari seluruh Jawa Timur',
          'Pelaksanaan monitoring dan evaluasi mutu pelayanan',
        ];
      case 'karsa_husada':
        return [
          'Pelayanan rawat jalan dengan 22 klinik spesialis',
          'Pelayanan gawat darurat (IGD) 24 jam',
          'Pelayanan rawat inap di berbagai kelas kamar',
          'Pelayanan hemodialisis (RISAL HD)',
          'Pelayanan bedah dan tindakan operatif',
          'Pelayanan medical tourism bagi wisatawan',
          'Pelayanan laboratorium, radiologi, dan bank darah',
          'Pelayanan rehabilitasi medik',
          'Pelayanan farmasi dan gizi klinik',
        ];
      case 'prov_jatim':
        return [
          'Pelayanan gawat darurat 24 jam dengan armada ambulans siaga',
          'Pelayanan rawat jalan dengan poli spesialis (anak, jantung, bedah, onkologi, dll.)',
          'Pelayanan rawat inap di berbagai kelas kamar',
          'Pelayanan diagnostik (laboratorium, radiologi, dan pencitraan medis)',
          'Pelayanan rehabilitasi medik',
          'Pelayanan medical check-up (MCU)',
          'Penyelenggaraan pelayanan rujukan dan konsultasi lanjutan',
          'Pelaksanaan penelitian dan pendidikan di bidang kesehatan',
          'Pelaksanaan koordinasi dan kemitraan dengan fasilitas kesehatan di Jawa Timur',
        ];
      default: // daha_husada
        return [
          'Penyusunan rencana dan program RSUD Daha Husada',
          'Pelaksanaan ketatausahaan',
          'Pengawasan dan pengendalian operasional rumah sakit',
          'Pelayanan medis',
          'Penyelenggaraan pelayanan penunjang medis dan non medis',
          'Pelaksanaan pelayanan kesehatan umum masyarakat',
          'Penyelenggaraan pelayanan dan asuhan keperawatan',
          'Penyelenggaraan pelayanan rujukan pasien, spesimen, IPTEK dan program',
          'Penyelenggaraan koordinasi dan kemitraan kegiatan Rumah Sakit Umum Daha Husada',
          'Penyelenggaraan penelitian, pengembangan dan diklat',
          'Pelaksanaan monitoring dan evaluasi program',
          'Pelaksanaan pembinaan wilayah di bidang teknis',
          'Pelaksanaan pelayanan kesehatan masyarakat (promotif, preventif, kuratif dan rehabilitatif) baik UKP maupun UKM di dalam gedung maupun di luar gedung di wilayah kerjanya',
          'Pelaksanaan tugas lain yang diberikan oleh kepala dinas',
        ];
    }
  }

  String get _pendaftaranPoliTitle {
    switch (_id) {
      case 'saiful_anwar':
        return 'Pendaftaran Online Rawat Jalan';
      case 'karsa_husada':
        return 'Pendaftaran Online Rawat Jalan (Non-BPJS)';
      case 'prov_jatim':
        return 'Pendaftaran Online Rawat Jalan';
      default:
        return 'Pendaftaran Online di Poli RSUD Daha Husada';
    }
  }

  List<String> get _pendaftaranPoliSteps {
    switch (_id) {
      case 'saiful_anwar':
        return [
          'Bagi pasien BPJS Kesehatan, pendaftaran dilakukan melalui aplikasi Mobile JKN',
          'Pastikan memiliki surat rujukan dari FKTP atau jadwal kontrol di poli RSUD Dr. Saiful Anwar',
          'Pilih menu "Pendaftaran" atau "Antrian Online" di aplikasi Mobile JKN dan ikuti petunjuk selanjutnya',
        ];
      case 'karsa_husada':
        return [
          'Kunjungi tautan pendaftaran online: https://tally.so/r/yPlLZ0',
          'Isi formulir pendaftaran dengan data diri dan keluhan secara lengkap',
          'Konfirmasi pendaftaran akan dikirimkan melalui nomor yang telah dicantumkan',
        ];
      case 'prov_jatim':
        return [
          'Kunjungi portal pendaftaran online di: https://app.rsuhaji.jatimprov.go.id/online/',
          'Pilih jadwal poli dan dokter yang tersedia',
          'Isi data diri dengan lengkap dan simpan nomor antrian yang diberikan',
        ];
      default:
        return [
          'Bagi pasien BPJS Kesehatan, pendaftaran menggunakan aplikasi Mobile JKN',
          'Untuk pasien umum dan asuransi lain, bisa daftar melalui WhatsApp. Caranya, kunjungi web resmi RSUD Daha Husada, pilih menu informasi, dan klik layanan pendaftaran online',
          'Pengguna akan diarahkan ke pesan WhatsApp admin RSUD Daha Husada',
        ];
    }
  }

  String get _pendaftaranBpjsTitle {
    switch (_id) {
      case 'saiful_anwar':
        return 'Layanan Pengaduan & Konsultasi (SAMBAT)';
      case 'karsa_husada':
        return 'Pendaftaran Online Via Mobile JKN (Pasien BPJS Kesehatan)';
      case 'prov_jatim':
        return 'Pendaftaran Via Mobile JKN (Pasien BPJS Kesehatan)';
      default:
        return 'Pendaftaran Online Via Mobile JKN (Khusus Pasien BPJS Kesehatan)';
    }
  }

  List<String> get _pendaftaranBpjsSteps {
    switch (_id) {
      case 'saiful_anwar':
        return [
          'Hubungi WhatsApp resmi SAMBAT di nomor +6281555606668',
          'Sampaikan keluhan, pertanyaan, atau kebutuhan konsultasi Anda',
          'Tim layanan akan merespons dan memberikan informasi yang dibutuhkan',
        ];
      case 'karsa_husada':
        return [
          'Unduh aplikasi Mobile JKN di Play Store atau App Store',
          'Login dengan akun JKN Anda; buat akun terlebih dahulu jika belum terdaftar',
          'Pilih menu "Pendaftaran Poli" dan pilih RSU Karsa Husada sebagai tujuan',
          'Pastikan memiliki surat rujukan dari FKTP atau jadwal kontrol yang masih aktif',
        ];
      case 'prov_jatim':
        return [
          'Unduh aplikasi Mobile JKN di Play Store atau App Store',
          'Login dan pilih menu "Pendaftaran Poli" atau "Antrian Online"',
          'Pilih RSUD Haji Provinsi Jawa Timur sebagai fasilitas tujuan',
          'Pastikan memiliki surat rujukan dari FKTP yang masih aktif',
        ];
      default:
        return [
          'Silakan download aplikasi Mobile JKN di Playstore/Appstore',
          'Bagi pengguna baru, silakan buat akun Mobile JKN terlebih dahulu. Siapkan NIK, no HP dan pastikan Anda punya pulsa regular minimal 5 ribu.',
          'Setelah membuat akun dan sudah terverifikasi, berikutnya ambil antrian di menu "Ambil antrian". Pastikan Anda punya surat rujukan dari FKTP atau memiliki jadwal kontrol di poli RSUD Daha Husada.',
        ];
    }
  }

  String get _id => widget.hospital.id;

  String get _telepon => const {
        'saiful_anwar': '(0341) 362101',
        'karsa_husada': '(0341) 596898',
        'prov_jatim': '(031) 5924000',
        'daha_husada': '0813-8230-0900',
      }[_id] ?? '';

  String get _teleponRaw => const {
        'saiful_anwar': '+62341362101',
        'karsa_husada': '+62341596898',
        'prov_jatim': '+62315924000',
        'daha_husada': '+6281382300900',
      }[_id] ?? '';

  String get _email => const {
        'saiful_anwar': 'drsaifulanwar@jatimprov.go.id',
        'karsa_husada': 'diklatpenelitian.rsuudkarsa@gmail.com',
        'prov_jatim': 'rshaji@jatimprov.go.id',
        'daha_husada': 'dahahusada@jatimprov.go.id',
      }[_id] ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _whiteBg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildTabBar(),
          const SizedBox(height: 16),
          Expanded(
            child: _selectedTab == 0
                ? _buildLayananTab()
                : _buildInformasiTab(),
          ),
        ],
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _blue,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      title: Text(
        widget.hospital.name,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'PlusJakartaSans',
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: _toggleFavorite,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isFavorite
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: _blue,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Tab Bar ───────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildTabItem(label: 'Layanan', index: 0),
            _buildTabItem(label: 'Informasi', index: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({required String label, required int index}) {
    final isActive = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isActive ? _blue : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : _textSecondary,
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // ── Tab Layanan ───────────────────────────────────────────────────────────

  Widget _buildLayananTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        children: [
          _buildLayananCard(
            icon: Icons.king_bed_rounded,
            title: 'Ketersediaan Kamar Rawat',
            description:
                'Informasi ketersediaan kamar rawat ${widget.hospital.name}',
            buttonLabel: 'Cek Ketersediaan',
            onButtonTap: () => Navigator.pushNamed(
                context, AppRoutes.ketersediaanKamarPage,
                arguments: widget.hospital),
          ),
          const SizedBox(height: 14),
          _buildLayananCard(
            icon: Icons.add_circle_outline_rounded,
            title: 'Jadwal Operasi',
            description:
                'Info jadwal tindakan operasi pasien ${widget.hospital.name}',
            buttonLabel: 'Lihat Jadwal',
            onButtonTap: () => Navigator.pushNamed(
                context, AppRoutes.jadwalOperasiPage,
                arguments: widget.hospital),
          ),
          const SizedBox(height: 14),
          _buildLayananCard(
            icon: Icons.groups_rounded,
            title: 'Info Antrean Pasien',
            description: 'Informasi antrean pasien ${widget.hospital.name}',
            buttonLabel: 'Lihat Antrean',
            onButtonTap: () => Navigator.pushNamed(
                context, AppRoutes.infoAntreanPage,
                arguments: widget.hospital),
          ),
        ],
      ),
    );
  }

  Widget _buildLayananCard({
    required IconData icon,
    required String title,
    required String description,
    required String buttonLabel,
    required VoidCallback onButtonTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(235, 243, 255, 1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _blue, size: 24),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: _textPrimary,
              fontFamily: 'PlusJakartaSans',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              color: _textSecondary,
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: onButtonTap,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _blue, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(
                  color: _blue,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab Informasi ─────────────────────────────────────────────────────────

  Widget _buildInformasiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        children: [
          _buildAccordion(
            icon: Icons.schedule_rounded,
            title: 'Operasional',
            subtitle: 'Informasi jam layanan, alamat & kontak',
            isExpanded: _operasionalExpanded,
            onToggle: () =>
                setState(() => _operasionalExpanded = !_operasionalExpanded),
            content: _buildOperasionalContent(),
          ),
          const SizedBox(height: 12),
          _buildAccordion(
            icon: Icons.description_rounded,
            title: 'Ketentuan Layanan',
            subtitle: 'Manfaat, prosedur & syarat pendaftaran',
            isExpanded: _ketentuanExpanded,
            onToggle: () =>
                setState(() => _ketentuanExpanded = !_ketentuanExpanded),
            content: _buildKetentuanContent(),
          ),
        ],
      ),
    );
  }

  // ── Accordion ─────────────────────────────────────────────────────────────

  Widget _buildAccordion({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget content,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(16),
              bottom: Radius.circular(isExpanded ? 0 : 16),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(235, 243, 255, 1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: _blue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: _textPrimary,
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: _textSecondary,
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: isExpanded ? 0 : 0.5,
                    child: const Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: _textSecondary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(
                height: 1,
                thickness: 1,
                color: Color.fromRGBO(240, 240, 240, 1)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              child: content,
            ),
          ],
        ],
      ),
    );
  }

  // ── Konten Operasional ────────────────────────────────────────────────────

  Widget _buildOperasionalContent() {
    return Column(
      children: [
        _infoCard(
          label: 'Link Layanan',
          child: GestureDetector(
            onTap: () async {
              final uri = Uri.parse(_hospitalUrl);
              if (await canLaunchUrl(uri)) launchUrl(uri);
            },
            child: Text(
              _hospitalUrl,
              style: const TextStyle(
                color: _blue,
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                decorationColor: _blue,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _infoCard(
          label: 'Alamat',
          child: Text(
            _alamat,
            style: const TextStyle(
              color: _textPrimary,
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 10),
        _infoCard(
          label: 'Jam Operasional',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _jamOperasional
                .map((jam) => _BulletItem(text: jam))
                .toList(),
          ),
        ),
        const SizedBox(height: 10),
        _infoCard(
          label: 'Telepon',
          child: GestureDetector(
            onTap: () async {
              final uri = Uri.parse('tel:$_teleponRaw');
              if (await canLaunchUrl(uri)) launchUrl(uri);
            },
            child: Text(
              _telepon,
              style: const TextStyle(
                color: _blue,
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                decorationColor: _blue,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _infoCard(
          label: 'Email',
          child: GestureDetector(
            onTap: () async {
              final uri = Uri.parse('mailto:$_email');
              if (await canLaunchUrl(uri)) launchUrl(uri);
            },
            child: Text(
              _email,
              style: const TextStyle(
                color: _blue,
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                decorationColor: _blue,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _infoCard(
          label: 'Media Sosial',
          child: Wrap(
            spacing: 10,
            runSpacing: 8,
            children: _socialMediaItems
                .map((item) => _socialButton(
                      icon: item.icon,
                      label: item.label,
                      onTap: () async {
                        final uri = Uri.parse(item.url);
                        if (await canLaunchUrl(uri)) launchUrl(uri);
                      },
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _socialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(235, 243, 255, 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _blue, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: _blue,
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Konten Ketentuan Layanan ──────────────────────────────────────────────

  Widget _buildKetentuanContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Manfaat',
          style: TextStyle(
            color: _textPrimary,
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _ketentuanIntro,
          style: const TextStyle(
            color: _textPrimary,
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 8),
        for (int i = 0; i < _manfaatList.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${i + 1}. ',
                  style: const TextStyle(
                    color: _textPrimary,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                  ),
                ),
                Expanded(
                  child: Text(
                    _manfaatList[i],
                    style: const TextStyle(
                      color: _textPrimary,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        const Text(
          'Sistem, Mekanisme, dan Prosedur',
          style: TextStyle(
            color: _textPrimary,
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _pendaftaranPoliTitle,
          style: const TextStyle(
            color: _textPrimary,
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        for (int i = 0; i < _pendaftaranPoliSteps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${i + 1}. ',
                  style: const TextStyle(
                    color: _textPrimary,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                  ),
                ),
                Expanded(
                  child: Text(
                    _pendaftaranPoliSteps[i],
                    style: const TextStyle(
                      color: _textPrimary,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Text(
          _pendaftaranBpjsTitle,
          style: const TextStyle(
            color: _textPrimary,
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        for (int i = 0; i < _pendaftaranBpjsSteps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${i + 1}. ',
                  style: const TextStyle(
                    color: _textPrimary,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                  ),
                ),
                Expanded(
                  child: Text(
                    _pendaftaranBpjsSteps[i],
                    style: const TextStyle(
                      color: _textPrimary,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _infoCard({required String label, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(248, 248, 245, 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _textPrimary,
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

// ── Social Media Item ─────────────────────────────────────────────────────────

class _SocialMediaItem {
  final IconData icon;
  final String label;
  final String url;
  const _SocialMediaItem(
      {required this.icon, required this.label, required this.url});
}

// ── Bullet Item ───────────────────────────────────────────────────────────────

class _BulletItem extends StatelessWidget {
  final String text;
  const _BulletItem({required this.text});

  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: CircleAvatar(
              radius: 3,
              backgroundColor: _textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: _textPrimary,
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
