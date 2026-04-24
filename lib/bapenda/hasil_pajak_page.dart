import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class KendaraanData {
  final String platNomor;
  final String nomorRangka;
  final String warna;
  final String model;
  final String tipe;
  final String tahunDibuat;
  final String tanggalMasaPajak;
  final int pkb;
  final int pkbProgresif;
  final int opsenPkb;
  final int opsenPkbProgresif;
  final int swdkllj;
  final int parkirBerlangganan;
  final int pengesahanStnk;
  final int cetakStnk;
  final int cetakTnkb;

  const KendaraanData({
    required this.platNomor,
    required this.nomorRangka,
    required this.warna,
    required this.model,
    required this.tipe,
    required this.tahunDibuat,
    required this.tanggalMasaPajak,
    required this.pkb,
    required this.pkbProgresif,
    required this.opsenPkb,
    required this.opsenPkbProgresif,
    required this.swdkllj,
    required this.parkirBerlangganan,
    required this.pengesahanStnk,
    required this.cetakStnk,
    required this.cetakTnkb,
  });

  factory KendaraanData.fromCsvRow(List<dynamic> row) {
    int safeInt(dynamic v) => int.tryParse(v.toString().trim()) ?? 0;
    return KendaraanData(
      platNomor: row[0].toString().trim(),
      nomorRangka: row[1].toString().trim(),
      warna: row[2].toString().trim(),
      model: row[3].toString().trim(),
      tipe: row[4].toString().trim(),
      tahunDibuat: row[5].toString().trim(),
      tanggalMasaPajak: row[6].toString().trim(),
      pkb: safeInt(row[7]),
      pkbProgresif: safeInt(row[8]),
      opsenPkb: safeInt(row[9]),
      opsenPkbProgresif: safeInt(row[10]),
      swdkllj: safeInt(row[11]),
      parkirBerlangganan: safeInt(row[12]),
      pengesahanStnk: safeInt(row[13]),
      cetakStnk: safeInt(row[14]),
      cetakTnkb: safeInt(row[15]),
    );
  }

  static String _formatRupiah(int amount) {
    if (amount == 0) return 'Rp 0';
    final s = amount.toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write('.');
      buf.write(s[i]);
      count++;
    }
    return 'Rp ${buf.toString().split('').reversed.join()}';
  }

  String get pkbFormatted => _formatRupiah(pkb);
  String get pkbProgresifFormatted => _formatRupiah(pkbProgresif);
  String get opsenPkbFormatted => _formatRupiah(opsenPkb);
  String get opsenPkbProgresifFormatted => _formatRupiah(opsenPkbProgresif);
  String get swdkllj2Formatted => _formatRupiah(swdkllj);
  String get parkirFormatted => _formatRupiah(parkirBerlangganan);
  String get pengesahanFormatted => _formatRupiah(pengesahanStnk);
  String get cetakStnkFormatted => _formatRupiah(cetakStnk);
  String get cetakTnkbFormatted => _formatRupiah(cetakTnkb);

  int get totalTagihanTahunan =>
      pkb + pkbProgresif + opsenPkb + opsenPkbProgresif +
      swdkllj + parkirBerlangganan + pengesahanStnk;

  String get totalTagihanTahunanFormatted => _formatRupiah(totalTagihanTahunan);

  int get totalPengurusan5Tahunan => totalTagihanTahunan + cetakStnk + cetakTnkb;
  String get totalPengurusan5TahunanFormatted => _formatRupiah(totalPengurusan5Tahunan);

  // Parse tanggal masa pajak (coba format DD/MM/YYYY, DD-MM-YYYY, YYYY-MM-DD)
  DateTime? get parsedTanggalMasaPajak {
    final s = tanggalMasaPajak.trim();
    final bySlash = s.split('/');
    if (bySlash.length == 3) {
      final d = int.tryParse(bySlash[0]);
      final m = int.tryParse(bySlash[1]);
      final y = int.tryParse(bySlash[2]);
      if (d != null && m != null && y != null) return DateTime(y, m, d);
    }
    final byDash = s.split('-');
    if (byDash.length == 3) {
      if (byDash[0].length == 4) {
        final y = int.tryParse(byDash[0]);
        final m = int.tryParse(byDash[1]);
        final d = int.tryParse(byDash[2]);
        if (d != null && m != null && y != null) return DateTime(y, m, d);
      } else {
        final d = int.tryParse(byDash[0]);
        final m = int.tryParse(byDash[1]);
        final y = int.tryParse(byDash[2]);
        if (d != null && m != null && y != null) return DateTime(y, m, d);
      }
    }
    return null;
  }
}

// Status jatuh tempo
enum _StatusPajak { aman, segera, lewat, unknown }

class HasilPajakPage extends StatelessWidget {
  final KendaraanData data;

  const HasilPajakPage({super.key, required this.data});

  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _whiteBg = Color.fromRGBO(248, 248, 245, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);

  _StatusPajak get _statusPajak {
    final tgl = data.parsedTanggalMasaPajak;
    if (tgl == null) return _StatusPajak.unknown;
    final diff = tgl.difference(DateTime.now()).inDays;
    if (diff < 0) return _StatusPajak.lewat;
    if (diff <= 30) return _StatusPajak.segera;
    return _StatusPajak.aman;
  }

