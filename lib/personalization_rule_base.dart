import 'rsud/hospital_config.dart';

/// Rule base untuk memilih 5 layanan unggulan beranda berdasarkan kategori
/// personalisasi yang dipilih user dan lokasi tinggalnya.
///
/// Output adalah daftar `featureId` (lihat [PersonalizationRuleBase.featureIds])
/// yang siap dipetakan ke `_ServiceItem` di beranda.
class PersonalizationRuleBase {
  /// 5 fitur default — dipakai bila user melewati personalisasi atau
  /// kategorinya tidak dikenal.
  static const List<String> defaultFeatures = [
    'bapenda',
    'rsud',
    'transjatim',
    'siskaperbapo',
    'nomor_darurat',
  ];

  /// Mapping kategori → 5 fitur paling relevan, terurut prioritas (rank 1..5).
  ///
  /// ID `rsud` di kategori `kesehatan` akan di-replace ke RSUD spesifik
  /// terdekat berdasarkan lokasi user (lihat [_resolveHospital]).
  static const Map<String, List<String>> _categoryFeatures = {
    'mobilitas': [
      'transjatim',
      'bapenda',
      'nomor_darurat',
      'open_data',
      'klinik_hoaks',
    ],
    'ekonomi': [
      'bapenda',
      'siskaperbapo',
      'sapa_bansos',
      'open_data',
      'klinik_hoaks',
    ],
    'pekerjaan': [
      'bapenda',
      'open_data',
      'sapa_bansos',
      'klinik_hoaks',
      'transjatim',
    ],
    'kesehatan': [
      'rsud',
      'etibi',
      'nomor_darurat',
      'sapa_bansos',
      'klinik_hoaks',
    ],
    'sosial': [
      'sapa_bansos',
      'klinik_hoaks',
      'open_data',
      'nomor_darurat',
      'etibi',
    ],
    'pemerintahan': [
      'bapenda',
      'open_data',
      'sapa_bansos',
      'siskaperbapo',
      'klinik_hoaks',
    ],
    'keamanan': [
      'nomor_darurat',
      'klinik_hoaks',
      'open_data',
      'etibi',
      'sapa_bansos',
    ],
  };

  /// Hitung 5 fitur untuk ditampilkan di beranda.
  ///
  /// - Bila [selectedCategoryIds] kosong → [defaultFeatures] (dengan RSUD
  ///   tetap di-resolve ke RS terdekat).
  /// - Multi-kategori: sistem skor posisi (rank 1=5 poin, 2=4 poin, … 5=1 poin),
  ///   diakumulasi antar kategori, lalu diambil top-5.
  /// - Tepat satu RSUD masuk daftar (yang terdekat) — duplikat antar kategori
  ///   di-deduplikasi otomatis lewat skor.
  static List<String> resolveFeatures({
    required List<String> selectedCategoryIds,
    required String city,
    required String regency,
  }) {
    if (selectedCategoryIds.isEmpty) {
      return _withHospital(defaultFeatures, city, regency);
    }

    final score = <String, int>{};
    for (final cat in selectedCategoryIds) {
      final list = _categoryFeatures[cat];
      if (list == null) continue;
      for (var i = 0; i < list.length; i++) {
        final id = list[i];
        score[id] = (score[id] ?? 0) + (5 - i);
      }
    }

    if (score.isEmpty) {
      return _withHospital(defaultFeatures, city, regency);
    }

    final ranked = score.entries.toList()
      ..sort((a, b) {
        final byScore = b.value.compareTo(a.value);
        if (byScore != 0) return byScore;
        return a.key.compareTo(b.key);
      });

    final picked = ranked.take(5).map((e) => e.key).toList();
    return _withHospital(picked, city, regency);
  }

  /// Replace ID generik `rsud` dengan RSUD terdekat berdasarkan lokasi.
  /// Jika `rsud` tidak ada di daftar, daftar dikembalikan apa adanya.
  static List<String> _withHospital(
    List<String> features,
    String city,
    String regency,
  ) {
    final idx = features.indexOf('rsud');
    if (idx < 0) return List<String>.from(features);
    final hospitalId = _resolveHospital(city, regency);
    return [
      for (var i = 0; i < features.length; i++)
        if (i == idx) hospitalId else features[i],
    ];
  }

  /// Mapping lokasi → ID RSUD spesifik di [ServiceRegistry] (`rsud_<config.id>`).
  static String _resolveHospital(String city, String regency) {
    final hospital = HospitalConfig.forLocation(city, regency);
    return 'rsud_${hospital.id}';
  }
}
