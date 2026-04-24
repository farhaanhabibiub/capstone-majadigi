import 'package:flutter/material.dart';
import '../data/sapabansos_data_service.dart';
import '../models/sapabansos_model.dart';

class PenerimaTab extends StatefulWidget {
  const PenerimaTab({super.key});

  @override
  State<PenerimaTab> createState() => _PenerimaTabState();
}

class _PenerimaTabState extends State<PenerimaTab> {
  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);

  bool _searchByNama = false;
  int _searchStatus = 0; // 0: initial, 1: found, 2: not found, 3: loading
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();

  PenerimaResult? _resultNik;
  List<PenerimaResult> _resultNamaList = [];

  List<String> _kabupatenList = ['Semua'];
  String _selectedKabupaten = 'Semua';
  bool _kabupatenLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadKabupaten();
  }

  Future<void> _loadKabupaten() async {
    final list = await SapaBansosDataService.getKabupatenList();
    if (mounted) setState(() { _kabupatenList = list; _kabupatenLoaded = true; });
  }

  @override
  void dispose() {
    _nikController.dispose();
    _namaController.dispose();
    super.dispose();
  }

  Future<void> _searchData() async {
    FocusScope.of(context).unfocus();
    setState(() => _searchStatus = 3);

    try {
      if (_searchByNama) {
        final nama = _namaController.text.trim();
        if (nama.isEmpty) { setState(() => _searchStatus = 0); return; }
        final results = await SapaBansosDataService.cariPenerimaByNama(
          nama,
          kabupaten: _selectedKabupaten,
        );
        if (!mounted) return;
        setState(() {
          _resultNamaList = results;
          _searchStatus = results.isNotEmpty ? 1 : 2;
        });
      } else {
        final nik = _nikController.text.trim();
        if (nik.isEmpty) { setState(() => _searchStatus = 0); return; }
        final found = await SapaBansosDataService.cariPenerima(nik);
        if (!mounted) return;
        setState(() {
          _resultNik = found;
          _searchStatus = found != null ? 1 : 2;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _searchStatus = 2);
    }
  }

  void _switchMode(bool byNama) {
    if (_searchByNama == byNama) return;
    setState(() {
      _searchByNama = byNama;
      _searchStatus = 0;
      _resultNik = null;
      _resultNamaList = [];
      _nikController.clear();
      _namaController.clear();
      _selectedKabupaten = 'Semua';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Cari Data Penerima Bansos',
            style: TextStyle(
              color: _textPrimary,
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Cari berdasarkan NIK atau Nama untuk mengetahui\nstatus penerimaan bansos',
            style: TextStyle(
              color: _textSecondary,
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // ── Mode toggle ─────────────────────────────────────────────────────
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                _modeChip('🔢  NIK', !_searchByNama, () => _switchMode(false)),
                _modeChip('👤  Nama', _searchByNama, () => _switchMode(true)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Search field ────────────────────────────────────────────────────
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _blue, width: 1.5),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _searchByNama
                ? TextField(
                    controller: _namaController,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(
                      color: _blue,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Masukkan nama penerima',
                      hintStyle: TextStyle(
                        color: Color(0xFFBDBDBD),
                        fontFamily: 'PlusJakartaSans',
                      ),
                    ),
                  )
                : TextField(
                    controller: _nikController,
                    keyboardType: TextInputType.number,
                    maxLength: 16,
                    style: const TextStyle(
                      color: _blue,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Masukkan NIK (16 digit)',
                      hintStyle: TextStyle(
                        color: Color(0xFFBDBDBD),
                        fontFamily: 'PlusJakartaSans',
                      ),
                      counterText: '',
                    ),
                  ),
          ),

          // ── Kabupaten dropdown (only for nama search) ───────────────────────
          if (_searchByNama && _kabupatenLoaded) ...[
            const SizedBox(height: 12),
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedKabupaten,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: _blue),
                  style: const TextStyle(
                    color: _textPrimary,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                  ),
                  items: _kabupatenList
                      .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedKabupaten = v ?? 'Semua'),
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // ── Search button ───────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _searchStatus == 3 ? null : _searchData,
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              icon: _searchStatus == 3
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.search, color: Colors.white, size: 18),
              label: Text(
                _searchStatus == 3 ? 'Mencari...' : 'Cari Data',
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // ── Results ─────────────────────────────────────────────────────────
          if (_searchStatus == 1 || _searchStatus == 2) ...[
            const SizedBox(height: 24),
            if (_searchStatus == 2)
              _buildNotFound()
            else if (_searchByNama)
              _buildNamaResults()
            else
              _buildNikResult(),
          ],
        ],
      ),
    );
  }

  Widget _modeChip(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: selected ? _blue : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : _textSecondary,
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotFound() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
      ),
      width: double.infinity,
      child: Row(
        children: const [
          Icon(Icons.error_outline, color: Color(0xFFE52B44), size: 20),
          SizedBox(width: 8),
          Text(
            'Data tidak ditemukan',
            style: TextStyle(
              color: _textPrimary,
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNikResult() {
    final r = _resultNik!;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HASIL PENCARIAN',
            style: TextStyle(
              color: Color.fromRGBO(50, 50, 50, 1),
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _infoRow('NIK', r.nik),
          _infoRow('Nama', r.nama),
          _infoRow('Kabupaten', r.kabupaten),
          _infoRow('Kecamatan', r.kecamatan),
          _infoRow('Kelurahan', r.kelurahan),
          _infoRow('Program', r.program),
        ],
      ),
    );
  }

  Widget _buildNamaResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'HASIL PENCARIAN',
              style: TextStyle(
                color: Color.fromRGBO(50, 50, 50, 1),
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${_resultNamaList.length} data ditemukan',
              style: const TextStyle(
                color: _textSecondary,
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...List.generate(_resultNamaList.length, (i) {
          final r = _resultNamaList[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        r.nama,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(0, 101, 255, 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        r.program,
                        style: const TextStyle(
                          color: _blue,
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 12, color: _textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${r.kecamatan}, ${r.kabupaten}',
                      style: const TextStyle(
                        color: _textSecondary,
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                color: _textPrimary,
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
              ),
            ),
          ),
          const Text(
            ' : ',
            style: TextStyle(
              color: _textPrimary,
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: _textPrimary,
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
