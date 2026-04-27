import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'admin/admin_page.dart';
import 'auth_service.dart';
import 'common/favorite_mixin.dart';
import 'klinikhoaks_landing_page.dart';
import 'klinikhoaks_lihatdetail.dart';
import 'widgets/empty_state.dart';
import 'widgets/skeleton_loader.dart';
import 'klinikhoaks_model.dart';
import 'notification_service.dart';
import 'theme/app_theme.dart';

class KlinikHoaksPermohonanPage extends StatefulWidget {
  final int initialTab;
  const KlinikHoaksPermohonanPage({super.key, this.initialTab = 0});

  @override
  State<KlinikHoaksPermohonanPage> createState() => _KlinikHoaksPermohonanPageState();
}

class _KlinikHoaksPermohonanPageState extends State<KlinikHoaksPermohonanPage>
    with FavoriteMixin {
  late int _selectedTab;
  List<LaporanHoaks> _laporanList = [];
  bool _isLoadingLaporan = true;
  bool _isAdmin = false;
  StreamSubscription<QuerySnapshot>? _statusStream;
  final Map<String, String> _knownStatuses = {};

  @override
  String get favoriteKey => 'fav_klinikhoaks';

  @override
  String get favoriteLabel => 'Klinik Hoaks';

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    _loadLaporan();
    _checkAdmin();
    _startStatusStream();
  }

  @override
  void dispose() {
    _statusStream?.cancel();
    super.dispose();
  }

  Future<void> _checkAdmin() async {
    final admin = await AuthService.instance.isAdmin();
    if (mounted) setState(() => _isAdmin = admin);
  }

  void _startStatusStream() {
    final uid = _uid;
    if (uid == null) return;
    _statusStream = FirebaseFirestore.instance
        .collection('laporan_hoaks')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .listen((snap) {
      for (final doc in snap.docs) {
        final laporan = LaporanHoaks.fromMap(doc.data(), docId: doc.id);
        final prev = _knownStatuses[laporan.tiketId];
        if (prev != null && prev != laporan.status) {
          NotificationService.showStatusUpdateNotification(
            tiketId: laporan.tiketId,
            newStatus: laporan.status,
          );
          // Update local list
          final idx = _laporanList.indexWhere((l) => l.tiketId == laporan.tiketId);
          if (idx != -1 && mounted) {
            setState(() => _laporanList[idx] = laporan);
          }
        }
        _knownStatuses[laporan.tiketId] = laporan.status;
      }
    });
  }

  Future<void> _refreshLaporan() async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final snap = await FirebaseFirestore.instance
          .collection('laporan_hoaks')
          .where('uid', isEqualTo: uid)
          .orderBy('createdAtMs', descending: true)
          .get();
      final list = snap.docs
          .map((d) => LaporanHoaks.fromMap(d.data(), docId: d.id))
          .toList();
      if (mounted) setState(() => _laporanList = list);
    } catch (_) {}
  }

  Future<void> _loadLaporan() async {
    final uid = _uid;
    if (uid == null) {
      setState(() => _isLoadingLaporan = false);
      return;
    }
    try {
      final snap = await FirebaseFirestore.instance
          .collection('laporan_hoaks')
          .where('uid', isEqualTo: uid)
          .orderBy('createdAtMs', descending: true)
          .get();
      final list = snap.docs
          .map((d) => LaporanHoaks.fromMap(d.data(), docId: d.id))
          .toList();
      for (final l in list) {
        _knownStatuses[l.tiketId] = l.status;
      }
      if (mounted) setState(() { _laporanList = list; _isLoadingLaporan = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoadingLaporan = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 320,
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
                          'Klinik Hoaks',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontFamily: 'PlusJakartaSans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isAdmin)
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const AdminPage()),
                                  ),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.admin_panel_settings, color: AppTheme.primary, size: 22),
                                  ),
                                ),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.bookmark_rounded
                                        : Icons.bookmark_border_rounded,
                                    color: AppTheme.primary,
                                    size: 22,
                                  ),
                                  onPressed: toggleFavorite,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildTabSwitcher(),
                        Expanded(child: _buildTabContent()),
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

  Widget _buildTabSwitcher() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            _buildTabItem('Layanan', 0),
            _buildTabItem('Tiket Saya', 1),
            _buildTabItem('Informasi', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF4B5563),
                fontWeight: FontWeight.w600,
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 1:
        return _buildTiketSayaTab();
      case 2:
        return _buildInformasiTab();
      default:
        return _buildLayananTab();
    }
  }

  // ── Tab 0: Layanan ────────────────────────────────────────────────────────────
  Widget _buildLayananTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Color(0xFFEBF5FF), shape: BoxShape.circle),
              child: const Icon(Icons.description, color: AppTheme.primary, size: 28),
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
              'Kirimkan detail informasi yang ingin diklarifikasi. Tim kami akan memverifikasi dalam 1×24 jam.',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'PlusJakartaSans',
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
                  side: const BorderSide(color: AppTheme.primary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                ),
                onPressed: () async {
                  final result = await Navigator.push<LaporanHoaks>(
                    context,
                    MaterialPageRoute(builder: (_) => const KlinikHoaksLandingPage()),
                  );
                  if (result != null && mounted) {
                    setState(() {
                      _laporanList.insert(0, result);
                      _selectedTab = 1;
                    });
                  }
                },
                child: const Text(
                  'Ajukan Laporan',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab 1: Tiket Saya ─────────────────────────────────────────────────────────
  Widget _buildTiketSayaTab() {
    if (_isLoadingLaporan) {
      return SkeletonLoader.list();
    }
    if (_laporanList.isEmpty) {
      return _buildEmptyTiket();
    }
    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: _refreshLaporan,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _laporanList.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (_, i) => _buildTicketCard(_laporanList[i]),
      ),
    );
  }

  Widget _buildEmptyTiket() {
    return EmptyState(
      icon: Icons.fact_check_outlined,
      title: 'Belum ada tiket laporan',
      subtitle:
          'Laporan hoaks yang Anda ajukan akan muncul di sini\nbeserta status verifikasinya.',
      actionLabel: 'Ajukan Laporan',
      onAction: () => setState(() => _selectedTab = 0),
    );
  }

  Widget _buildTicketCard(LaporanHoaks laporan) {
    final statusColor = laporan.status == 'Selesai'
        ? const Color(0xFF32D583)
        : laporan.status == 'Diverifikasi'
            ? AppTheme.primary
            : const Color(0xFFFDB022);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nomor Tiket',
                    style: TextStyle(fontSize: 11, fontFamily: 'PlusJakartaSans', color: Colors.grey),
                  ),
                  Text(
                    laporan.tiketId,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                child: Text(
                  laporan.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            laporan.topik,
            style: const TextStyle(
              fontSize: 15,
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            laporan.tanggal,
            style: const TextStyle(fontSize: 12, fontFamily: 'PlusJakartaSans', color: Colors.grey),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primary, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KlinikHoaksLihatDetail(laporan: laporan),
                  ),
                );
              },
              child: const Text(
                'Lihat Detail',
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 2: Informasi ──────────────────────────────────────────────────────────
  Widget _buildInformasiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _ExpandableCard(
            title: 'Operasional',
            subtitle: 'Jam layanan & kontak',
            icon: Icons.access_time_filled,
            child: _buildOperasionalContent(),
          ),
          const SizedBox(height: 16),
          _ExpandableCard(
            title: 'Ketentuan Umum',
            subtitle: 'Manfaat & prosedur penggunaan',
            icon: Icons.description,
            child: _buildKetentuanContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildOperasionalContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoSection(
          'Link Layanan',
          InkWell(
            onTap: () => _launchUrl('https://klinikhoaks.jatimprov.go.id/'),
            child: const Text(
              'klinikhoaks.jatimprov.go.id',
              style: TextStyle(
                color: AppTheme.primary,
                decoration: TextDecoration.underline,
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _infoSection(
          'Alamat',
          const Text(
            'Jl. Ahmad Yani No.242-244, Gayungan, Surabaya, Jawa Timur 60235',
            style: TextStyle(
              color: Color(0xFF4B5563),
              height: 1.5,
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _infoSection(
          'Jam Operasional',
          Column(
            children: [
              _dayRow('Senin – Kamis', '08:00 – 16:00', closed: false),
              _dayRow('Jumat', '08:00 – 11:00', closed: false),
              _dayRow('Sabtu – Minggu', 'Tutup', closed: true),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEBF5FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: AppTheme.primary, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pengajuan laporan dapat dilakukan kapan saja (24/7). Respons verifikasi mengikuti jam operasional di atas.',
                  style: TextStyle(
                    color: Color(0xFF1D4ED8),
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKetentuanContent() {
    return Column(
      children: [
        _ketentuanSection('Manfaat', [
          'Membantu masyarakat memverifikasi informasi yang meragukan agar terhindar dari hoaks.',
          'Melindungi publik dari dampak negatif informasi palsu yang menyesatkan.',
          'Meningkatkan kesadaran dan literasi digital masyarakat melalui klarifikasi informasi.',
          'Mendukung terciptanya ruang digital yang sehat dan bebas hoaks.',
          'Menyediakan akses transparan terhadap hasil verifikasi informasi.',
        ]),
        const SizedBox(height: 12),
        _ketentuanSection('Sistem, Mekanisme, dan Prosedur', [
          'Akses aplikasi MajaDigitalJatim dan pilih fitur Klinik Hoaks.',
          'Pilih tab "Layanan" lalu tekan "Ajukan Laporan".',
          'Isi formulir dengan topik, isi laporan, dan link bukti.',
          'Tekan "Ajukan" — tiket dibuat otomatis dan tercatat di sistem.',
          'Pantau status verifikasi di tab "Tiket Saya".',
        ]),
      ],
    );
  }

  Widget _infoSection(String title, Widget content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
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
              fontSize: 13,
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

  Widget _ketentuanSection(String title, List<String> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
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
              fontSize: 13,
              fontFamily: 'PlusJakartaSans',
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(
            items.length,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${i + 1}. ',
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'PlusJakartaSans',
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      items[i],
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'PlusJakartaSans',
                        color: Color(0xFF4B5563),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayRow(String day, String time, {required bool closed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 5, color: Color(0xFF1F2937)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              day,
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'PlusJakartaSans',
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'PlusJakartaSans',
              color: closed ? Colors.red.shade400 : const Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

class _ExpandableCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _ExpandableCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  State<_ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<_ExpandableCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => _expanded = !_expanded),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: Color(0xFFEBF5FF), shape: BoxShape.circle),
              child: Icon(widget.icon, color: const Color(0xFF007AFF), size: 22),
            ),
            title: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 15,
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            subtitle: Text(
              widget.subtitle,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'PlusJakartaSans',
                color: Colors.grey,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Color(0xFFEBF5FF), shape: BoxShape.circle),
              child: Icon(
                _expanded ? Icons.expand_less : Icons.expand_more,
                color: const Color(0xFF007AFF),
                size: 18,
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
              child: widget.child,
            ),
        ],
      ),
    );
  }
}
