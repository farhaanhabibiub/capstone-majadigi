import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_route.dart';
import '../common/favorite_mixin.dart';
import '../theme/app_theme.dart';

class BapendaPage extends StatefulWidget {
  const BapendaPage({super.key});

  @override
  State<BapendaPage> createState() => _BapendaPageState();
}

class _BapendaPageState extends State<BapendaPage> with FavoriteMixin {
  int _selectedTab = 0;
  bool _operasionalExpanded = true;
  bool _ketentuanExpanded = true;

  @override
  String get favoriteKey => 'fav_bapenda';

  @override
  String get favoriteLabel => 'BAPENDA';

  static const List<String> _pendaftaranSteps = [
    'Kunjungi laman resmi Bapenda Jatim.',
    'Cek info pajak kendaraan bermotor di menu Info Laju / Info PKB.',
    'Masukkan plat nomor kendaraan.',
    'Masukkan 5 digit terakhir nomor rangka.',
    'Untuk mengetahui info nilai jual kendaraan, klik info besaran PKB dan BBN di menu info, isi data yang diminta lalu klik submit.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildTabBar(),
          const SizedBox(height: 16),
          Expanded(
            child: _selectedTab == 0 ? _buildLayananTab() : _buildInformasiTab(),
          ),
        ],
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primary,
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
          child: GestureDetector(
            onTap: toggleFavorite,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFavorite
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: AppTheme.primary,
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
            color: isActive ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : AppTheme.textSecondary,
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
            assetPath: 'assets/images/bapenda_pajak_kendaraan.png',
            fallbackIcon: Icons.directions_car_rounded,
            title: 'Info Pajak Kendaraan Bermotor',
            description:
                'Lihat informasi Pajak Kendaraan Bermotor dengan cepat dan mudah',
            buttonLabel: 'Cek Pajak',
            onButtonTap: () => Navigator.pushNamed(context, AppRoutes.infoPajakPage),
          ),
          const SizedBox(height: 14),
          _buildLayananCard(
            assetPath: 'assets/images/bapenda_nilai_jual.png',
            fallbackIcon: Icons.account_balance_wallet_rounded,
            title: 'Info Nilai Jual Kendaraan Bermotor',
            description:
                'Temukan Nilai Jual Kendaraan Bermotor terkini langsung dari sumber resmi',
            buttonLabel: 'Lihat Estimasi',
            onButtonTap: () => Navigator.pushNamed(context, AppRoutes.estimasiNjkbPage),
          ),
        ],
      ),
    );
  }

  Widget _buildLayananCard({
    required String assetPath,
    required IconData fallbackIcon,
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
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Icon(
                fallbackIcon,
                color: AppTheme.primary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
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
              color: AppTheme.textSecondary,
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
                side: const BorderSide(color: AppTheme.primary, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(
                  color: AppTheme.primary,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAccordion(
            icon: Icons.support_agent_rounded,
            title: 'Operasional',
            isExpanded: _operasionalExpanded,
            onToggle: () =>
                setState(() => _operasionalExpanded = !_operasionalExpanded),
            content: _buildOperasionalContent(),
          ),
          const SizedBox(height: 12),
          _buildAccordion(
            icon: Icons.description_rounded,
            title: 'Ketentuan Umum',
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
                    child: Icon(icon, color: AppTheme.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
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
                      color: Color.fromRGBO(120, 120, 120, 1),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow(
          label: 'Link Layanan',
          child: GestureDetector(
            onTap: () async {
              final uri = Uri.parse('https://bapenda.jatimprov.go.id/');
              if (await canLaunchUrl(uri)) launchUrl(uri);
            },
            child: const Text(
              'https://bapenda.jatimprov.go.id/',
              style: TextStyle(
                color: AppTheme.primary,
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                decorationColor: AppTheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _infoRow(
          label: 'Alamat',
          child: const Text(
            'Jl. Manyar Kertoarjo No.1, Manyar Sabrangan, Kec. Mulyorejo, Surabaya, Jawa Timur 60116',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 14),
        _infoRow(
          label: 'Jam Operasional',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _jamItem('Senin', '08:00 - 15:30'),
              _jamItem('Selasa', '08:00 - 15:30'),
              _jamItem('Rabu', '08:00 - 15:30'),
              _jamItem('Kamis', '08:00 - 15:30'),
              _jamItem('Jumat', '08:00 - 15:30'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _infoRow(
          label: 'Telepon',
          child: GestureDetector(
            onTap: () async {
              final uri = Uri.parse('tel:+6231593251');
              if (await canLaunchUrl(uri)) launchUrl(uri);
            },
            child: const Text(
              '(031) 593-251',
              style: TextStyle(
                color: AppTheme.primary,
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                decorationColor: AppTheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _infoRow(
          label: 'Email',
          child: GestureDetector(
            onTap: () async {
              final uri = Uri.parse('mailto:bapenda@jatimprov.go.id');
              if (await canLaunchUrl(uri)) launchUrl(uri);
            },
            child: const Text(
              'bapenda@jatimprov.go.id',
              style: TextStyle(
                color: AppTheme.primary,
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                decorationColor: AppTheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _jamItem(String hari, String jam) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              hari,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                height: 1.6,
              ),
            ),
          ),
          Text(
            '($jam)',
            style: const TextStyle(
              color: AppTheme.textSecondary,
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

  // ── Konten Ketentuan Umum ─────────────────────────────────────────────────

  Widget _buildKetentuanContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow(
          label: 'Manfaat',
          child: const Text(
            'Sebagai institusi yang berperan penting dalam pengelolaan Pendapatan Asli Daerah, BAPENDA berupaya meningkatkan transparansi, akuntabilitas, dan kualitas pelayanan keuangan di tingkat Provinsi dan Kabupaten/Kota di Jawa Timur.',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 14),
        _infoRow(
          label: 'Pendaftaran Online',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cara cek informasi pajak dan nilai jual kendaraan:',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 6),
              for (int i = 0; i < _pendaftaranSteps.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${i + 1}. ',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _pendaftaranSteps[i],
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
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
              const SizedBox(height: 10),
              const Text(
                'Pembayaran Pajak Kendaraan Bermotor (PKB) tahunan bisa dilakukan di Kantor Bersama Samsat atau melalui E-Samsat. Aplikasi E-Samsat merupakan sistem pembayaran PKB, Sumbangan Wajib Dana Kecelakaan Lalu Lintas Jalan (SWDKLLJ), dan biaya administrasi.',
                style: TextStyle(
                  color: AppTheme.textPrimary,
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
                  color: AppTheme.textPrimary,
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

  // ── Helper ────────────────────────────────────────────────────────────────

  Widget _infoRow({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
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
