import 'package:flutter/material.dart';

// ── Model data hasil ───────────────────────────────────────────────────────────

class HasilNjkbData {
  final String model;
  final String merk;
  final String tipe;
  final String tahun;
  final int pkbPlatHitam;
  final int opsenPkbPlatHitam;
  final int pkbPlatMerah;
  final int opsenPkbPlatMerah;
  final int pkbPlatKuning;
  final int opsenPkbPlatKuning;
  final int pnbpBjnb;
  final int pnbpStnk;
  final int pnbpTnkb;

  const HasilNjkbData({
    required this.model,
    required this.merk,
    required this.tipe,
    required this.tahun,
    required this.pkbPlatHitam,
    required this.opsenPkbPlatHitam,
    required this.pkbPlatMerah,
    required this.opsenPkbPlatMerah,
    required this.pkbPlatKuning,
    required this.opsenPkbPlatKuning,
    required this.pnbpBjnb,
    required this.pnbpStnk,
    required this.pnbpTnkb,
  });

  String fmt(int v) {
    if (v == 0) return 'Rp 0';
    final s = v.toString();
    final buf = StringBuffer();
    int c = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (c > 0 && c % 3 == 0) buf.write('.');
      buf.write(s[i]);
      c++;
    }
    return 'Rp ${buf.toString().split('').reversed.join()}';
  }
}

// ── Page ───────────────────────────────────────────────────────────────────────

class HasilNjkbPage extends StatelessWidget {
  final HasilNjkbData data;

  const HasilNjkbPage({super.key, required this.data});

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
          'Informasi NJKB',
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
            // ── Header card ─────────────────────────────────────────────────
            _buildHeaderCard(),

            const SizedBox(height: 20),

            // ── Label ────────────────────────────────────────────────────────
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

            // ── Card 1: Identitas ────────────────────────────────────────────
            _buildCard(
              icon: Icons.directions_car_rounded,
              title: 'Identitas Kendaraan',
              child: _buildIdentitas(),
            ),

            const SizedBox(height: 12),

            // ── Card 2: PKB ──────────────────────────────────────────────────
            _buildCard(
              icon: Icons.receipt_long_rounded,
              title: 'Pajak Kendaraan (PKB)',
              child: _buildPkb(),
            ),

            const SizedBox(height: 20),

            // ── Tombol ───────────────────────────────────────────────────────
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

            const SizedBox(height: 20),

            // ── Card 3: PNBP ─────────────────────────────────────────────────
            _buildCard(
              icon: Icons.account_balance_rounded,
              title: 'Penerimaan Negara Bukan Pajak (PNBP)',
              child: _buildPnbp(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Widgets ────────────────────────────────────────────────────────────────

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
            child: const Icon(
                Icons.account_balance_wallet_rounded, color: _blue, size: 22),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cek Estimasi Jual Kendaraan',
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
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: _textPrimary,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
              height: 1, thickness: 1,
              color: Color.fromRGBO(240, 240, 240, 1)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildIdentitas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _identitasItem(label: 'MODEL', value: data.model.toUpperCase()),
            ),
            Expanded(
              child: _identitasItem(label: 'MERK', value: data.merk.toUpperCase()),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _identitasItem(label: 'TIPE', value: data.tipe.toUpperCase()),
        const SizedBox(height: 14),
        _identitasItem(label: 'TAHUN BUAT', value: data.tahun),
      ],
    );
  }

  Widget _identitasItem({required String label, required String value}) {
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
          style: const TextStyle(
            color: _textPrimary,
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildPkb() {
    final rows = [
      ('PKB Plat Hitam', data.fmt(data.pkbPlatHitam)),
      ('Opsen PKB Plat Hitam', data.fmt(data.opsenPkbPlatHitam)),
      ('PKB Plat Merah', data.fmt(data.pkbPlatMerah)),
      ('Opsen PKB Plat Merah', data.fmt(data.opsenPkbPlatMerah)),
      ('PKB Plat Kuning', data.fmt(data.pkbPlatKuning)),
      ('Opsen PKB Plat Kuning', data.fmt(data.opsenPkbPlatKuning)),
    ];
    return Column(
      children: [
        for (int i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _biayaRow(rows[i].$1, rows[i].$2),
        ],
      ],
    );
  }

  Widget _buildPnbp() {
    final rows = [
      ('PNBP BJNB', data.fmt(data.pnbpBjnb)),
      ('PNBP STNK', data.fmt(data.pnbpStnk)),
      ('PNBP TNKB', data.fmt(data.pnbpTnkb)),
    ];
    return Column(
      children: [
        for (int i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _biayaRow(rows[i].$1, rows[i].$2),
        ],
      ],
    );
  }

  Widget _biayaRow(String label, String value) {
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
