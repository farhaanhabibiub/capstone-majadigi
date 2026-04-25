import 'package:flutter/material.dart';

/// Palette & gaya teks terpusat untuk seluruh aplikasi Majadigi.
///
/// Tujuan: hilangkan duplikasi `static const Color _blue = ...` yang tersebar
/// di puluhan file. Untuk rebranding cukup ubah nilai di sini.
class AppTheme {
  AppTheme._();

  // ── Brand ──────────────────────────────────────────────────────────────
  static const Color primary = Color.fromRGBO(0, 101, 255, 1);
  static const Color primaryDark = Color(0xFF0062D1);

  // ── Surfaces ───────────────────────────────────────────────────────────
  static const Color background = Color.fromRGBO(248, 248, 245, 1);
  static const Color surface = Colors.white;

  // ── Text ───────────────────────────────────────────────────────────────
  static const Color textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color textSecondary = Color.fromRGBO(120, 120, 120, 1);
  static const Color textMuted = Color.fromRGBO(140, 140, 140, 1);

  // ── Neutrals / Feedback ────────────────────────────────────────────────
  static const Color neutralDark = Color.fromRGBO(100, 100, 100, 1);
  static const Color success = Color(0xFF32D583);
  static const Color warning = Color(0xFFFDB022);
  static const Color danger = Color(0xFFF04438);

  // ── Typography ─────────────────────────────────────────────────────────
  static const String fontFamily = 'PlusJakartaSans';
}
