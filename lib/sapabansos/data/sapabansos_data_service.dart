import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import '../models/sapabansos_model.dart';

class SapaBansosDataService {
  static List<PenerimaResult>? _cache;

  static Future<List<PenerimaResult>> loadPenerima() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/data/penerima_bansos.csv');
    final rows = Csv(fieldDelimiter: ',', lineDelimiter: '\n').decode(raw);
    _cache = rows.skip(1).where((r) => r.length >= 6).map((r) {
      final nik = r[0].toString().trim();
      final nama = r[1].toString().trim();
      return PenerimaResult(
        nikSearch: nik,
        namaSearch: nama.toLowerCase(),
        nik: _maskNik(nik),
        nama: _maskNama(nama),
        kabupaten: r[2].toString().trim(),
        kecamatan: r[3].toString().trim(),
        kelurahan: r[4].toString().trim(),
        program: r[5].toString().trim(),
      );
    }).toList();
    return _cache!;
  }

  static Future<PenerimaResult?> cariPenerima(String nik) async {
    final list = await loadPenerima();
    try {
      return list.firstWhere((p) => p.nikSearch == nik);
    } catch (_) {
      return null;
    }
  }

  static Future<List<PenerimaResult>> cariPenerimaByNama(
    String nama, {
    String? kabupaten,
  }) async {
    final list = await loadPenerima();
    final query = nama.trim().toLowerCase();
    if (query.isEmpty) return [];
    return list.where((p) {
      final matchNama = p.namaSearch.contains(query);
      final matchKab = kabupaten == null ||
          kabupaten == 'Semua' ||
          p.kabupaten == kabupaten;
      return matchNama && matchKab;
    }).take(20).toList();
  }

  static Future<List<String>> getKabupatenList() async {
    final list = await loadPenerima();
    final set = <String>{};
    for (final p in list) set.add(p.kabupaten);
    return ['Semua', ...set.toList()..sort()];
  }

  static String _maskNik(String nik) {
    if (nik.length < 8) return nik;
    return '${nik.substring(0, 4)}${'*' * (nik.length - 8)}${nik.substring(nik.length - 4)}';
  }

  static String _maskNama(String nama) {
    if (nama.isEmpty) return nama;
    final parts = nama.split(' ');
    return parts.map((p) {
      if (p.length <= 2) return p;
      return '${p[0]}${'*' * (p.length - 1)}';
    }).join(' ');
  }
}
