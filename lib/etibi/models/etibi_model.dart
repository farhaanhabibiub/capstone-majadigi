class RiwayatSkrining {
  final String? docId;
  final String tanggal;
  final String hasil;
  final String levelRisiko;
  final int skor;
  final int skorMax;
  final String faskes;
  final String kabupaten;
  final String noTelp;
  final int createdAtMs;

  RiwayatSkrining({
    this.docId,
    required this.tanggal,
    required this.hasil,
    required this.levelRisiko,
    required this.skor,
    required this.skorMax,
    required this.faskes,
    required this.kabupaten,
    required this.noTelp,
    int? createdAtMs,
  }) : createdAtMs = createdAtMs ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toMap() => {
        'tanggal': tanggal,
        'hasil': hasil,
        'levelRisiko': levelRisiko,
        'skor': skor,
        'skorMax': skorMax,
        'faskes': faskes,
        'kabupaten': kabupaten,
        'noTelp': noTelp,
        'createdAtMs': createdAtMs,
      };

  factory RiwayatSkrining.fromMap(Map<String, dynamic> map, {String? docId}) =>
      RiwayatSkrining(
        docId: docId,
        tanggal: map['tanggal'] ?? '',
        hasil: map['hasil'] ?? '',
        levelRisiko: map['levelRisiko'] ?? 'Rendah',
        skor: map['skor'] ?? 0,
        skorMax: map['skorMax'] ?? 46,
        faskes: map['faskes'] ?? '-',
        kabupaten: map['kabupaten'] ?? '-',
        noTelp: map['noTelp'] ?? '-',
        createdAtMs: map['createdAtMs'] ?? 0,
      );
}
