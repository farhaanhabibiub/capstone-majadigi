import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ErrorRetry extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String retryLabel;
  final VoidCallback onRetry;
  final IconData icon;
  final EdgeInsetsGeometry padding;

  const ErrorRetry({
    super.key,
    this.title = 'Gagal memuat data',
    this.subtitle,
    this.retryLabel = 'Coba Lagi',
    required this.onRetry,
    this.icon = Icons.cloud_off_rounded,
    this.padding = const EdgeInsets.all(24),
  });

  static String fromException(Object error) {
    final s = error.toString().toLowerCase();
    if (s.contains('socket') || s.contains('network') || s.contains('unreachable')) {
      return 'Tidak ada koneksi internet. Periksa jaringan Anda.';
    }
    if (s.contains('permission-denied') || s.contains('permission_denied')) {
      return 'Akses ditolak. Pastikan aturan keamanan benar.';
    }
    if (s.contains('timeout') || s.contains('deadline')) {
      return 'Permintaan terlalu lama. Coba lagi.';
    }
    if (s.contains('unavailable')) {
      return 'Layanan sedang tidak tersedia. Coba lagi sebentar.';
    }
    return 'Terjadi kesalahan saat memuat data.';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(254, 242, 242, 1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.danger, size: 36),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontFamily: AppTheme.fontFamily,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                retryLabel,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
