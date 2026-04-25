import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../app_route.dart';
import '../auth_service.dart';
import '../beranda/notifikasi_service.dart';
import '../theme/app_theme.dart';


class ProfilTab extends StatefulWidget {
  const ProfilTab({super.key});

  @override
  State<ProfilTab> createState() => _ProfilTabState();
}

class _ProfilTabState extends State<ProfilTab> {
  String _name = '';
  String _email = '';
  String _photoUrl = '';
  int _notifCount = 0;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadNotifCount();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final admin = await AuthService.instance.isAdmin();
    if (mounted) setState(() => _isAdmin = admin);
  }

  void _loadProfile() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _name = user.displayName?.isNotEmpty == true ? user.displayName! : 'Pengguna';
        _email = user.email ?? '';
        _photoUrl = user.photoURL ?? '';
      });
    }
  }

  Future<void> _loadNotifCount() async {
    final count = await NotifikasiService.getUnreadCount();
    if (mounted) setState(() => _notifCount = count);
  }

  // ── Ubah Profil ────────────────────────────────────────────────────────────

  void _goToUbahProfil() {
    Navigator.pushNamed(context, AppRoutes.ubahProfilPage).then((_) {
      // Refresh nama & foto setelah kembali
      _loadProfile();
    });
  }

  // ── Keamanan Akun ──────────────────────────────────────────────────────────

  void _showKeamananAkun() {
    Navigator.pushNamed(context, AppRoutes.keamananAkunPage);
  }

  // ── Syarat & Ketentuan / Kebijakan Privasi ─────────────────────────────────

  void _showInfoSheet(String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const Divider(height: 24),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  children: [
                    Text(content, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textSecondary, height: 1.7)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hapus Akun ─────────────────────────────────────────────────────────────

  void _hapusAkun() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Akun?',
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: const Text(
          'Akun dan semua data Anda akan dihapus secara permanen dari sistem kami. Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(fontFamily: AppTheme.fontFamily, color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) return;
              try {
                await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
                await user.delete();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.loginPage, (_) => false);
                }
              } on FirebaseAuthException catch (e) {
                if (!mounted) return;
                if (e.code == 'requires-recent-login') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Silakan login ulang terlebih dahulu sebelum menghapus akun.')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
            child: const Text('Hapus', style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Keluar ─────────────────────────────────────────────────────────────────

  void _keluar() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Keluar?',
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: const Text(
          'Anda akan keluar dari akun ini. Untuk menggunakan aplikasi kembali, Anda perlu login ulang.',
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(fontFamily: AppTheme.fontFamily, color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService.instance.signOut();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.loginPage, (_) => false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
            child: const Text('Keluar', style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text('Profil', style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 20),
          // Avatar
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color.fromRGBO(220, 232, 255, 1),
            backgroundImage: _photoUrl.isNotEmpty ? NetworkImage(_photoUrl) : null,
            child: _photoUrl.isEmpty
                ? Image.asset(
                    'assets/images/avatar_placeholder.png',
                    width: 80, height: 80,
                    errorBuilder: (_, __, ___) => const Icon(Icons.person_rounded, color: AppTheme.primary, size: 40),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(_name.isEmpty ? '...' : _name, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text(_email, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              children: [
                // ── Akun ──────────────────────────────────────────────────
                _sectionLabel('Akun'),
                const SizedBox(height: 8),
                _menuGroup([
                  _menuItem(icon: Icons.person_outline_rounded, label: 'Ubah Profil', onTap: _goToUbahProfil),
                  _menuItem(icon: Icons.shield_outlined, label: 'Keamanan Akun', onTap: _showKeamananAkun),
                  _menuItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifikasi',
                    badge: _notifCount > 0 ? _notifCount : null,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.notifikasiPage)
                        .then((_) => _loadNotifCount()),
                  ),
                ]),


                // ── Panel Admin (hanya terlihat jika admin) ────────────────
                if (_isAdmin) ...[
                  const SizedBox(height: 20),
                  _sectionLabel('Administrasi'),
                  const SizedBox(height: 8),
                  _menuGroup([
                    _menuItem(
                      icon: Icons.admin_panel_settings_outlined,
                      label: 'Panel Admin',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.adminPage),
                    ),
                  ]),
                ],

                const SizedBox(height: 20),

                // ── Bantuan & Informasi ────────────────────────────────────
                _sectionLabel('Bantuan & Informasi'),
                const SizedBox(height: 8),
                _menuGroup([
                  _menuItem(
                    icon: Icons.description_outlined,
                    label: 'Syarat & Ketentuan',
                    onTap: () => _showInfoSheet(
                      'Syarat & Ketentuan',
                      'Terakhir diperbarui: April 2026\n\n'

                      '1. PENERIMAAN KETENTUAN\n'
                      'Dengan mengunduh, mendaftar, atau menggunakan aplikasi Majadigi, Anda menyatakan telah membaca, memahami, dan menyetujui seluruh Syarat & Ketentuan ini. Jika Anda tidak menyetujui ketentuan ini, harap hentikan penggunaan aplikasi.\n\n'

                      '2. TENTANG MAJADIGI\n'
                      'Majadigi adalah aplikasi layanan publik digital Provinsi Jawa Timur yang mengintegrasikan berbagai layanan pemerintahan, meliputi: informasi Pajak Kendaraan Bermotor (BAPENDA), layanan rumah sakit daerah (RSUD), transportasi umum (Transjatim), pemantauan harga bahan pokok (SISKAPERBAPO), layanan tuberkulosis (E-TIBI), pengecekan bantuan sosial (SAPA BANSOS), pelaporan berita hoaks (Klinik Hoaks), dan data publik Jawa Timur.\n\n'

                      '3. PERSYARATAN PENGGUNA\n'
                      'Pengguna wajib berusia minimal 17 tahun atau mendapat persetujuan orang tua/wali. Pengguna wajib memberikan informasi yang akurat, lengkap, dan terkini saat pendaftaran. Setiap akun hanya boleh digunakan oleh satu individu dan tidak dapat dipindahtangankan.\n\n'

                      '4. KEWAJIBAN PENGGUNA\n'
                      'Pengguna bertanggung jawab menjaga kerahasiaan akun dan kata sandi. Pengguna wajib segera melapor jika mengetahui adanya akses tidak sah pada akunnya. Pengguna bertanggung jawab atas seluruh aktivitas yang dilakukan melalui akunnya.\n\n'

                      '5. LARANGAN PENGGUNAAN\n'
                      'Pengguna dilarang: (a) menggunakan aplikasi untuk tujuan ilegal atau melanggar hukum yang berlaku di Indonesia; (b) menyebarkan informasi palsu, menyesatkan, atau konten yang bersifat SARA; (c) mencoba meretas, merusak, atau mengganggu sistem aplikasi; (d) menggunakan aplikasi untuk kepentingan komersial tanpa izin tertulis; (e) melakukan scraping atau pengambilan data secara masif.\n\n'

                      '6. INFORMASI LAYANAN\n'
                      'Data yang tersedia pada fitur BAPENDA, RSUD, SISKAPERBAPO, dan layanan lainnya bersifat informatif. Majadigi tidak bertanggung jawab atas keputusan yang diambil berdasarkan informasi dalam aplikasi. Untuk kepastian hukum, pengguna disarankan menghubungi instansi terkait secara langsung.\n\n'

                      '7. KEKAYAAN INTELEKTUAL\n'
                      'Seluruh konten dalam aplikasi Majadigi, termasuk logo, desain, teks, dan antarmuka, merupakan milik Pemerintah Provinsi Jawa Timur dan dilindungi oleh hukum kekayaan intelektual yang berlaku. Pengguna tidak diperkenankan menyalin, mendistribusikan, atau memodifikasi konten tanpa izin.\n\n'

                      '8. BATASAN TANGGUNG JAWAB\n'
                      'Majadigi disediakan "sebagaimana adanya" tanpa jaminan ketersediaan layanan 24 jam penuh. Kami tidak bertanggung jawab atas kerugian yang timbul akibat gangguan layanan, kesalahan data, atau ketidaktersediaan fitur tertentu.\n\n'

                      '9. PERUBAHAN KETENTUAN\n'
                      'Kami berhak memperbarui Syarat & Ketentuan ini sewaktu-waktu. Perubahan akan diberitahukan melalui notifikasi aplikasi atau email terdaftar. Penggunaan aplikasi setelah perubahan diterbitkan dianggap sebagai penerimaan ketentuan baru.\n\n'

                      '10. HUKUM YANG BERLAKU\n'
                      'Syarat & Ketentuan ini tunduk pada hukum Negara Kesatuan Republik Indonesia. Segala perselisihan diselesaikan melalui musyawarah mufakat, dan apabila tidak tercapai, melalui pengadilan yang berwenang di Surabaya, Jawa Timur.',
                    ),
                  ),
                  _menuItem(
                    icon: Icons.privacy_tip_outlined,
                    label: 'Kebijakan Privasi',
                    onTap: () => _showInfoSheet(
                      'Kebijakan Privasi',
                      'Terakhir diperbarui: April 2026\n\n'

                      'Majadigi berkomitmen melindungi privasi dan keamanan data pribadi seluruh penggunanya. Kebijakan Privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, menyimpan, dan melindungi data Anda.\n\n'

                      '1. DATA YANG KAMI KUMPULKAN\n'
                      'Saat menggunakan Majadigi, kami mengumpulkan:\n'
                      '• Data Identitas: nama lengkap, alamat email, nomor telepon\n'
                      '• Data Lokasi: kota dan kabupaten domisili (untuk personalisasi layanan)\n'
                      '• Data Perangkat: token FCM untuk pengiriman notifikasi\n'
                      '• Data Preferensi: layanan yang disimpan dan dipersonalisasi\n'
                      '• Data Aktivitas: laporan yang dikirim melalui fitur Klinik Hoaks\n\n'

                      '2. CARA PENGGUNAAN DATA\n'
                      'Data yang dikumpulkan digunakan untuk:\n'
                      '• Menyediakan dan meningkatkan layanan Majadigi\n'
                      '• Mempersonalisasi tampilan layanan berdasarkan lokasi domisili\n'
                      '• Mengirimkan notifikasi layanan dan pembaruan informasi\n'
                      '• Memproses laporan hoaks dan memberikan respons kepada pelapor\n'
                      '• Menjaga keamanan dan mencegah penyalahgunaan akun\n\n'

                      '3. PENYIMPANAN DAN KEAMANAN DATA\n'
                      'Data Anda disimpan menggunakan layanan Firebase (Google Cloud) yang memenuhi standar keamanan internasional ISO 27001. Kata sandi disimpan dalam bentuk terenkripsi (hash) dan tidak dapat dibaca oleh siapapun, termasuk tim pengembang. Akses ke data dibatasi hanya untuk personel yang berwenang.\n\n'

                      '4. BERBAGI DATA DENGAN PIHAK KETIGA\n'
                      'Kami tidak menjual, menyewakan, atau memperdagangkan data pribadi Anda. Data dapat dibagikan hanya kepada:\n'
                      '• Instansi pemerintah Provinsi Jawa Timur yang terkait dengan layanan yang Anda gunakan\n'
                      '• Penyedia layanan teknis (Firebase/Google) sebatas yang diperlukan untuk operasional aplikasi\n'
                      '• Pihak berwenang apabila diwajibkan oleh hukum yang berlaku\n\n'

                      '5. HAK PENGGUNA\n'
                      'Anda memiliki hak untuk:\n'
                      '• Mengakses data pribadi yang kami simpan\n'
                      '• Memperbarui atau mengoreksi data yang tidak akurat\n'
                      '• Menghapus akun dan data pribadi Anda\n'
                      '• Menarik persetujuan pemberian data kapan saja\n'
                      'Hak-hak ini dapat dijalankan melalui menu Profil > Ubah Profil atau Profil > Hapus Akun.\n\n'

                      '6. NOTIFIKASI PUSH\n'
                      'Majadigi menggunakan Firebase Cloud Messaging (FCM) untuk mengirim notifikasi layanan. Anda dapat menonaktifkan notifikasi melalui pengaturan perangkat Anda kapan saja.\n\n'

                      '7. RETENSI DATA\n'
                      'Data Anda disimpan selama akun aktif digunakan. Apabila akun dihapus, data akan dihapus secara permanen dari sistem kami dalam waktu 30 hari, kecuali ada kewajiban hukum untuk menyimpannya lebih lama.\n\n'

                      '8. PERUBAHAN KEBIJAKAN\n'
                      'Kebijakan Privasi ini dapat diperbarui sewaktu-waktu. Kami akan memberitahukan perubahan signifikan melalui notifikasi aplikasi atau email terdaftar.\n\n'

                      '9. HUBUNGI KAMI\n'
                      'Jika Anda memiliki pertanyaan mengenai Kebijakan Privasi ini, silakan hubungi kami melalui:\n'
                      'Email: majadigi@jatimprov.go.id\n'
                      'Alamat: Kantor Gubernur Jawa Timur, Jl. Pahlawan No. 110, Surabaya 60174',
                    ),
                  ),
                ]),

                const SizedBox(height: 20),

                // ── Hapus Akun ─────────────────────────────────────────────
                _dangerCard(),

                const SizedBox(height: 16),

                // ── Keluar ─────────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _keluar,
                    icon: const Icon(Icons.logout_rounded, size: 18, color: AppTheme.primary),
                    label: const Text('Keluar', style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.primary)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
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

  // ── Komponen UI ────────────────────────────────────────────────────────────

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _menuGroup(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, thickness: 1, indent: 56, color: Color.fromRGBO(240, 240, 240, 1)),
            items[i],
          ],
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    int? badge,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            _iconBox(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
            ),
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: AppTheme.danger, borderRadius: BorderRadius.circular(99)),
                child: Text('$badge', style: const TextStyle(color: Colors.white, fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 6),
            ],
            const Icon(Icons.chevron_right_rounded, size: 20, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _dangerCard() {
    return GestureDetector(
      onTap: _hapusAkun,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: const Color.fromRGBO(254, 242, 242, 1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.delete_outline_rounded, color: AppTheme.danger, size: 18),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Hapus Akun', style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.danger)),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: AppTheme.danger),
          ],
        ),
      ),
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(235, 243, 255, 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: AppTheme.primary, size: 18),
    );
  }
}