  Future<void> _launchESamsat() async {
    final uri = Uri.parse('https://www.bankjatim.co.id/id/layanan/e-channel/e-samsat-jatim');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _whiteBg,
      appBar: AppBar(
        backgroundColor: _blue,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Informasi PKB',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),

            // Status badge jatuh tempo
            _buildStatusBanner(),
            const SizedBox(height: 16),

            const Text(
              'HASIL PENCARIAN',
              style: TextStyle(
                color: _textSecondary,
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            _buildCard(
              icon: Icons.directions_car_rounded,
              title: 'Identitas Kendaraan',
              child: _buildIdentitasContent(),
            ),
            const SizedBox(height: 12),

            _buildCard(
              icon: Icons.account_balance_wallet_rounded,
              title: 'Biaya Pengurusan Tahunan',
              child: _buildBiayaContent(),
            ),
            const SizedBox(height: 12),

            _buildCard(
              icon: Icons.print_rounded,
              title: 'Biaya Pengurusan 5 Tahunan',
              child: _buildCetakContent(),
            ),
            const SizedBox(height: 24),

            // Tombol Bayar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _launchESamsat,
                icon: const Icon(Icons.payment_rounded, color: Colors.white, size: 20),
                label: const Text(
                  'Bayar via E-Samsat',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _blue, width: 1.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text(
                  'Cek Kendaraan Lain',
                  style: TextStyle(
                    color: _blue,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    final status = _statusPajak;
    Color bgColor;
    Color textColor;
    IconData icon;
    String label;

    switch (status) {
      case _StatusPajak.aman:
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        icon = Icons.check_circle_rounded;
        final tgl = data.parsedTanggalMasaPajak!;
        final sisa = tgl.difference(DateTime.now()).inDays;
        label = 'Pajak aktif · jatuh tempo ${data.tanggalMasaPajak} ($sisa hari lagi)';
        break;
      case _StatusPajak.segera:
        bgColor = const Color(0xFFFFF8E1);
        textColor = const Color(0xFFF57F17);
        icon = Icons.warning_amber_rounded;
        final tgl2 = data.parsedTanggalMasaPajak!;
        final sisa2 = tgl2.difference(DateTime.now()).inDays;
        label = 'Segera jatuh tempo ${data.tanggalMasaPajak} ($sisa2 hari lagi)';
        break;
      case _StatusPajak.lewat:
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        icon = Icons.error_rounded;
        label = 'Pajak sudah jatuh tempo sejak ${data.tanggalMasaPajak}';
        break;
      case _StatusPajak.unknown:
        bgColor = const Color(0xFFF5F5F5);
        textColor = _textSecondary;
        icon = Icons.info_outline_rounded;
        label = 'Masa pajak: ${data.tanggalMasaPajak}';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(235, 243, 255, 1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.directions_car_rounded, color: _blue, size: 22),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cek Pajak Kendaraan',
                style: TextStyle(
                  color: _textPrimary,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'BAPENDA Provinsi Jawa Timur',
                style: TextStyle(
                  color: _textSecondary,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required IconData icon, required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(235, 243, 255, 1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: _blue, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color.fromRGBO(240, 240, 240, 1)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildIdentitasContent() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _identitasItem(label: 'NOMOR POLISI', value: data.platNomor, bold: true)),
            Expanded(child: _identitasItem(label: 'WARNA', value: data.warna, bold: false)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _identitasItem(label: 'MODEL', value: data.model, bold: true)),
            Expanded(child: _identitasItem(label: 'TIPE', value: data.tipe, bold: false)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _identitasItem(label: 'TAHUN DIBUAT', value: data.tahunDibuat, bold: true)),
            Expanded(child: _identitasItem(label: 'MASA PAJAK', value: data.tanggalMasaPajak, bold: false)),
          ],
        ),
      ],
    );
  }

  Widget _identitasItem({required String label, required String value, required bool bold}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: _textSecondary, fontFamily: 'PlusJakartaSans', fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 14, fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
      ],
    );
  }

  Widget _buildBiayaContent() {
    final items = [
      ('PKB', data.pkbFormatted),
      if (data.pkbProgresif > 0) ('PKB Progresif', data.pkbProgresifFormatted),
      ('Opsen PKB', data.opsenPkbFormatted),
      if (data.opsenPkbProgresif > 0) ('Opsen PKB Progresif', data.opsenPkbProgresifFormatted),
      ('SWDKLLJ', data.swdkllj2Formatted),
      ('Parkir Berlangganan', data.parkirFormatted),
      ('Pengesahan STNK', data.pengesahanFormatted),
    ];

    return Column(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _biayaRow(items[i].$1, items[i].$2),
        ],
        const SizedBox(height: 12),
        const Divider(height: 1, thickness: 1, color: Color.fromRGBO(235, 235, 235, 1)),
        const SizedBox(height: 12),
        _totalRow('TOTAL TAGIHAN TAHUNAN', data.totalTagihanTahunanFormatted),
      ],
    );
  }

  Widget _buildCetakContent() {
    return Column(
      children: [
        _biayaRow('Cetak STNK', data.cetakStnkFormatted),
        const SizedBox(height: 10),
        _biayaRow('Cetak TNKB', data.cetakTnkbFormatted),
        const SizedBox(height: 12),
        const Divider(height: 1, thickness: 1, color: Color.fromRGBO(235, 235, 235, 1)),
        const SizedBox(height: 12),
        _totalRow('TOTAL (inkl. Cetak)', data.totalPengurusan5TahunanFormatted),
        const SizedBox(height: 8),
        Text(
          '* Total 5 tahunan sudah termasuk semua biaya tahunan + biaya cetak STNK dan TNKB',
          style: TextStyle(
            color: _textSecondary,
            fontFamily: 'PlusJakartaSans',
            fontSize: 11,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _biayaRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.w400)),
        Text(value, style: const TextStyle(color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _totalRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(235, 243, 255, 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: _blue, fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
          Text(value, style: const TextStyle(color: _blue, fontFamily: 'PlusJakartaSans', fontSize: 15, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
