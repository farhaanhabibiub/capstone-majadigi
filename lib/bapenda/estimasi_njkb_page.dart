import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_route.dart';
import '../theme/app_theme.dart';
import 'hasil_njkb_page.dart';

// ── Model record database ──────────────────────────────────────────────────────

class _NjkbRecord {
  final String jenis;
  final String model;
  final String merk;
  final String tipe;
  final int tahun;
  final int njkb;

  const _NjkbRecord({
    required this.jenis,
    required this.model,
    required this.merk,
    required this.tipe,
    required this.tahun,
    required this.njkb,
  });

  factory _NjkbRecord.fromRow(List<dynamic> r) => _NjkbRecord(
        jenis: r[0].toString().trim(),
        model: r[1].toString().trim(),
        merk: r[2].toString().trim(),
        tipe: r[3].toString().trim(),
        tahun: int.tryParse(r[4].toString().trim()) ?? 0,
        njkb: int.tryParse(r[5].toString().trim()) ?? 0,
      );
}

// ── Page ───────────────────────────────────────────────────────────────────────

class EstimasiNjkbPage extends StatefulWidget {
  const EstimasiNjkbPage({super.key});

  @override
  State<EstimasiNjkbPage> createState() => _EstimasiNjkbPageState();
}

class _EstimasiNjkbPageState extends State<EstimasiNjkbPage> {

  // ── Database ────────────────────────────────────────────────────────────────
  List<_NjkbRecord> _db = [];
  bool _dbLoaded = false;

  // ── Pilihan user ────────────────────────────────────────────────────────────
  String? _selJenis;
  String? _selModel;
  String? _selMerk;
  String? _selTipe;
  String? _selTahun;

  // Dropdown terbuka (null = semua tutup)
  int? _open; // 0=jenis 1=model 2=merk 3=tipe 4=tahun

  // ── Opsi cascading dari DB ──────────────────────────────────────────────────
  List<String> get _jenisOpts => _db.map((r) => r.jenis).toSet().toList()..sort();

  List<String> get _modelOpts {
    if (_selJenis == null) return [];
    return _db.where((r) => r.jenis == _selJenis).map((r) => r.model).toSet().toList()..sort();
  }

