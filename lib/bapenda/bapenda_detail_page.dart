import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BapendaDetailPage extends StatefulWidget {
  final String serviceTitle;

  const BapendaDetailPage({super.key, required this.serviceTitle});

  @override
  State<BapendaDetailPage> createState() => _BapendaDetailPageState();
}

class _BapendaDetailPageState extends State<BapendaDetailPage> {
  int _selectedTab = 1; // mulai di tab Informasi
  bool _operasionalExpanded = true;
  bool _ketentuanExpanded = true;

  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _whiteBg = Color.fromRGBO(248, 248, 245, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);

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
      title: const Text(
        'BAPENDA Jawa Timur',
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'PlusJakartaSans',
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bookmark_border_rounded,
              color: _blue,
              size: 20,
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
              color: Colors.black.withValues(alpha:0.06),
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

  // ── Tab Layanan (placeholder) ─────────────────────────────────────────────

  Widget _buildLayananTab() {
    return const Center(
      child: Text(
        'Pilih layanan dari halaman sebelumnya.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color.fromRGBO(120, 120, 120, 1),
          fontFamily: 'PlusJakartaSans',
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
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
            icon: Icons.support_agent_rounded,
            title: 'Operasional',
            isExpanded: _operasionalExpanded,
            onToggle: () =>
                setState(() => _operasionalExpanded = !_operasionalExpanded),
            child: _buildOperasionalContent(),
          ),
          const SizedBox(height: 12),
          _buildAccordion(
            icon: Icons.description_rounded,
            title: 'Ketentuan Umum',
            isExpanded: _ketentuanExpanded,
            onToggle: () =>
                setState(() => _ketentuanExpanded = !_ketentuanExpanded),
            child: _buildKetentuanContent(),
          ),
        ],
      ),
    );
  }

  // ── Accordion ─────────────────────────────────────────────────────────────

  Widget _buildAccordion({
    required IconData icon,
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Container(
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
          // Header
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
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(235, 243, 255, 1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: _blue, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
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
          // Konten
          if (isExpanded) ...[
            const Divider(
              height: 1,
              thickness: 1,
              color: Color.fromRGBO(240, 240, 240, 1),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              child: child,
            ),
          ],
        ],
      ),
    );
  }

  // ── Konten Operasional ────────────────────────────────────────────────────

  Widget _buildOperasionalContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          label: 'Link Layanan',
          child: GestureDetector(
            onTap: () async {
              final uri = Uri.parse('https://bapenda.jatimprov.go.id/');
              if (await canLaunchUrl(uri)) launchUrl(uri);
            },
            child: const Text(
              'https://bapenda.jatimprov.go.id/',
              style: TextStyle(
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
        const SizedBox(height: 14),
        _buildInfoRow(
          label: 'Alamat',
          child: const Text(
            'Jl. Manyar Kertoarjo No.1, Manyar Sabrangan, Kec. Mulyorejo, Surabaya, Jawa Timur 60116',
            style: TextStyle(
              color: _textPrimary,
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 14),
        _buildInfoRow(
          label: 'Jam Operasional',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _JamItem(hari: 'Senin', jam: '08:00 - 15:30'),
              _JamItem(hari: 'Selasa', jam: '08:00 - 15:30'),
              _JamItem(hari: 'Rabu', jam: '08:00 - 15:30'),
              _JamItem(hari: 'Kamis', jam: '08:00 - 15:30'),
              _JamItem(hari: 'Jumat', jam: '08:00 - 15:30'),
            ],
          ),
        ),
      ],
    );
  }

  // ── Konten Ketentuan Umum ─────────────────────────────────────────────────

  Widget _buildKetentuanContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          label: 'Manfaat',
          child: const Text(
            'Sebagai institusi yang berperan penting dalam pengelolaan Pendapatan Asli Daerah, BAPENDA berupaya meningkatkan transparansi, akuntabilitas, dan kualitas pelayanan keuangan di tingkat Provinsi dan Kabupaten/Kota di Jawa Timur.',
            style: TextStyle(
              color: _textPrimary,
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 14),
        _buildInfoRow(
          label: 'Pendaftaran Online',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cara cek informasi pajak dan nilai jual kendaraan:',
                style: TextStyle(
                  color: _textPrimary,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 6),
              ..._pendaftaranSteps.map((step) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_pendaftaranSteps.indexOf(step) + 1}. ',
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
                            step,
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
                  )),
              const SizedBox(height: 10),
              const Text(
                'Pembayaran Pajak Kendaraan Bermotor (PKB) tahunan bisa dilakukan di Kantor Bersama Samsat atau melalui E-Samsat. Aplikasi E-Samsat merupakan sistem pembayaran PKB, Sumbangan Wajib Dana Kecelakaan Lalu Lintas Jalan (SWDKLLJ), dan biaya administrasi.',
                style: TextStyle(
                  color: _textPrimary,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Tersedia juga melalui marketplace, e-wallet, Payment Point Online Bank (PPOB) seperti Indomaret, Alfamart, Alfamidi, Kantor Pos, Agen Badan Usaha Mitra Desa, Samsat Kampus, dan sebagainya.',
                style: TextStyle(
                  color: _textPrimary,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static const List<String> _pendaftaranSteps = [
    'Kunjungi laman resmi Bapenda Jatim.',
    'Cek info pajak kendaraan bermotor di menu Info Laju / Info PKB.',
    'Masukkan plat nomor kendaraan.',
    'Masukkan 5 digit terakhir nomor rangka.',
    'Untuk mengetahui info nilai jual kendaraan, klik info besaran PKB dan BBN di menu info, isi data yang diminta lalu klik submit.',
  ];

  // ── Helper ────────────────────────────────────────────────────────────────

  Widget _buildInfoRow({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _textSecondary,
            fontFamily: 'PlusJakartaSans',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

// ── Jam Item ──────────────────────────────────────────────────────────────────

class _JamItem extends StatelessWidget {
  final String hari;
  final String jam;

  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);

  const _JamItem({required this.hari, required this.jam});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              hari,
              style: const TextStyle(
                color: _textPrimary,
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                height: 1.6,
              ),
            ),
          ),
          const Text(
            '  ',
            style: TextStyle(color: _textSecondary),
          ),
          Text(
            '($jam)',
            style: const TextStyle(
              color: _textSecondary,
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
