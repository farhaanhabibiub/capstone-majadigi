import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Helper untuk mengunduh dataset Open Data sebagai file CSV ke perangkat
/// pengguna. File ditulis ke direktori sementara aplikasi lalu dibuka melalui
/// system share sheet — pengguna dapat menyimpan ke folder Downloads, Drive,
/// mengirim ke email, dsb.
class DatasetDownloadService {
  DatasetDownloadService._();

  /// Tulis [headers] + [rows] sebagai CSV (delimiter koma, RFC 4180-friendly
  /// quoting), lalu tampilkan share sheet. Return true jika berhasil.
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

      final dir = await getTemporaryDirectory();
      final fileName = '${_slug(title)}.csv';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(buf.toString());

      if (!context.mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF007AFF),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Berhasil membuat $fileName',
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
        [XFile(file.path, mimeType: 'text/csv', name: fileName)],
        subject: 'Dataset Majadigi: $title',
        text: 'Dataset "$title" dari aplikasi Majadigi.',
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