  List<String> get _merkOpts {
    if (_selJenis == null || _selModel == null) return [];
    return _db
        .where((r) => r.jenis == _selJenis && r.model == _selModel)
        .map((r) => r.merk)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> get _tipeOpts {
    if (_selJenis == null || _selModel == null || _selMerk == null) return [];
    return _db
        .where((r) => r.jenis == _selJenis && r.model == _selModel && r.merk == _selMerk)
        .map((r) => r.tipe)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> get _tahunOpts {
    if (_selJenis == null || _selModel == null || _selMerk == null || _selTipe == null) return [];
    final years = _db
        .where((r) =>
            r.jenis == _selJenis &&
            r.model == _selModel &&
            r.merk == _selMerk &&
            r.tipe == _selTipe)
        .map((r) => r.tahun.toString())
        .toSet()
        .toList();
    years.sort((a, b) => b.compareTo(a));
    return years;
  }

  bool get _isFormFilled =>
      _selJenis != null &&
      _selModel != null &&
      _selMerk != null &&
      _selTipe != null &&
      _selTahun != null;

  // ── Init ─────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadDb();
  }

  Future<void> _loadDb() async {
    try {
      final raw = await rootBundle.loadString('assets/data/njkb_database.csv');
      final rows = Csv(fieldDelimiter: ',', lineDelimiter: '\n').decode(raw);
      final items = <_NjkbRecord>[];
      for (int i = 1; i < rows.length; i++) {
        if (rows[i].length >= 6) items.add(_NjkbRecord.fromRow(rows[i]));
      }
      if (mounted) setState(() { _db = items; _dbLoaded = true; });
    } catch (_) {
      if (mounted) setState(() => _dbLoaded = true);
    }
  }

  // ── Select helpers ───────────────────────────────────────────────────────────
  void _toggle(int idx) => setState(() => _open = (_open == idx) ? null : idx);

  void _pickJenis(String v) => setState(() {
        _selJenis = v; _selModel = null; _selMerk = null;
        _selTipe = null; _selTahun = null; _open = null;
      });

  void _pickModel(String v) => setState(() {
        _selModel = v; _selMerk = null; _selTipe = null; _selTahun = null; _open = null;
      });

  void _pickMerk(String v) => setState(() {
        _selMerk = v; _selTipe = null; _selTahun = null; _open = null;
      });

  void _pickTipe(String v) => setState(() { _selTipe = v; _selTahun = null; _open = null; });

  void _pickTahun(String v) => setState(() { _selTahun = v; _open = null; });

  // ── Cari data ────────────────────────────────────────────────────────────────
  void _handleCariData() {
    FocusScope.of(context).unfocus();
    final tahunInt = int.tryParse(_selTahun ?? '') ?? 0;
    _NjkbRecord? rec;
    for (final r in _db) {
      if (r.jenis == _selJenis &&
          r.model == _selModel &&
          r.merk == _selMerk &&
          r.tipe == _selTipe &&
          r.tahun == tahunInt) {
        rec = r; break;
      }
    }
    if (rec == null) return; // seharusnya tidak terjadi karena opsi dari DB

    final isMotor = _selJenis == 'Sepeda Motor';
    final njkb = rec.njkb;
    final hasil = HasilNjkbData(
      model: _selModel!,
      merk: _selMerk!,
      tipe: _selTipe!,
      tahun: _selTahun!,
      njkb: njkb,
      pkbPlatHitam: (njkb * 0.02).round(),
      opsenPkbPlatHitam: (njkb * 0.02 * 0.66).round(),
      pkbPlatMerah: (njkb * 0.005).round(),
      opsenPkbPlatMerah: (njkb * 0.005 * 0.66).round(),
      pkbPlatKuning: (njkb * 0.01).round(),
      opsenPkbPlatKuning: (njkb * 0.01 * 0.66).round(),
      pnbpBjnb: isMotor ? 75_000 : 375_000,
      pnbpStnk: isMotor ? 100_000 : 200_000,
      pnbpTnkb: isMotor ? 60_000 : 100_000,
    );
    Navigator.pushNamed(context, AppRoutes.hasilNjkbPage, arguments: hasil);
  }

  // ── Build ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _open = null),
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.primary,
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
        body: !_dbLoaded
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(),
                    const SizedBox(height: 24),

                    _buildLabel('Jenis Kendaraan'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      idx: 0, hint: 'Pilih Jenis Kendaraan',
                      selected: _selJenis, items: _jenisOpts,
                      onPick: _pickJenis,
                    ),
                    const SizedBox(height: 18),

                    _buildLabel('Model Kendaraan'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      idx: 1, hint: 'Pilih Model Kendaraan',
                      selected: _selModel, items: _modelOpts,
                      enabled: _selJenis != null,
                      onPick: _pickModel,
                    ),
                    const SizedBox(height: 18),

                    _buildLabel('Merk Kendaraan'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      idx: 2, hint: 'Pilih Merk Kendaraan',
                      selected: _selMerk, items: _merkOpts,
                      enabled: _selModel != null,
                      onPick: _pickMerk,
                    ),
                    const SizedBox(height: 18),

                    _buildLabel('Tipe Kendaraan'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      idx: 3, hint: 'Pilih Tipe Kendaraan',
                      selected: _selTipe, items: _tipeOpts,
                      enabled: _selMerk != null,
                      onPick: _pickTipe,
                    ),
                    const SizedBox(height: 18),

                    _buildLabel('Tahun Kendaraan'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      idx: 4, hint: 'Pilih Tahun Kendaraan',
                      selected: _selTahun, items: _tahunOpts,
                      enabled: _selTipe != null,
                      onPick: _pickTahun,
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isFormFilled ? _handleCariData : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          disabledBackgroundColor: const Color.fromRGBO(210, 210, 210, 1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999)),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Cari Data',
                          style: TextStyle(
                            color: Colors.white,
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
      ),
    );
  }

  // ── Widgets ───────────────────────────────────────────────────────────────────

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
            blurRadius: 8, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(235, 243, 255, 1), shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_balance_wallet_rounded, color: AppTheme.primary, size: 22),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cek Estimasi Jual Kendaraan',
                  style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'PlusJakartaSans',
                      fontSize: 14, fontWeight: FontWeight.w700)),
              SizedBox(height: 2),
              Text('BAPENDA Provinsi Jawa Timur',
                  style: TextStyle(color: AppTheme.textSecondary, fontFamily: 'PlusJakartaSans',
                      fontSize: 12, fontWeight: FontWeight.w400)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: const TextStyle(
          color: AppTheme.textPrimary, fontFamily: 'PlusJakartaSans',
          fontSize: 13, fontWeight: FontWeight.w600,
        ),
      );

  Widget _buildDropdown({
    required int idx,
    required String hint,
    required String? selected,
    required List<String> items,
    required void Function(String) onPick,
    bool enabled = true,
  }) {
    final isOpen = _open == idx;
    final hasVal = selected != null;
    final isDisabled = !enabled;

    final Color border = isDisabled
        ? const Color.fromRGBO(220, 220, 220, 1)
        : hasVal || isOpen
            ? AppTheme.primary
            : const Color.fromRGBO(225, 225, 225, 1);

    final Color labelColor = isDisabled
        ? const Color.fromRGBO(190, 190, 190, 1)
        : hasVal
            ? AppTheme.primary
            : const Color.fromRGBO(180, 180, 180, 1);

    final Color chevron = isDisabled
        ? const Color.fromRGBO(200, 200, 200, 1)
        : hasVal || isOpen
            ? AppTheme.primary
            : const Color.fromRGBO(160, 160, 160, 1);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isOpen ? 16 : 999),
        border: Border.all(color: border, width: 1.2),
        boxShadow: hasVal && !isOpen
            ? [BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.08),
                blurRadius: 6, offset: const Offset(0, 2))]
            : null,
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: isDisabled ? null : () { FocusScope.of(context).unfocus(); _toggle(idx); },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selected ?? hint,
                      style: TextStyle(
                        color: labelColor, fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: hasVal ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: isOpen ? 0.5 : 0,
                    child: Icon(Icons.keyboard_arrow_down_rounded, color: chevron, size: 22),
                  ),
                ],
              ),
            ),
          ),

          // List
          if (isOpen && items.isNotEmpty) ...[
            const Divider(height: 1, thickness: 1, color: Color.fromRGBO(230, 230, 230, 1)),
            for (int i = 0; i < items.length; i++) ...[
              InkWell(
                onTap: () => onPick(items[i]),
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(i == items.length - 1 ? 14 : 0)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          items[i],
                          style: TextStyle(
                            color: selected == items[i] ? AppTheme.primary : AppTheme.textPrimary,
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            fontWeight: selected == items[i] ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (selected == items[i])
                        const Icon(Icons.check_rounded, color: AppTheme.primary, size: 18),
                    ],
                  ),
                ),
              ),
              if (i < items.length - 1)
                const Divider(height: 1, thickness: 1, indent: 18, endIndent: 18,
                    color: Color.fromRGBO(240, 240, 240, 1)),
            ],
          ],
        ],
      ),
    );
  }
}
