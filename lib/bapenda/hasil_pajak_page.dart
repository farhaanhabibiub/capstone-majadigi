import 'package:flutter/material.dart';

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

  String _formatRupiah(int amount) {
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
}

class HasilPajakPage extends StatelessWidget {
  final KendaraanData data;

  const HasilPajakPage({super.key, required this.data});

  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _whiteBg = Color.fromRGBO(248, 248, 245, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);

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
            // ── Kartu Header ────────────────────────────────────────────────
            _buildHeaderCard(),

            const SizedBox(height: 20),

            // ── Label Hasil Pencarian ────────────────────────────────────────
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

            // ── Card Identitas Kendaraan ─────────────────────────────────────
            _buildCard(
              icon: Icons.directions_car_rounded,
              title: 'Identitas Kendaraan',
              child: _buildIdentitasContent(),
            ),

            const SizedBox(height: 12),

            // ── Card Biaya Penul Tahunan ─────────────────────────────────────
            _buildCard(
              icon: Icons.account_balance_wallet_rounded,
              title: 'Biaya Penul Tahunan',
              child: _buildBiayaContent(),
            ),

            const SizedBox(height: 20),

            // ── Tombol Cek Kendaraan Lain ────────────────────────────────────
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

            const SizedBox(height: 24),

            // ── Section Cetak ────────────────────────────────────────────────
            Container(
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  _buildBiayaRow('Cetak STNK', data.cetakStnkFormatted),
                  const SizedBox(height: 16),
                  _buildBiayaRow('Cetak TNKB', data.cetakTnkbFormatted),
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
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
            Expanded(child: _buildIdentitasItem(label: 'NOMOR POLISI', value: data.platNomor, valueBold: true)),
            Expanded(child: _buildIdentitasItem(label: 'WARNA', value: data.warna, valueBold: false)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _buildIdentitasItem(label: 'MODEL', value: data.model, valueBold: true)),
            Expanded(child: _buildIdentitasItem(label: 'TIPE', value: data.tipe, valueBold: false)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _buildIdentitasItem(label: 'TAHUN DIBUAT', value: data.tahunDibuat, valueBold: true)),
            Expanded(child: _buildIdentitasItem(label: 'TANGGAL MASA PAJAK', value: data.tanggalMasaPajak, valueBold: false)),
          ],
        ),
      ],
    );
  }

  Widget _buildIdentitasItem({
    required String label,
    required String value,
    required bool valueBold,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _textSecondary,
            fontFamily: 'PlusJakartaSans',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: _textPrimary,
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            fontWeight: valueBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBiayaContent() {
    final items = [
      ('PKB', data.pkbFormatted),
      ('PKB Progresif', data.pkbProgresifFormatted),
      ('Opsen PKB', data.opsenPkbFormatted),
      ('Opsen PKB Progresif', data.opsenPkbProgresifFormatted),
      ('SWDKLLJ', data.swdkllj2Formatted),
      ('Parkir Berlangganan', data.parkirFormatted),
      ('Pengesahan STNK', data.pengesahanFormatted),
    ];

    return Column(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _buildBiayaRow(items[i].$1, items[i].$2),
        ],
      ],
    );
  }

  Widget _buildBiayaRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _textPrimary,
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: _textPrimary,
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
