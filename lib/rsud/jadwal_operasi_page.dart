import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/error_retry.dart';
import '../widgets/skeleton_loader.dart';
import 'hospital_config.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class JadwalData {
  final String tanggal; // DD/MM/YYYY
  final String hari;
  final String jamMulai;
  final String jamSelesai;
  final String namaOperasi;
  final String dokter;
  final String klinik;
  final String status;

  String get jamRange => '$jamMulai – $jamSelesai';
  bool get isTerjadwal => status == 'Terjadwal';

  const JadwalData({
    required this.tanggal,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    required this.namaOperasi,
    required this.dokter,
    required this.klinik,
    required this.status,
  });
}

// ── Page ──────────────────────────────────────────────────────────────────────

class JadwalOperasiPage extends StatefulWidget {
  final HospitalConfig hospital;
  const JadwalOperasiPage({super.key, required this.hospital});

  @override
  State<JadwalOperasiPage> createState() => _JadwalOperasiPageState();
}

class _JadwalOperasiPageState extends State<JadwalOperasiPage> {
  // ── data ───────────────────────────────────────────────────────────────────
  List<JadwalData> _allData = [];
  String _updateTerakhir = '-';
  bool _isLoading = true;
  Object? _loadError;

  // ── filter state ───────────────────────────────────────────────────────────
  final _searchCtrl = TextEditingController();
  String? _selectedTanggal; // DD/MM/YYYY
  String? _selectedKlinik;
  bool _isFilterApplied = false;
  List<JadwalData> _hasilList = [];

  // ── theme ──────────────────────────────────────────────────────────────────
  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _whiteBg = Color.fromRGBO(248, 248, 245, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);
  static const Color _green = Color.fromRGBO(34, 160, 80, 1);

  static const List<String> _monthNames = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const Map<String, Color> _klinikColors = {
    'KLINIK BEDAH': Color.fromRGBO(0, 101, 255, 1),
    'KLINIK MATA': Color.fromRGBO(130, 30, 200, 1),
    'KLINIK ORTOPEDI': Color.fromRGBO(210, 100, 0, 1),
    'KLINIK OBSGIN': Color.fromRGBO(200, 0, 100, 1),
    'KLINIK THT': Color.fromRGBO(0, 150, 130, 1),
    'KLINIK UROLOGI': Color.fromRGBO(30, 70, 180, 1),
    'KLINIK JANTUNG': Color.fromRGBO(200, 30, 30, 1),
  };

  // ── lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onFilterChanged);
    _loadData();
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onFilterChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── data loading ───────────────────────────────────────────────────────────

