import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class DatasetDownloadService {
  DatasetDownloadService._();

  static Future<bool> downloadCsv({
    required BuildContext context,
    required String title,
    required List<String> headers,
    required List<List<String>> rows,
  }) async {
    try {
      final buf = StringBuffer()..writeln(headers.map(_escape).join(','));
      for (final row in rows) {
        buf.writeln(row.map(_escape).join(','));
      }
      final csvContent = buf.toString();
      final fileName = '${_slug(title)}.csv';

      // Android: simpan ke penyimpanan eksternal app (tidak perlu permission
      // di Android 10+) lalu buka share sheet agar user bisa memindahkan ke
      // folder manapun.
      if (Platform.isAndroid) {
        final savedPath = await _saveToExternalStorage(fileName, csvContent);
        if (savedPath != null) {
          if (!context.mounted) return false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF007AFF),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 4),
              content: Row(
                children: [
                  const Icon(Icons.download_done_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'File tersimpan: $fileName — pilih tujuan di bawah',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
          await Share.shareXFiles(
            [XFile(savedPath, mimeType: 'text/csv', name: fileName)],
            subject: 'Dataset Majadigi: $title',
          );
          return true;
        }
      }

      // iOS atau fallback Android: tulis ke temp lalu buka share sheet
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(csvContent);

      if (!context.mounted) return false;

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv', name: fileName)],
        subject: 'Dataset Majadigi: $title',
      );
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFE11D48),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Text(
              'Gagal mengunduh dataset. ${e.toString()}',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }
      return false;
    }
  }

  /// Simpan ke app-specific external storage (tidak perlu permission Android 10+).
  /// Return path file jika berhasil, null jika gagal.
  static Future<String?> _saveToExternalStorage(
      String fileName, String content) async {
    try {
      final extDir = await getExternalStorageDirectory();
      if (extDir != null) {
        final file = File('${extDir.path}/$fileName');
        await file.writeAsString(content);
        return file.path;
      }
    } catch (_) {}
    return null;
  }

  static String _escape(String cell) {
    if (cell.contains(',') || cell.contains('"') || cell.contains('\n')) {
      return '"${cell.replaceAll('"', '""')}"';
    }
    return cell;
  }

  static String _slug(String input) {
    final cleaned = input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    final trimmed = cleaned.length > 60 ? cleaned.substring(0, 60) : cleaned;
    return 'majadigi_$trimmed';
  }
}
