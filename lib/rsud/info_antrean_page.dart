import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'hospital_config.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class AntreanData {
  final String poli;
  final String dokter;
  final String jamPraktik;
  final String loket;
  final String antreanBerjalan;
  final int totalAntrean;
  final int sisaAntrean;
  final int estimasiMenit;

  const AntreanData({
    required this.poli,
    required this.dokter,
    required this.jamPraktik,
    required this.loket,
    required this.antreanBerjalan,
    required this.totalAntrean,
    required this.sisaAntrean,
    required this.estimasiMenit,
  });
}

// ── Page ──────────────────────────────────────────────────────────────────────

class InfoAntreanPage extends StatefulWidget {
  final HospitalConfig hospital;
  const InfoAntreanPage({super.key, required this.hospital});

  @override
  State<InfoAntreanPage> createState() => _InfoAntreanPageState();
}

class _InfoAntreanPageState extends State<InfoAntreanPage>
    with SingleTickerProviderStateMixin {
  // ── data ───────────────────────────────────────────────────────────────────
  List<AntreanData> _allData = [];
  bool _isLoading = true;

  // ── filter state ───────────────────────────────────────────────────────────
  String? _selectedPoli;
  String? _selectedDokter;
  bool _hasilApplied = false;
  AntreanData? _hasilData;

  // ── live dot animation ─────────────────────────────────────────────────────
  late AnimationController _liveCtrl;
  late Animation<double> _liveAnim;

  // ── theme ──────────────────────────────────────────────────────────────────
  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _whiteBg = Color.fromRGBO(248, 248, 245, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);
  static const Color _green = Color.fromRGBO(34, 180, 80, 1);

  // ── lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _liveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _liveAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _liveCtrl, curve: Curves.easeInOut),
    );
    _loadData();
  }

  @override
  void dispose() {
    _liveCtrl.dispose();
    super.dispose();
  }

  // ── data loading ───────────────────────────────────────────────────────────

  Future<void> _loadData() async {
    try {
      final raw = await rootBundle.loadString(widget.hospital.antreanCsv);
      final rows = const CsvToListConverter(
        fieldDelimiter: '|',
        shouldParseNumbers: false,
        eol: '\n',
      ).convert(raw);

      final List<AntreanData> list = [];

      for (int i = 1; i < rows.length; i++) {
        final r = rows[i];
        if (r.length < 8) continue;

        final poli = r[0].toString().trim().replaceAll('\r', '');
        if (poli.isEmpty) continue;

        final dokter = r[1].toString().trim().replaceAll('\r', '');
        final jamPraktik = r[2].toString().trim().replaceAll('\r', '');
        final loket = r[3].toString().trim().replaceAll('\r', '');
        final antreanBerjalan = r[4].toString().trim().replaceAll('\r', '');
        final totalAntrean =
            int.tryParse(r[5].toString().trim().replaceAll('\r', '')) ?? 0;
        final sisaAntrean =
            int.tryParse(r[6].toString().trim().replaceAll('\r', '')) ?? 0;
        final estimasiMenit =
            int.tryParse(r[7].toString().trim().replaceAll('\r', '')) ?? 0;

        list.add(AntreanData(
          poli: poli,
          dokter: dokter,
          jamPraktik: jamPraktik,
          loket: loket,
          antreanBerjalan: antreanBerjalan,
          totalAntrean: totalAntrean,
          sisaAntrean: sisaAntrean,
          estimasiMenit: estimasiMenit,
        ));
      }

      if (mounted) {
        setState(() {
          _allData = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('InfoAntrean: gagal load CSV – $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── computed ───────────────────────────────────────────────────────────────

  List<String> get _availablePolis =>
      _allData.map((d) => d.poli).toSet().toList()..sort();

  List<String> get _availableDokters {
    if (_selectedPoli == null) return _allData.map((d) => d.dokter).toList();
    return _allData
        .where((d) => d.poli == _selectedPoli)
        .map((d) => d.dokter)
        .toList();
  }

  bool get _isBothFilled =>
      _selectedPoli != null && _selectedDokter != null;

  bool get _buttonActive => _isBothFilled && !_hasilApplied;

  // ── actions ────────────────────────────────────────────────────────────────

  void _pickPoli() {
    _showBottomPicker(
      title: 'Pilih Poli',
      items: _availablePolis,
      selected: _selectedPoli,
      onSelect: (val) {
        setState(() {
          _selectedPoli = val;
          // Reset dokter jika tidak valid untuk poli baru
          if (_selectedDokter != null &&
              !_allData
                  .where((d) => d.poli == val)
                  .map((d) => d.dokter)
                  .contains(_selectedDokter)) {
            _selectedDokter = null;
          }
          _hasilApplied = false;
        });
      },
    );
  }

  void _pickDokter() {
    if (_availableDokters.isEmpty) return;
    _showBottomPicker(
      title: 'Pilih Dokter',
      items: _availableDokters,
      selected: _selectedDokter,
      onSelect: (val) {
        setState(() {
          _selectedDokter = val;
          _hasilApplied = false;
        });
      },
    );
  }

  void _cekAntrean() {
    if (!_isBothFilled) return;
    final match = _allData.firstWhere(
      (d) => d.poli == _selectedPoli && d.dokter == _selectedDokter,
      orElse: () => AntreanData(
        poli: _selectedPoli!,
        dokter: _selectedDokter!,
        jamPraktik: '-',
        loket: '-',
        antreanBerjalan: '-',
        totalAntrean: 0,
        sisaAntrean: 0,
        estimasiMenit: 0,
      ),
    );
    setState(() {
      _hasilData = match;
      _hasilApplied = true;
    });
  }

  void _showBottomPicker({
    required String title,
    required List<String> items,
    required String? selected,
    required ValueChanged<String> onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          maxChildSize: 0.85,
          minChildSize: 0.3,
          builder: (_, scrollCtrl) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(220, 220, 220, 1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    controller: scrollCtrl,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      color: Color.fromRGBO(240, 240, 240, 1),
                    ),
                    itemBuilder: (_, i) {
                      final item = items[i];
                      final isSelected = item == selected;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          item,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color:
                                isSelected ? _blue : _textPrimary,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_rounded,
                                color: _blue, size: 18)
                            : null,
                        onTap: () {
                          onSelect(item);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _whiteBg,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _blue),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterCard(),
                  if (_hasilApplied && _hasilData != null) ...[
                    const SizedBox(height: 24),
                    _buildHasilSection(_hasilData!),
                  ],
                ],
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _blue,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      title: const Text(
        'Info Antrean Pasien',
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'PlusJakartaSans',
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ── Filter Card ────────────────────────────────────────────────────────────

  Widget _buildFilterCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cari Data Antrean',
            style: TextStyle(
              color: _textPrimary,
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          // Pilih Poli
          _buildDropdownField(
            hint: 'Pilih Poli',
            value: _selectedPoli,
            icon: Icons.local_hospital_rounded,
            onTap: _pickPoli,
            onClear: _selectedPoli != null
                ? () => setState(() {
                      _selectedPoli = null;
                      _selectedDokter = null;
                      _hasilApplied = false;
                    })
                : null,
          ),
          const SizedBox(height: 10),
          // Pilih Dokter
          _buildDropdownField(
            hint: 'Pilih Dokter',
            value: _selectedDokter,
            icon: Icons.person_rounded,
            enabled: _selectedPoli != null,
            onTap: _pickDokter,
            onClear: _selectedDokter != null
                ? () => setState(() {
                      _selectedDokter = null;
                      _hasilApplied = false;
                    })
                : null,
          ),
          const SizedBox(height: 14),
          // Cek Antrean button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: _buttonActive ? _cekAntrean : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _buttonActive ? _blue : const Color.fromRGBO(210, 210, 210, 1),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Cek Antrean',
                style: TextStyle(
                  color: _buttonActive
                      ? Colors.white
                      : const Color.fromRGBO(160, 160, 160, 1),
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String hint,
    required String? value,
    required IconData icon,
    required VoidCallback onTap,
    VoidCallback? onClear,
    bool enabled = true,
  }) {
    final isFilled = value != null;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: enabled
              ? Colors.white
              : const Color.fromRGBO(248, 248, 248, 1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isFilled
                ? _blue
                : const Color.fromRGBO(220, 220, 220, 1),
            width: isFilled ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isFilled ? _blue : _textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value ?? hint,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isFilled ? _textPrimary : _textSecondary,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight:
                      isFilled ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close_rounded,
                    size: 18, color: _textSecondary),
              )
            else
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: enabled ? _textSecondary : const Color.fromRGBO(200, 200, 200, 1),
              ),
          ],
        ),
      ),
    );
  }

  // ── Hasil Section ──────────────────────────────────────────────────────────

  Widget _buildHasilSection(AntreanData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row: HASIL PENCARIAN + LIVE
        Row(
          children: [
            const Text(
              'HASIL PENCARIAN',
              style: TextStyle(
                color: _textPrimary,
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            AnimatedBuilder(
              animation: _liveAnim,
              builder: (_, __) => Opacity(
                opacity: _liveAnim.value,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: _green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'LIVE',
                      style: TextStyle(
                        color: _green,
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Antrean berjalan + total side by side
        IntrinsicHeight(
          child: Row(
            children: [
              // Left: Antrean berjalan (blue)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _blue,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ANTREAN BERJALAN',
                        style: TextStyle(
                          color: Colors.white70,
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        data.antreanBerjalan,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.computer_rounded,
                              color: Colors.white70, size: 14),
                          const SizedBox(width: 5),
                          Text(
                            data.loket,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Right: Total antrean (white)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
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
                      const Text(
                        'TOTAL ANTREAN',
                        style: TextStyle(
                          color: _textSecondary,
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${data.totalAntrean}',
                        style: const TextStyle(
                          color: _textPrimary,
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.trending_flat_rounded,
                              color: _textSecondary, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Estimasi: ${data.estimasiMenit} Menit',
                              style: const TextStyle(
                                color: _textSecondary,
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Detail rows
        _buildDetailCard(
          icon: Icons.local_hospital_rounded,
          iconBg: const Color.fromRGBO(235, 243, 255, 1),
          iconColor: _blue,
          label: 'NAMA POLI',
          value: data.poli,
        ),
        const SizedBox(height: 8),
        _buildDetailCard(
          icon: Icons.person_rounded,
          iconBg: const Color.fromRGBO(230, 255, 237, 1),
          iconColor: const Color.fromRGBO(34, 160, 80, 1),
          label: 'NAMA DOKTER',
          value: data.dokter,
        ),
        const SizedBox(height: 8),
        _buildDetailCard(
          icon: Icons.access_time_rounded,
          iconBg: const Color.fromRGBO(255, 247, 230, 1),
          iconColor: const Color.fromRGBO(200, 120, 0, 1),
          label: 'JAM PRAKTIK',
          value: data.jamPraktik,
        ),
        const SizedBox(height: 8),
        _buildDetailCard(
          icon: Icons.groups_rounded,
          iconBg: const Color.fromRGBO(253, 231, 255, 1),
          iconColor: const Color.fromRGBO(160, 0, 190, 1),
          label: 'SISA ANTREAN',
          value: '${data.sisaAntrean} orang lagi',
        ),
        const SizedBox(height: 14),

        // Info box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(235, 243, 255, 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: _blue, size: 18),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Data antrean di atas diperbarui setiap 2 menit secara otomatis. '
                  'Silakan datang 15 menit sebelum nomor antrean Anda dipanggil '
                  'untuk verifikasi dokumen.',
                  style: TextStyle(
                    color: _blue,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    height: 1.55,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
