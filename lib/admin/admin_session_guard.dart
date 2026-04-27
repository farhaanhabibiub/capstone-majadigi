import 'dart:async';

import 'package:flutter/material.dart';
import '../app_route.dart';
import '../auth_service.dart';
import '../theme/app_theme.dart';

/// Bungkus halaman admin agar otomatis logout setelah idle tertentu.
///
/// Setiap pointer event (tap, scroll, drag) akan reset timer. Bila tidak
/// ada interaksi dalam [timeout], user akan ditendang ke halaman login.
/// Reasoning: panel admin punya akses tulis (update status laporan, hapus
/// notifikasi) — meninggalkan layar terbuka di perangkat tanpa pengawasan
/// adalah risiko nyata.
class AdminSessionGuard extends StatefulWidget {
  final Widget child;
  final Duration timeout;

  const AdminSessionGuard({
    super.key,
    required this.child,
    this.timeout = const Duration(minutes: 5),
  });

  @override
  State<AdminSessionGuard> createState() => _AdminSessionGuardState();
}

class _AdminSessionGuardState extends State<AdminSessionGuard> {
  Timer? _idleTimer;
  bool _expired = false;

  @override
  void initState() {
    super.initState();
    _restart();
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }

  void _restart() {
    _idleTimer?.cancel();
    _idleTimer = Timer(widget.timeout, _onTimeout);
  }

  Future<void> _onTimeout() async {
    if (_expired || !mounted) return;
    _expired = true;

    // Tampilkan dialog informasi sebelum logout
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.lock_clock_rounded,
            color: AppTheme.danger, size: 36),
        title: const Text(
          'Sesi Berakhir',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        content: Text(
          'Sesi admin berakhir setelah ${widget.timeout.inMinutes} menit tanpa aktivitas. Silakan login ulang untuk melanjutkan.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 13,
            color: AppTheme.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (!mounted) return;
    await AuthService.instance.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.loginPage,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _restart(),
      onPointerMove: (_) => _restart(),
      onPointerSignal: (_) => _restart(),
      child: widget.child,
    );
  }
}
