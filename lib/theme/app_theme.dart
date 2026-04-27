import 'package:flutter/material.dart';

/// Palette & gaya teks terpusat untuk seluruh aplikasi Majadigi.
///
/// Tujuan: hilangkan duplikasi `static const Color _blue = ...` yang tersebar
/// di puluhan file. Untuk rebranding cukup ubah nilai di sini.
///
/// Default app adalah light mode — varian dark hanya aktif jika user
/// mengaktifkannya dari halaman Pengaturan Aksesibilitas.
class AppTheme {
  AppTheme._();

  // ── Brand ──────────────────────────────────────────────────────────────
  static const Color primary = Color.fromRGBO(0, 101, 255, 1);
  static const Color primaryDark = Color(0xFF0062D1);

  // ── Surfaces (Light) ───────────────────────────────────────────────────
  static const Color background = Color.fromRGBO(248, 248, 245, 1);
  static const Color surface = Colors.white;

  // ── Text (Light) ───────────────────────────────────────────────────────
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

  // ── Dark variants ──────────────────────────────────────────────────────
  // Dipakai oleh helper context-aware di bawah. Light tetap default.
  static const Color _darkBackground = Color(0xFF121316);
  static const Color _darkSurface = Color(0xFF1C1E22);
  static const Color _darkSurfaceElevated = Color(0xFF24272D);
  static const Color _darkBorder = Color(0xFF2E3137);
  static const Color _darkTextPrimary = Color(0xFFEDEEF1);
  static const Color _darkTextSecondary = Color(0xFFA8ACB4);
  static const Color _darkTextMuted = Color(0xFF7C8088);

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // ── Helper warna context-aware ─────────────────────────────────────────
  // Pakai ini di widget agar otomatis mengikuti light/dark mode.
  static Color backgroundOf(BuildContext context) =>
      _isDark(context) ? _darkBackground : background;

  static Color surfaceOf(BuildContext context) =>
      _isDark(context) ? _darkSurface : surface;

  static Color surfaceElevatedOf(BuildContext context) =>
      _isDark(context) ? _darkSurfaceElevated : surface;

  static Color borderOf(BuildContext context) => _isDark(context)
      ? _darkBorder
      : const Color.fromRGBO(235, 235, 235, 1);

  static Color textPrimaryOf(BuildContext context) =>
      _isDark(context) ? _darkTextPrimary : textPrimary;

  static Color textSecondaryOf(BuildContext context) =>
      _isDark(context) ? _darkTextSecondary : textSecondary;

  static Color textMutedOf(BuildContext context) =>
      _isDark(context) ? _darkTextMuted : textMuted;

  // ── ThemeData factories ────────────────────────────────────────────────
  static ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ).copyWith(surface: surface),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: _darkBackground,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ).copyWith(
        surface: _darkSurface,
        onSurface: _darkTextPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkSurface,
        foregroundColor: _darkTextPrimary,
        elevation: 0,
      ),
      dividerColor: _darkBorder,
    );
  }
}
