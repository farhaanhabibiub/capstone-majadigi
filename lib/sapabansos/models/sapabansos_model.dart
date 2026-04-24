class PenerimaResult {
  final String nikSearch;
  final String namaSearch;
  final String nik;
  final String nama;
  final String kabupaten;
  final String kecamatan;
  final String kelurahan;
  final String program;

  PenerimaResult({
    required this.nikSearch,
    required this.namaSearch,
    required this.nik,
    required this.nama,
    required this.kabupaten,
    required this.kecamatan,
    required this.kelurahan,
    required this.program,
  });
}

class BansosProgram {
  final String iconPath;
  final String title;
  final String description;
  final String kategori;
  final String nilai;
  final int jumlahPenerima;
  final int jumlahTersalur;
  final double progressValue;

  int get jumlahBelumTersalur => jumlahPenerima - jumlahTersalur;
  String get progressText => '${(progressValue * 100).toStringAsFixed(1)}%';
  String get kuota => _formatAngka(jumlahPenerima);
  String get tersalur => _formatAngka(jumlahTersalur);
  String get belumTersalur => _formatAngka(jumlahBelumTersalur);

  const BansosProgram({
    required this.iconPath,
    required this.title,
    required this.description,
    required this.kategori,
    required this.nilai,
    required this.jumlahPenerima,
    required this.jumlahTersalur,
    required this.progressValue,
  });

  static String _formatAngka(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
