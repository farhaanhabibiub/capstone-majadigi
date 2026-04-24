/// Hospital configuration model.
/// Each hospital has its own CSV data files but shares the same UI.
class HospitalConfig {
  final String id;
  final String name; // displayed in AppBar
  final String city; // display city label
  final String kamarCsv;
  final String jadwalCsv;
  final String antreanCsv;

  const HospitalConfig({
    required this.id,
    required this.name,
    required this.city,
    required this.kamarCsv,
    required this.jadwalCsv,
    required this.antreanCsv,
  });

  // ── Static hospital definitions ───────────────────────────────────────────

  static const dahaHusada = HospitalConfig(
    id: 'daha_husada',
    name: 'RSUD Daha Husada',
    city: 'Kediri',
    kamarCsv: 'assets/data/kamar_rsud.csv',
    jadwalCsv: 'assets/data/jadwal_operasi.csv',
    antreanCsv: 'assets/data/info_antrean.csv',
  );

  static const saifulAnwar = HospitalConfig(
    id: 'saiful_anwar',
    name: 'RSUD Saiful Anwar',
    city: 'Malang',
    kamarCsv: 'assets/data/kamar_saiful_anwar.csv',
    jadwalCsv: 'assets/data/jadwal_saiful_anwar.csv',
    antreanCsv: 'assets/data/antrean_saiful_anwar.csv',
  );

  static const karsaHusada = HospitalConfig(
    id: 'karsa_husada',
    name: 'RSUD Karsa Husada',
    city: 'Batu',
    kamarCsv: 'assets/data/kamar_karsa_husada.csv',
    jadwalCsv: 'assets/data/jadwal_karsa_husada.csv',
    antreanCsv: 'assets/data/antrean_karsa_husada.csv',
  );

  static const provJatim = HospitalConfig(
    id: 'prov_jatim',
    name: 'RSUD Prov. Jawa Timur',
    city: 'Surabaya',
    kamarCsv: 'assets/data/kamar_prov_jatim.csv',
    jadwalCsv: 'assets/data/jadwal_prov_jatim.csv',
    antreanCsv: 'assets/data/antrean_prov_jatim.csv',
  );

  // ── Location engineering ──────────────────────────────────────────────────
  /// Maps a user's city/regency (from personalization) to the nearest hospital.
  /// Rules:
  ///   Batu      → Karsa Husada   (checked first — Batu is near Malang)
  ///   Malang    → Saiful Anwar
  ///   Kediri    → Daha Husada
  ///   Surabaya  → Prov. Jawa Timur
  ///   default   → Daha Husada
  static HospitalConfig forLocation(String city, String regency) {
    final loc = '${city.toLowerCase()} ${regency.toLowerCase()}';

    if (loc.contains('batu')) return karsaHusada;
    if (loc.contains('malang')) return saifulAnwar;
    if (loc.contains('kediri')) return dahaHusada;
    if (loc.contains('surabaya')) return provJatim;

    // Extended East Java coverage — map nearby regions to nearest hospital
    if (loc.contains('blitar') || loc.contains('tulungagung') ||
        loc.contains('nganjuk') || loc.contains('jombang')) { return dahaHusada; }
    if (loc.contains('pasuruan') || loc.contains('probolinggo') ||
        loc.contains('lumajang')) { return saifulAnwar; }
    if (loc.contains('sidoarjo') || loc.contains('gresik') ||
        loc.contains('mojokerto') || loc.contains('lamongan')) { return provJatim; }

    return dahaHusada; // fallback
  }
}
