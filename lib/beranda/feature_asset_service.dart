import 'dart:async';
import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Mengelola aset modular tiap fitur addable. Saat user mengaktifkan fitur,
/// service ini mencoba men-download manifest aset dari Firebase Storage di
/// path `feature_manifests/<featureId>.json`. Jika tersedia, aset di-prefetch
/// ke cache lokal; jika tidak, fallback ke aset bundled di APK/IPA dan
/// progres tetap dijalankan secara halus agar UX konsisten.
///
/// Manifest format yang diharapkan:
/// ```json
/// {
///   "version": "1.0",
///   "feature": "sapa_bansos",
///   "assets": [
///     { "key": "hero", "url": "https://...", "size": 123456 }
///   ]
/// }
/// ```
class FeatureAssetService {
  FeatureAssetService._();

  static final FeatureAssetService instance = FeatureAssetService._();

  static const String _kPrefetchedPrefix = 'feature_prefetched.';
  static const String _kManifestPrefix = 'feature_manifest.';
  static const Duration _minDuration = Duration(milliseconds: 1800);
  static const Duration _maxDuration = Duration(seconds: 6);

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<bool> isPrefetched(String featureId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_kPrefetchedPrefix$featureId') ?? false;
  }

  /// Prefetch manifest + aset untuk satu fitur. [onProgress] dipanggil
  /// dengan nilai 0.0 → 1.0. Tidak pernah throw — kegagalan jaringan
  /// otomatis fallback ke simulate progress + aset bundled.
  Future<FeaturePrefetchResult> prefetch(
    String featureId, {
    ValueChanged<double>? onProgress,
  }) async {
    final start = DateTime.now();
    onProgress?.call(0.0);

    final manifest = await _fetchManifest(featureId);

    if (manifest != null) {
      await _downloadAssets(
        manifest,
        onProgress: onProgress,
      );
      await _saveManifest(featureId, manifest);
    } else {
      await _simulateProgress(onProgress: onProgress);
    }

    final elapsed = DateTime.now().difference(start);
    if (elapsed < _minDuration) {
      await Future<void>.delayed(_minDuration - elapsed);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_kPrefetchedPrefix$featureId', true);
    onProgress?.call(1.0);

    return FeaturePrefetchResult(
      featureId: featureId,
      usedRemoteManifest: manifest != null,
    );
  }

  Future<Map<String, String>> getCachedAssetUrls(String featureId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_kManifestPrefix$featureId');
    if (raw == null) return const {};
    try {
      final manifest = jsonDecode(raw) as Map<String, dynamic>;
      final assets = manifest['assets'] as List<dynamic>? ?? const [];
      return {
        for (final a in assets)
          if (a is Map<String, dynamic> &&
              a['key'] is String &&
              a['url'] is String)
            a['key'] as String: a['url'] as String,
      };
    } catch (_) {
      return const {};
    }
  }

  /// Hapus flag prefetch dan manifest tersimpan untuk satu fitur.
  /// Dipanggil saat user menghapus fitur dari Beranda.
  Future<void> invalidate(String featureId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_kPrefetchedPrefix$featureId');
    await prefs.remove('$_kManifestPrefix$featureId');
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs
        .getKeys()
        .where((k) =>
            k.startsWith(_kPrefetchedPrefix) ||
            k.startsWith(_kManifestPrefix))
        .toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
  }

  // ── internal ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> _fetchManifest(String featureId) async {
    try {
      final ref = _storage.ref('feature_manifests/$featureId.json');
      final bytes = await ref
          .getData(512 * 1024)
          .timeout(const Duration(seconds: 6));
      if (bytes == null) return null;
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _downloadAssets(
    Map<String, dynamic> manifest, {
    ValueChanged<double>? onProgress,
  }) async {
    final assets = (manifest['assets'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    if (assets.isEmpty) {
      await _simulateProgress(onProgress: onProgress);
      return;
    }

    final hardDeadline = DateTime.now().add(_maxDuration);
    for (var i = 0; i < assets.length; i++) {
      if (DateTime.now().isAfter(hardDeadline)) break;
      final url = assets[i]['url'] as String?;
      if (url != null) {
        try {
          await http
              .get(Uri.parse(url))
              .timeout(const Duration(seconds: 4));
        } catch (_) {
          // Lewati aset yang gagal — fitur tetap pakai bundled fallback.
        }
      }
      onProgress?.call((i + 1) / assets.length * 0.95);
    }
  }

  Future<void> _saveManifest(
    String featureId,
    Map<String, dynamic> manifest,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        '$_kManifestPrefix$featureId',
        jsonEncode(manifest),
      );
    } catch (_) {}
  }

  Future<void> _simulateProgress({ValueChanged<double>? onProgress}) async {
    const ticks = 24;
    for (var i = 1; i <= ticks; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 70));
      onProgress?.call(i / ticks * 0.95);
    }
  }
}

class FeaturePrefetchResult {
  final String featureId;
  final bool usedRemoteManifest;
  const FeaturePrefetchResult({
    required this.featureId,
    required this.usedRemoteManifest,
  });
}
