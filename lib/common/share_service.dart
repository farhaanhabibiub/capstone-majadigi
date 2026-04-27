import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// Share helper untuk Majadigi.
///
/// Pakai Share.share() (share_plus) yang membuka system share sheet —
/// otomatis menampilkan WhatsApp, Telegram, SMS, email, dll. yang
/// terpasang di perangkat pengguna.
class ShareService {
  ShareService._();

  static const String _appUrl =
      'https://play.google.com/store/apps/details?id=com.majadigi.app';

  /// Bagikan layanan ke aplikasi lain.
  ///
  /// [origin] adalah `RenderObject` widget pemicu — opsional, untuk iPad
  /// agar share sheet muncul di posisi yang benar.
  static Future<void> shareLayanan({
    required String label,
    required String description,
    BuildContext? context,
  }) {
    final text = 'Coba layanan *$label* di Majadigi 🇮🇩\n\n'
        '$description\n\n'
        'Akses berbagai layanan publik Provinsi Jawa Timur dalam satu '
        'aplikasi. Unduh sekarang: $_appUrl';

    Rect? sharePositionOrigin;
    if (context != null) {
      final box = context.findRenderObject() as RenderBox?;
      if (box != null) {
        sharePositionOrigin = box.localToGlobal(Offset.zero) & box.size;
      }
    }

    return Share.share(
      text,
      subject: 'Layanan $label - Majadigi',
      sharePositionOrigin: sharePositionOrigin,
    );
  }
}
