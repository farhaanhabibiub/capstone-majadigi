import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../theme/app_theme.dart';
import '../transjatim/transjatim_ticket_service.dart';
import 'audit_log_service.dart';

class ScanTiketPage extends StatefulWidget {
  const ScanTiketPage({super.key});

  @override
  State<ScanTiketPage> createState() => _ScanTiketPageState();
}

class _ScanTiketPageState extends State<ScanTiketPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final MobileScannerController _scanner = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    formats: const [BarcodeFormat.qrCode],
  );
  final TextEditingController _manualCtrl = TextEditingController();

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _scanner.dispose();
    _manualCtrl.dispose();
    super.dispose();
  }

  // ── Scanning logic ────────────────────────────────────────────────────────

  /// Ambil orderId dari QR. QR tiket Majadigi di-encode JSON dengan field
  /// `id`. Untuk QR lain, coba parse seluruh string sebagai orderId mentah.
  String? _extractOrderId(String raw) {
    try {
      final obj = jsonDecode(raw);
      if (obj is Map && obj['id'] is String) {
        return obj['id'] as String;
      }
    } catch (_) {
      // Bukan JSON — coba mentah
    }
    final trimmed = raw.trim();
    if (trimmed.startsWith('TJ')) return trimmed;
    return null;
  }

  Future<void> _handleScan(String raw) async {
    if (_isProcessing) return;
    final orderId = _extractOrderId(raw);
    if (orderId == null) {
      _showSheet(_buildResultSheet(
        icon: Icons.error_outline_rounded,
        color: const Color(0xFFE11D48),
        title: 'QR tidak dikenali',
        message: 'QR ini bukan tiket Majadigi yang valid.',
      ));
      return;
    }
    await _verifyAndMark(orderId);
  }

  Future<void> _handleManualSubmit() async {
    final orderId = _manualCtrl.text.trim();
    if (orderId.isEmpty) return;
    FocusScope.of(context).unfocus();
    await _verifyAndMark(orderId);
  }

  Future<void> _verifyAndMark(String orderId) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    await _scanner.stop();
    try {
      final adminUid = FirebaseAuth.instance.currentUser?.uid ?? '-';
      final outcome = await TransjatimTicketService.markUsed(
        orderId: orderId,
        adminUid: adminUid,
      );

      switch (outcome.result) {
        case TicketScanResult.success:
          await AuditLogService.record(
            action: 'mark_ticket_used',
            targetType: 'transjatim_tickets',
            targetId: orderId,
            details: {
              'fromStop': outcome.data?['fromStop'],
              'toStop': outcome.data?['toStop'],
              'routeId': outcome.data?['routeId'],
            },
          );
          _showSheet(_buildSuccessSheet(orderId, outcome.data ?? const {}));
          break;
        case TicketScanResult.alreadyUsed:
          _showSheet(_buildAlreadyUsedSheet(orderId, outcome.data ?? const {}));
          break;
        case TicketScanResult.notFound:
          _showSheet(_buildResultSheet(
            icon: Icons.search_off_rounded,
            color: const Color(0xFFE11D48),
            title: 'Tiket tidak ditemukan',
            message:
                'ID $orderId tidak ada di sistem. Pastikan tiket dari pembayaran Majadigi terbaru.',
          ));
          break;
        case TicketScanResult.error:
          _showSheet(_buildResultSheet(
            icon: Icons.cloud_off_rounded,
            color: const Color(0xFFE11D48),
            title: 'Gagal verifikasi',
            message:
                'Periksa koneksi internet atau coba lagi.\n${outcome.error ?? ''}',
          ));
          break;
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSheet(Widget child) {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceOf(context),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(child: child),
    ).whenComplete(() {
      _manualCtrl.clear();
      // Resume kamera setelah sheet ditutup (kalau user di tab kamera).
      if (mounted && _tab.index == 0) {
        _scanner.start();
      }
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundOf(context),
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Scan Tiket Transjatim',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _scanner.toggleTorch(),
            icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
            tooltip: 'Senter',
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          onTap: (i) {
            if (i == 0) {
              _scanner.start();
            } else {
              _scanner.stop();
            }
          },
          tabs: const [
            Tab(icon: Icon(Icons.qr_code_scanner_rounded), text: 'Kamera'),
            Tab(icon: Icon(Icons.keyboard_rounded), text: 'Manual'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [_buildCameraTab(), _buildManualTab()],
      ),
    );
  }

  Widget _buildCameraTab() {
    return Stack(
      children: [
        MobileScanner(
          controller: _scanner,
          onDetect: (capture) {
            for (final code in capture.barcodes) {
              final raw = code.rawValue;
              if (raw == null) continue;
              _handleScan(raw);
              break;
            }
          },
          errorBuilder: (ctx, error, child) => _buildScannerError(error),
        ),
        // Overlay frame
        Center(
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 24,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Arahkan kamera ke QR tiket. Tiket akan otomatis diverifikasi & ditandai sudah digunakan.',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isProcessing)
          Container(
            color: Colors.black.withValues(alpha: 0.4),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildScannerError(MobileScannerException error) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.no_photography_rounded,
                color: Colors.white, size: 56),
            const SizedBox(height: 16),
            const Text(
              'Tidak dapat mengakses kamera',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pastikan izin kamera sudah diberikan.\n${error.errorDetails?.message ?? ''}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _tab.animateTo(1),
              icon: const Icon(Icons.keyboard_rounded, color: Colors.white),
              label: const Text(
                'Pakai input manual',
                style: TextStyle(color: Colors.white),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF5FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppTheme.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Masukkan ID Tiket yang tertera di bawah QR code (mis. TJ1714…).',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'ID Tiket',
            style: TextStyle(
              color: AppTheme.textPrimaryOf(context),
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _manualCtrl,
            textCapitalization: TextCapitalization.characters,
            onSubmitted: (_) => _handleManualSubmit(),
            decoration: InputDecoration(
              hintText: 'TJ1714123456789',
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              filled: true,
              fillColor: AppTheme.surfaceOf(context),
              prefixIcon: const Icon(Icons.confirmation_number_outlined),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.borderOf(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.borderOf(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppTheme.primary, width: 1.4),
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _handleManualSubmit,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.4,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline, color: Colors.white),
              label: Text(
                _isProcessing ? 'Memverifikasi…' : 'Verifikasi & Tandai Pakai',
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                disabledBackgroundColor:
                    AppTheme.primary.withValues(alpha: 0.6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Result sheets ─────────────────────────────────────────────────────────

  Widget _buildSuccessSheet(String orderId, Map<String, dynamic> d) {
    return _buildResultSheet(
      icon: Icons.check_circle_rounded,
      color: const Color(0xFF16A34A),
      title: 'Tiket Valid',
      message: 'Tiket berhasil ditandai sudah digunakan.',
      details: _formatTicketDetails(orderId, d),
    );
  }

  Widget _buildAlreadyUsedSheet(String orderId, Map<String, dynamic> d) {
    final usedAt = d['usedAt'];
    String? usedAtStr;
    if (usedAt is Map) {
      usedAtStr = null;
    } else if (usedAt != null) {
      usedAtStr = usedAt.toString();
    }
    return _buildResultSheet(
      icon: Icons.block_rounded,
      color: const Color(0xFFE11D48),
      title: 'Tiket Sudah Digunakan',
      message: usedAtStr != null
          ? 'Tiket ini telah ditandai pakai pada $usedAtStr.\nTidak dapat digunakan kembali.'
          : 'Tiket ini sudah pernah ditandai pakai.\nTidak dapat digunakan kembali.',
      details: _formatTicketDetails(orderId, d),
    );
  }

  Widget _buildResultSheet({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    String? details,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderOf(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 36),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              title,
              style: TextStyle(
                color: color,
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondaryOf(context),
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
          if (details != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.backgroundOf(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderOf(context)),
              ),
              child: Text(
                details,
                style: TextStyle(
                  color: AppTheme.textPrimaryOf(context),
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text(
                'Tutup',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTicketDetails(String orderId, Map<String, dynamic> d) {
    final route = d['routeId'] ?? '-';
    final from = d['fromStop'] ?? '-';
    final to = d['toStop'] ?? '-';
    final pax = d['passengerCount'] ?? '-';
    final cls = d['ticketClass'] ?? '-';
    return 'ID:    $orderId\n'
        'Rute:  $route\n'
        'Dari:  $from\n'
        'Ke:    $to\n'
        'Pax:   $pax orang\n'
        'Kelas: $cls';
  }
}
