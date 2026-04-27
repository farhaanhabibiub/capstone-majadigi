import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../app_route.dart';
import '../klinikhoaks_model.dart';
import '../widgets/empty_state.dart';
import '../widgets/skeleton_loader.dart';
import 'audit_log_service.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  static const _blue = Color(0xFF007AFF);

  List<LaporanHoaks> _list = [];
  bool _isLoading = true;
  String _filterStatus = 'Semua';

  static const _statuses = ['Semua', 'Diproses', 'Diverifikasi', 'Selesai'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('laporan_hoaks')
          .orderBy('createdAtMs', descending: true)
          .get();
      final list = snap.docs
          .map((d) => LaporanHoaks.fromMap(d.data(), docId: d.id))
          .toList();
      if (mounted) setState(() { _list = list; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('laporan_hoaks')
          .orderBy('createdAtMs', descending: true)
          .get();
      final list = snap.docs
          .map((d) => LaporanHoaks.fromMap(d.data(), docId: d.id))
          .toList();
      if (mounted) setState(() => _list = list);
    } catch (_) {}
  }

  List<LaporanHoaks> get _filtered =>
      _filterStatus == 'Semua' ? _list : _list.where((l) => l.status == _filterStatus).toList();

  Future<void> _updateStatus(LaporanHoaks laporan, String newStatus) async {
    if (laporan.docId == null) return;
    final previousStatus = laporan.status;
    try {
      await FirebaseFirestore.instance
          .collection('laporan_hoaks')
          .doc(laporan.docId)
          .update({'status': newStatus});
      await AuditLogService.record(
        action: AuditLogService.actionUpdateLaporanStatus,
        targetType: 'laporan_hoaks',
        targetId: laporan.docId!,
        details: {
          'from': previousStatus,
          'to': newStatus,
          'tiketId': laporan.tiketId,
          'topik': laporan.topik,
        },
      );
      final idx = _list.indexWhere((l) => l.docId == laporan.docId);
      if (idx != -1 && mounted) {
        setState(() => _list[idx] = laporan.copyWith(status: newStatus));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui status')),
        );
      }
    }
  }

  void _showDetailSheet(LaporanHoaks laporan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailSheet(
        laporan: laporan,
        onStatusChange: (newStatus) {
          Navigator.pop(context);
          _updateStatus(laporan, newStatus);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 220,
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
                          'Admin — Klinik Hoaks',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'PlusJakartaSans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Audit Log',
                                icon: const Icon(
                                  Icons.history_rounded,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.auditLogPage,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Kelola Notifikasi',
                                icon: const Icon(
                                  Icons.notifications_rounded,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.adminNotifikasiPage,
                                ),
                              ),
                            ],
                          ),
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
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildFilterRow(),
                        const SizedBox(height: 8),
                        Expanded(child: _buildBody()),
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

  Widget _buildFilterRow() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _statuses.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final s = _statuses[i];
          final selected = _filterStatus == s;
          return GestureDetector(
            onTap: () => setState(() => _filterStatus = s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? _blue : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: selected ? _blue : const Color(0xFFE0E0E0)),
              ),
              child: Text(
                s,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF4B5563),
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return SkeletonLoader.list(itemCount: 6);
    }
    final items = _filtered;
    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.inbox_outlined,
        title: 'Belum ada laporan',
        subtitle:
            'Laporan hoaks dari pengguna akan muncul di sini\nsetelah mereka mengajukan permohonan.',
        actionLabel: 'Muat Ulang',
        onAction: _refresh,
      );
    }
    return RefreshIndicator(
      color: _blue,
      onRefresh: _refresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _AdminCard(
          laporan: items[i],
          onTap: () => _showDetailSheet(items[i]),
        ),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final LaporanHoaks laporan;
  final VoidCallback onTap;

  const _AdminCard({required this.laporan, required this.onTap});

  static const _blue = Color(0xFF007AFF);

  Color get _statusColor {
    switch (laporan.status) {
      case 'Selesai':
        return const Color(0xFF32D583);
      case 'Diverifikasi':
        return _blue;
      default:
        return const Color(0xFFFDB022);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    laporan.tiketId,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'PlusJakartaSans',
                      color: Colors.grey,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    laporan.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              laporan.topik,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 13, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    laporan.namaUser.isEmpty ? '(Tanpa nama)' : laporan.namaUser,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'PlusJakartaSans',
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  laporan.tanggal,
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'PlusJakartaSans',
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSheet extends StatelessWidget {
  final LaporanHoaks laporan;
  final void Function(String) onStatusChange;

  const _DetailSheet({required this.laporan, required this.onStatusChange});

  static const _blue = Color(0xFF007AFF);
  static const _statuses = ['Diproses', 'Diverifikasi', 'Selesai'];

  Color _statusColor(String s) {
    switch (s) {
      case 'Selesai':
        return const Color(0xFF32D583);
      case 'Diverifikasi':
        return _blue;
      default:
        return const Color(0xFFFDB022);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'Detail Laporan',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(laporan.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
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
            ),
            const SizedBox(height: 4),
            const Divider(),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _row('Nomor Tiket', laporan.tiketId),
                  _row('Pengirim', laporan.namaUser.isEmpty ? '(Tanpa nama)' : laporan.namaUser),
                  _row('Tanggal', laporan.tanggal),
                  _row('Topik', laporan.topik),
                  _row('Isi Laporan', laporan.isiLaporan),
                  _row('Link Bukti', laporan.linkBukti),
                  if (laporan.namaFile.isNotEmpty) _row('File', laporan.namaFile),
                  const SizedBox(height: 20),
                  const Text(
                    'Ubah Status',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._statuses.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: s == laporan.status ? null : () => onStatusChange(s),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: s == laporan.status
                                ? Colors.grey.shade200
                                : _statusColor(s),
                            foregroundColor: s == laporan.status ? Colors.grey : Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            s == laporan.status ? '$s (Aktif)' : 'Tandai "$s"',
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontFamily: 'PlusJakartaSans',
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value.isEmpty ? '—' : value,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'PlusJakartaSans',
              color: Color(0xFF1F2937),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