  Future<void> _loadData() async {
    try {
      final raw = await rootBundle.loadString(widget.hospital.jadwalCsv);
      final rows = Csv(fieldDelimiter: '|', lineDelimiter: '\n').decode(raw);

      String timestamp = '';
      final List<JadwalData> list = [];

      for (int i = 1; i < rows.length; i++) {
        final r = rows[i];
        if (r.length < 9) continue;

        final tanggal = r[1].toString().trim().replaceAll('\r', '');
        if (tanggal.isEmpty) continue;

        final hari = r[2].toString().trim().replaceAll('\r', '');
        final jamMulai = r[3].toString().trim().replaceAll('\r', '');
        final jamSelesai = r[4].toString().trim().replaceAll('\r', '');
        final namaOperasi = r[5].toString().trim().replaceAll('\r', '');
        final dokter = r[6].toString().trim().replaceAll('\r', '');
        final klinik = r[7].toString().trim().replaceAll('\r', '').toUpperCase();
        final status = r[8].toString().trim().replaceAll('\r', '');

        if (timestamp.isEmpty && r.length >= 10) {
          final ts = r[9].toString().trim().replaceAll('\r', '');
          if (ts.isNotEmpty) timestamp = ts;
        }

        list.add(JadwalData(
          tanggal: tanggal,
          hari: hari,
          jamMulai: jamMulai,
          jamSelesai: jamSelesai,
          namaOperasi: namaOperasi,
          dokter: dokter,
          klinik: klinik,
          status: status,
        ));
      }

      if (mounted) {
        setState(() {
          _allData = list;
          _updateTerakhir = timestamp.isEmpty ? '-' : timestamp;
          _loadError = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('JadwalOperasi: gagal load CSV – $e');
      if (mounted) {
        setState(() {
          _loadError = e;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _retryLoad() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    await _loadData();
  }

  // ── computed ───────────────────────────────────────────────────────────────

  int get _totalOperasi => _allData.length;
  int get _totalTerjadwal =>
      _allData.where((d) => d.isTerjadwal).length;
  int get _totalSelesai =>
      _allData.where((d) => !d.isTerjadwal).length;

  bool get _isAnyFilterSet =>
      _searchCtrl.text.trim().isNotEmpty ||
      _selectedTanggal != null ||
      _selectedKlinik != null;

  List<String> get _availableKliniks =>
      _allData.map((d) => d.klinik).toSet().toList()..sort();

  // ── filter helpers ─────────────────────────────────────────────────────────

  void _onFilterChanged() {
    if (_isFilterApplied && mounted) {
      setState(() => _isFilterApplied = false);
    }
  }

  void _applyFilter() {
    if (!_isAnyFilterSet) return;

    List<JadwalData> result = List.from(_allData);
    final search = _searchCtrl.text.trim().toLowerCase();

    if (search.isNotEmpty) {
      result = result
          .where((d) => d.namaOperasi.toLowerCase().contains(search))
          .toList();
    }
    if (_selectedTanggal != null) {
      result = result.where((d) => d.tanggal == _selectedTanggal).toList();
    }
    if (_selectedKlinik != null) {
      result = result.where((d) => d.klinik == _selectedKlinik).toList();
    }

    setState(() {
      _hasilList = result;
      _isFilterApplied = true;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1, 1, 1),
      lastDate: DateTime(now.year + 2, 12, 31),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
              const ColorScheme.light(primary: _blue, onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      final dd = picked.day.toString().padLeft(2, '0');
      final mm = picked.month.toString().padLeft(2, '0');
      final yyyy = picked.year.toString();
      setState(() {
        _selectedTanggal = '$dd/$mm/$yyyy';
        _isFilterApplied = false;
      });
    }
  }

  void _pickKlinik() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const Text(
              'Pilih Klinik / Spesialis',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ..._availableKliniks.map((k) {
              final selected = _selectedKlinik == k;
              final color = _klinikColors[k] ??
                  const Color.fromRGBO(80, 80, 80, 1);
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                title: Text(
                  k,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? _blue : _textPrimary,
                  ),
                ),
                trailing: selected
                    ? const Icon(Icons.check_rounded, color: _blue, size: 20)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedKlinik = k;
                    _isFilterApplied = false;
                  });
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── date helpers ───────────────────────────────────────────────────────────

  int _dateSortKey(String ddmmyyyy) {
    final p = ddmmyyyy.split('/');
    if (p.length != 3) return 0;
    final dd = int.tryParse(p[0]) ?? 0;
    final mm = int.tryParse(p[1]) ?? 0;
    final yyyy = int.tryParse(p[2]) ?? 0;
    return yyyy * 10000 + mm * 100 + dd;
  }

  String _formatDateHeader(String ddmmyyyy, String hari) {
    final parts = ddmmyyyy.split('/');
    if (parts.length != 3) return '$hari, $ddmmyyyy';
    final month = int.tryParse(parts[1]) ?? 0;
    final monthName =
        (month >= 1 && month <= 12) ? _monthNames[month] : '';
    return '$hari, ${parts[0]} $monthName ${parts[2]}';
  }

  Map<String, List<JadwalData>> _groupByDate(List<JadwalData> list) {
    final sorted = List<JadwalData>.from(list)
      ..sort((a, b) => _dateSortKey(a.tanggal).compareTo(_dateSortKey(b.tanggal)));
    final map = <String, List<JadwalData>>{};
    for (final item in sorted) {
      map.putIfAbsent(item.tanggal, () => []).add(item);
    }
    return map;
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _whiteBg,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const SkeletonLoader.dashboard()
          : _loadError != null
              ? ErrorRetry(
                  title: 'Gagal memuat jadwal operasi',
                  subtitle: ErrorRetry.fromException(_loadError!),
                  onRetry: _retryLoad,
                )
              : _buildBody(),
    );
  }

  Future<void> _refresh() async {
    _searchCtrl.clear();
    setState(() {
      _isLoading = true;
      _isFilterApplied = false;
      _hasilList = [];
      _selectedTanggal = null;
      _selectedKlinik = null;
    });
    await _loadData();
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.hospital.name,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'PlusJakartaSans',
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Text(
            'Jadwal Operasi',
            style: TextStyle(
              color: Colors.white70,
              fontFamily: 'PlusJakartaSans',
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _isLoading ? null : _refresh,
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryBanner(),
          const SizedBox(height: 16),
          _buildStatRow(),
          const SizedBox(height: 20),
          _buildFilterCard(),
          const SizedBox(height: 20),
          if (_isFilterApplied) _buildHasilSection() else _buildGroupedList(),
        ],
      ),
    );
  }

  // ── Summary Banner ─────────────────────────────────────────────────────────

  Widget _buildSummaryBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color.fromRGBO(0, 101, 255, 1), Color.fromRGBO(0, 55, 180, 1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _blue.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Watermark icon
          Positioned(
            right: -10,
            bottom: -14,
            child: Icon(
              Icons.medical_services_rounded,
              size: 90,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: label + number
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL OPERASI',
                      style: TextStyle(
                        color: Colors.white70,
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_totalOperasi',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 44,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              // Right: timestamp
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time_rounded,
                      color: Colors.white60, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    _updateTerakhir,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Stat Row ───────────────────────────────────────────────────────────────

  Widget _buildStatRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.calendar_today_rounded,
            iconBg: const Color.fromRGBO(235, 243, 255, 1),
            iconColor: _blue,
            label: 'TERJADWAL',
            value: '$_totalTerjadwal',
            valueColor: _textPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle_rounded,
            iconBg: const Color.fromRGBO(230, 255, 237, 1),
            iconColor: _green,
            label: 'SELESAI',
            value: '$_totalSelesai',
            valueColor: _green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: _textSecondary,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Filter Card ────────────────────────────────────────────────────────────

  Widget _buildFilterCard() {
    final buttonActive = _isAnyFilterSet && !_isFilterApplied;

    return Container(
      padding: const EdgeInsets.all(16),
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
          const Text(
            'Cari Data Operasi',
            style: TextStyle(
              color: _textPrimary,
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          // Search field
          TextField(
            controller: _searchCtrl,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              color: _textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Cari Nama Operasi',
              hintStyle: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                color: _textSecondary,
              ),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: _textSecondary, size: 20),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    color: Color.fromRGBO(220, 220, 220, 1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    color: Color.fromRGBO(220, 220, 220, 1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _blue, width: 1.4),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Tanggal + Spesialis row
          Row(
            children: [
              Expanded(child: _buildFilterButton(
                icon: Icons.calendar_month_rounded,
                label: _selectedTanggal ?? 'Tanggal',
                isActive: _selectedTanggal != null,
                onTap: _pickDate,
                onClear: _selectedTanggal != null
                    ? () => setState(() {
                          _selectedTanggal = null;
                          _isFilterApplied = false;
                        })
                    : null,
              )),
              const SizedBox(width: 10),
              Expanded(child: _buildFilterButton(
                icon: Icons.grid_view_rounded,
                label: _selectedKlinik ?? 'Spesialis',
                isActive: _selectedKlinik != null,
                onTap: _pickKlinik,
                onClear: _selectedKlinik != null
                    ? () => setState(() {
                          _selectedKlinik = null;
                          _isFilterApplied = false;
                        })
                    : null,
              )),
            ],
          ),
          const SizedBox(height: 12),
          // Apply button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: buttonActive ? _applyFilter : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonActive ? _blue : const Color.fromRGBO(210, 210, 210, 1),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Terapkan Filter',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: buttonActive ? Colors.white : const Color.fromRGBO(160, 160, 160, 1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isActive
              ? const Color.fromRGBO(235, 243, 255, 1)
              : const Color.fromRGBO(248, 248, 248, 1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? _blue
                : const Color.fromRGBO(220, 220, 220, 1),
            width: isActive ? 1.2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 16,
                color: isActive ? _blue : _textSecondary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? _blue : _textSecondary,
                ),
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close_rounded,
                    size: 16, color: _textSecondary),
              )
            else
              const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 16, color: _textSecondary),
          ],
        ),
      ),
    );
  }

  // ── Grouped List (default view) ────────────────────────────────────────────

  Widget _buildGroupedList() {
    if (_allData.isEmpty) {
      return const _EmptyState(message: 'Data jadwal tidak tersedia.');
    }
    final grouped = _groupByDate(_allData);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((entry) {
        final ddmmyyyy = entry.key;
        final items = entry.value;
        final hari = items.first.hari;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Row(
              children: [
                Expanded(
                  child: Text(
                    _formatDateHeader(ddmmyyyy, hari),
                    style: const TextStyle(
                      color: _textPrimary,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${items.length} operasi',
                  style: const TextStyle(
                    color: _textSecondary,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Horizontal scroll cards
            SizedBox(
              height: 158,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (ctx, i) =>
                    _JadwalCard(data: items[i], klinikColors: _klinikColors),
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      }).toList(),
    );
  }

  // ── Hasil Section ──────────────────────────────────────────────────────────

  Widget _buildHasilSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            Text(
              '${_hasilList.length} jadwal ditemukan',
              style: const TextStyle(
                color: _textSecondary,
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_hasilList.isEmpty)
          const _EmptyState(message: 'Tidak ada jadwal yang cocok.')
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _hasilList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) => _JadwalCard(
              data: _hasilList[i],
              fullWidth: true,
              klinikColors: _klinikColors,
            ),
          ),
      ],
    );
  }
}

// ── Jadwal Card ───────────────────────────────────────────────────────────────

class _JadwalCard extends StatelessWidget {
  final JadwalData data;
  final bool fullWidth;
  final Map<String, Color> klinikColors;

  const _JadwalCard({
    required this.data,
    this.fullWidth = false,
    required this.klinikColors,
  });

  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);
  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _green = Color.fromRGBO(34, 160, 80, 1);

  @override
  Widget build(BuildContext context) {
    final klinikColor =
        klinikColors[data.klinik] ?? const Color.fromRGBO(80, 80, 80, 1);

    return Container(
      width: fullWidth ? double.infinity : 230,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Klinik + time chips
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _Chip(
                label: data.klinik,
                color: klinikColor,
                bgColor: klinikColor.withValues(alpha: 0.12),
              ),
              _Chip(
                label: data.jamRange,
                icon: Icons.access_time_rounded,
                color: _textSecondary,
                bgColor: const Color.fromRGBO(240, 240, 240, 1),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Operation name
          Text(
            data.namaOperasi,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _textPrimary,
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 5),
          // Doctor
          Row(
            children: [
              const Icon(Icons.person_rounded,
                  size: 13, color: _textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  data.dokter,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Status
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: data.isTerjadwal ? _blue : _green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                data.status,
                style: TextStyle(
                  color: data.isTerjadwal ? _blue : _green,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;
  final IconData? icon;

  const _Chip({
    required this.label,
    required this.color,
    required this.bgColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontFamily: 'PlusJakartaSans',
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded,
                size: 48, color: Color.fromRGBO(200, 200, 200, 1)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color.fromRGBO(160, 160, 160, 1),
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
