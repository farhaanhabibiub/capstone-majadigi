import 'dart:math';

class LaporanHoaks {
  final String? docId;
  final String uid;
  final String namaUser;
  final String tiketId;
  final String topik;
  final String isiLaporan;
  final String linkBukti;
  final String namaFile;
  final String fileUrl;
  final String status;
  final String tanggal;
  final int createdAtMs;

  LaporanHoaks({
    this.docId,
    this.uid = '',
    this.namaUser = '',
    required this.tiketId,
    required this.topik,
    required this.isiLaporan,
    required this.linkBukti,
    this.namaFile = '',
    this.fileUrl = '',
    this.status = 'Diproses',
    required this.tanggal,
    int? createdAtMs,
  }) : createdAtMs = createdAtMs ?? DateTime.now().millisecondsSinceEpoch;

  static String generateTiketId() {
    final now = DateTime.now();
    final rand = (1000 + Random().nextInt(9000)).toString();
    final dd = now.day.toString().padLeft(2, '0');
    final mm = now.month.toString().padLeft(2, '0');
    return 'KH-${now.year}$mm$dd-$rand';
  }

  static String formatTanggal(DateTime dt) {
    const bulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${dt.day} ${bulan[dt.month]} ${dt.year}';
  }

  LaporanHoaks copyWith({String? status}) => LaporanHoaks(
        docId: docId,
        uid: uid,
        namaUser: namaUser,
        tiketId: tiketId,
        topik: topik,
        isiLaporan: isiLaporan,
        linkBukti: linkBukti,
        namaFile: namaFile,
        fileUrl: fileUrl,
        status: status ?? this.status,
        tanggal: tanggal,
        createdAtMs: createdAtMs,
      );

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'namaUser': namaUser,
        'tiketId': tiketId,
        'topik': topik,
        'isiLaporan': isiLaporan,
        'linkBukti': linkBukti,
        'namaFile': namaFile,
        'fileUrl': fileUrl,
        'status': status,
        'tanggal': tanggal,
        'createdAtMs': createdAtMs,
      };

  factory LaporanHoaks.fromMap(Map<String, dynamic> map, {String? docId}) =>
      LaporanHoaks(
        docId: docId,
        uid: map['uid'] ?? '',
        namaUser: map['namaUser'] ?? '',
        tiketId: map['tiketId'] ?? '',
        topik: map['topik'] ?? '',
        isiLaporan: map['isiLaporan'] ?? '',
        linkBukti: map['linkBukti'] ?? '',
        namaFile: map['namaFile'] ?? '',
        fileUrl: map['fileUrl'] ?? '',
        status: map['status'] ?? 'Diproses',
        tanggal: map['tanggal'] ?? '',
        createdAtMs: map['createdAtMs'] ?? 0,
      );
}
