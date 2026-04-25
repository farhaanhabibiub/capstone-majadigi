import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../common/favorite_mixin.dart';
import '../notification_service.dart';
import '../theme/app_theme.dart';
import 'widgets/skrining_tab.dart';
import 'widgets/riwayat_tab.dart';
import 'widgets/tentang_tab.dart';
import 'models/etibi_model.dart';

class EtibiPage extends StatefulWidget {
  const EtibiPage({super.key});

  @override
  State<EtibiPage> createState() => _EtibiPageState();
}

class _EtibiPageState extends State<EtibiPage> with FavoriteMixin {
  int _selectedTabIndex = 0;
  List<RiwayatSkrining> _riwayatList = [];
  bool _isLoadingRiwayat = true;
  DateTime? _reminderDate;

  @override
  String get favoriteKey => 'fav_etibi';

  @override
  String get favoriteLabel => 'E-TIBI';

  CollectionReference<Map<String, dynamic>>? get _riwayatCol {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('skrining_riwayat');
  }

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
    _loadReminderDate();
  }

  Future<void> _loadReminderDate() async {
    final date = await NotificationService.getReminderDate();
    if (mounted) setState(() => _reminderDate = date);
  }

  Future<void> _refreshRiwayat() async {
    final col = _riwayatCol;
    if (col == null) return;
    try {
      final snap = await col.orderBy('createdAtMs', descending: true).get();
      final list = snap.docs
          .map((d) => RiwayatSkrining.fromMap(d.data(), docId: d.id))
          .toList();
      if (mounted) setState(() => _riwayatList = list);
    } catch (_) {}
  }

  Future<void> _hapusRiwayat(RiwayatSkrining riwayat) async {
    setState(() => _riwayatList.removeWhere(
      (r) => r.createdAtMs == riwayat.createdAtMs,
    ));
    final col = _riwayatCol;
    if (col == null || riwayat.docId == null) return;
    try {
      await col.doc(riwayat.docId).delete();
    } catch (_) {
      _loadRiwayat();
    }
  }

  Future<void> _loadRiwayat() async {
    final col = _riwayatCol;
    if (col == null) {
      setState(() => _isLoadingRiwayat = false);
      return;
    }
    try {
      final snap = await col.orderBy('createdAtMs', descending: true).get();
      final list = snap.docs
          .map((d) => RiwayatSkrining.fromMap(d.data(), docId: d.id))
          .toList();
      if (mounted) setState(() { _riwayatList = list; _isLoadingRiwayat = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoadingRiwayat = false);
    }
  }

  Future<void> _tambahRiwayat(RiwayatSkrining riwayatBaru) async {
    // Optimistic update — tampil dulu di UI
    setState(() => _riwayatList.insert(0, riwayatBaru));

    final col = _riwayatCol;
    if (col == null) return;
    try {
      final docRef = await col.add(riwayatBaru.toMap());
      // Simpan docId ke item yang sudah ada di list
      final idx = _riwayatList.indexWhere((r) => r.docId == null && r.createdAtMs == riwayatBaru.createdAtMs);
      if (idx != -1 && mounted) {
        setState(() {
          _riwayatList[idx] = RiwayatSkrining.fromMap(riwayatBaru.toMap(), docId: docRef.id);
        });
      }
    } catch (_) {
      // Biarkan data tetap tampil di UI meskipun gagal simpan
    }
  }

  void _pindahKeRiwayat() {
    setState(() => _selectedTabIndex = 1);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _showReminderDialog();
    });
  }

  void _showReminderDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Color.fromRGBO(0, 101, 255, 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active_outlined,
                color: AppTheme.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Atur Pengingat Skrining',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color.fromRGBO(32, 32, 32, 1),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ingatkan saya untuk skrining TBC kembali dalam:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                color: Color.fromRGBO(120, 120, 120, 1),
                height: 1.5,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Column(
            children: [
              _reminderButton(ctx, '1 Minggu', 7),
              const SizedBox(height: 8),
              _reminderButton(ctx, '1 Bulan', 30),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Tidak perlu',
                  style: TextStyle(
                    color: Color.fromRGBO(120, 120, 120, 1),
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ],
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _reminderButton(BuildContext ctx, String label, int days) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          Navigator.pop(ctx);
          await NotificationService.scheduleEtibiReminder(daysLater: days);
          final date = await NotificationService.getReminderDate();
          if (mounted) {
            setState(() => _reminderDate = date);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Pengingat diatur $days hari lagi'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double headerHeight = kToolbarHeight + statusBarHeight + 36;

    return Scaffold(
      backgroundColor: AppTheme.primary,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'E-TIBI',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'PlusJakartaSans',
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 36,
            height: 36,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: IconButton(
              icon: Icon(
                isFavorite
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: AppTheme.primary,
                size: 20,
              ),
              onPressed: toggleFavorite,
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            height: headerHeight + 50,
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                image: DecorationImage(
                  image: AssetImage('assets/images/tekstur.png'),
                  fit: BoxFit.cover,
                  opacity: 0.15,
                ),
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(height: headerHeight),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildTabSwitcher(),
                      Expanded(child: _buildTabContent()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    if (_selectedTabIndex == 1) {
      if (_isLoadingRiwayat) {
        return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
      }
      return Column(
        children: [
          if (_reminderDate != null) _buildReminderBanner(),
          Expanded(
            child: _riwayatList.isEmpty
                ? _buildEmptyRiwayat()
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: RiwayatTab(
                      riwayatList: _riwayatList,
                      onRefresh: _refreshRiwayat,
                      onDelete: _hapusRiwayat,
                    ),
                  ),
          ),
        ],
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildCurrentTab(),
    );
  }

  Widget _buildReminderBanner() {
    final d = _reminderDate!;
    final formatted = '${d.day}/${d.month}/${d.year}';
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 101, 255, 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color.fromRGBO(0, 101, 255, 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active, color: AppTheme.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pengingat Aktif',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppTheme.primary,
                  ),
                ),
                Text(
                  'Skrining berikutnya: $formatted',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    color: Color.fromRGBO(0, 101, 255, 0.8),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              await NotificationService.cancelEtibiReminder();
              if (mounted) setState(() => _reminderDate = null);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pengingat dibatalkan'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Batalkan',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRiwayat() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Belum ada riwayat skrining',
            style: TextStyle(
              color: Color.fromRGBO(120, 120, 120, 1),
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Lakukan skrining pertama Anda\ndi tab Skrining',
            style: TextStyle(
              color: Color.fromRGBO(160, 160, 160, 1),
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => setState(() => _selectedTabIndex = 0),
            child: const Text(
              'Mulai Skrining',
              style: TextStyle(
                color: AppTheme.primary,
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
        child: Row(
          children: [
            _buildTabItem('Skrining', 0),
            _buildTabItem('Riwayat', 1),
            _buildTabItem('Tentang', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textPrimary,
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_selectedTabIndex) {
      case 0:
        return SkriningTab(onSubmit: _tambahRiwayat, onSelesai: _pindahKeRiwayat);
      case 2:
        return const TentangTab();
      default:
        return SkriningTab(onSubmit: _tambahRiwayat, onSelesai: _pindahKeRiwayat);
    }
  }
}
