import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_retry.dart';
import '../widgets/skeleton_loader.dart';
import 'hospital_config.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class KamarData {
  final String ruang;
  final String kelas;
  final int kapasitas;
  final int terisi;

  int get sisa => kapasitas - terisi;

  const KamarData({
    required this.ruang,
    required this.kelas,
    required this.kapasitas,
    required this.terisi,
  });
}

// ── Page ──────────────────────────────────────────────────────────────────────

class KetersediaanKamarPage extends StatefulWidget {
  final HospitalConfig hospital;
  const KetersediaanKamarPage({super.key, required this.hospital});

  @override
  State<KetersediaanKamarPage> createState() => _KetersediaanKamarPageState();
}

class _KetersediaanKamarPageState extends State<KetersediaanKamarPage> {
  List<KamarData> _kamarList = [];
  String _updateTerakhir = '-';
  bool _isLoading = true;
  bool _showAll = false;
  Object? _loadError;

  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _whiteBg = Color.fromRGBO(248, 248, 245, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);
  static const Color _red = Color.fromRGBO(220, 53, 69, 1);

  // How many rows to show in collapsed mode
  static const int _collapsedCount = 5;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final raw = await rootBundle.loadString(widget.hospital.kamarCsv);
      final rows = Csv(fieldDelimiter: ',', lineDelimiter: '\n').decode(raw);

      String timestamp = '';
      final List<KamarData> list = [];

      // Row 0 = header; skip it. Rows 1+ = data.
      for (int i = 1; i < rows.length; i++) {
        final r = rows[i];
        if (r.length < 4) continue;

        final ruang = r[0].toString().trim();
        final kelas = r[1].toString().trim().toUpperCase();
        // Strip any stray \r from Windows CRLF line endings
        final kapasitas =
            int.tryParse(r[2].toString().trim().replaceAll('\r', '')) ?? 0;
        final terisi =
            int.tryParse(r[3].toString().trim().replaceAll('\r', '')) ?? 0;

        if (ruang.isEmpty || ruang.startsWith('#')) continue;

        // First non-empty update_terakhir wins
        if (timestamp.isEmpty && r.length >= 5) {
          final ts = r[4].toString().trim().replaceAll('\r', '');
          if (ts.isNotEmpty) timestamp = ts;
        }

        list.add(KamarData(
          ruang: ruang,
          kelas: kelas,
          kapasitas: kapasitas,
          terisi: terisi,
        ));
      }

      if (mounted) {
        setState(() {
          _kamarList = list;
          _updateTerakhir = timestamp.isEmpty ? '-' : timestamp;
          _loadError = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('KetersediaanKamar: gagal load CSV – $e');
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

  // ── Computed totals ───────────────────────────────────────────────────────

  int get _totalKapasitas =>
      _kamarList.fold(0, (s, k) => s + k.kapasitas);

  int get _totalTerisi =>
      _kamarList.fold(0, (s, k) => s + k.terisi);

  int get _totalTersedia => _totalKapasitas - _totalTerisi;

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _whiteBg,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const SkeletonLoader.dashboard()
          : _loadError != null
              ? ErrorRetry(
                  title: 'Gagal memuat data kamar',
                  subtitle: ErrorRetry.fromException(_loadError!),
                  onRetry: _retryLoad,
                )
              : _kamarList.isEmpty
                  ? _buildEmptyState()
                  : _buildBody(),
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.king_bed_outlined,
      title: 'Data kamar belum tersedia',
      subtitle:
          'Informasi ketersediaan kamar ${widget.hospital.name}\nbelum dipublikasikan. Coba muat ulang.',
      actionLabel: 'Muat Ulang',
      onAction: _refresh,
    );
  }

  Future<void> _refresh() async {
    setState(() => _isLoading = true);
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
            'Ketersediaan Kamar Rawat',
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
          _buildRincianCard(),
        ],
      ),
    );
  }

  // ── Summary Banner ────────────────────────────────────────────────────────

  Widget _buildSummaryBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(0, 101, 255, 1),
            Color.fromRGBO(0, 60, 180, 1),
          ],
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
        children: [
          // Decorative circle
          Positioned(
            right: -16,
            bottom: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'KAMAR TERSEDIA',
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
                '$_totalTersedia',
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 52,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded,
                      color: Colors.white60, size: 13),
                  const SizedBox(width: 5),
                  Text(
                    'Update Terakhir: $_updateTerakhir',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
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

  // ── Stat Row ──────────────────────────────────────────────────────────────

  Widget _buildStatRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.king_bed_rounded,
            iconBg: const Color.fromRGBO(235, 243, 255, 1),
            iconColor: _blue,
            label: 'TOTAL KAMAR',
            value: '$_totalKapasitas',
            valueColor: _textPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.hotel_rounded,
            iconBg: const Color.fromRGBO(255, 235, 238, 1),
            iconColor: _red,
            label: 'KAMAR TERISI',
            value: '$_totalTerisi',
            valueColor: _red,
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: _textSecondary,
              fontFamily: 'PlusJakartaSans',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontFamily: 'PlusJakartaSans',
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ── Rincian Card ──────────────────────────────────────────────────────────

  Widget _buildRincianCard() {
    final displayed = _showAll
        ? _kamarList
        : _kamarList.take(_collapsedCount).toList();

    return Container(
      width: double.infinity,
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
          // Title
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              'Rincian Per Ruang',
              style: TextStyle(
                color: _textPrimary,
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Column headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                Expanded(
                  flex: 5,
                  child: _TableHeader('RUANG / KELAS'),
                ),
                Expanded(
                  flex: 3,
                  child: _TableHeader('KAPASITAS', center: true),
                ),
                Expanded(
                  flex: 2,
                  child: _TableHeader('ISI', center: true),
                ),
                Expanded(
                  flex: 2,
                  child: _TableHeader('SISA', center: true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, thickness: 1,
              color: Color.fromRGBO(240, 240, 240, 1)),
          // Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayed.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              thickness: 1,
              color: Color.fromRGBO(240, 240, 240, 1),
            ),
            itemBuilder: (context, i) => _buildKamarRow(displayed[i]),
          ),
          if (_kamarList.length > _collapsedCount) ...[
            const Divider(height: 1, thickness: 1,
                color: Color.fromRGBO(240, 240, 240, 1)),
            GestureDetector(
              onTap: () => setState(() => _showAll = !_showAll),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Center(
                  child: Text(
                    _showAll ? 'Sembunyikan' : 'Lihat Selengkapnya',
                    style: const TextStyle(
                      color: _blue,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKamarRow(KamarData k) {
    final pct = k.kapasitas == 0 ? 0.0 : (k.terisi / k.kapasitas).clamp(0.0, 1.0);
    final barColor = pct >= 0.9
        ? _red
        : pct >= 0.7
            ? const Color.fromRGBO(245, 124, 0, 1)
            : _blue;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ruang + badge
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      k.ruang,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _KelasChip(kelas: k.kelas),
                  ],
                ),
              ),
              // Kapasitas
              Expanded(
                flex: 3,
                child: Text(
                  '${k.kapasitas}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // ISI (red)
              Expanded(
                flex: 2,
                child: Text(
                  '${k.terisi}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _red,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // SISA (blue)
              Expanded(
                flex: 2,
                child: Text(
                  '${k.sisa}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _blue,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 5,
                    backgroundColor: const Color.fromRGBO(230, 230, 230, 1),
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(pct * 100).round()}%',
                style: TextStyle(
                  color: barColor,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
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

class _TableHeader extends StatelessWidget {
  final String text;
  final bool center;
  const _TableHeader(this.text, {this.center = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: center ? TextAlign.center : TextAlign.left,
      style: const TextStyle(
        color: Color.fromRGBO(120, 120, 120, 1),
        fontFamily: 'PlusJakartaSans',
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _KelasChip extends StatelessWidget {
  final String kelas;
  const _KelasChip({required this.kelas});

  static const Map<String, Color> _bgMap = {
    'VIP': Color.fromRGBO(230, 244, 255, 1),
    'KELAS1': Color.fromRGBO(230, 255, 237, 1),
    'KELAS2': Color.fromRGBO(255, 247, 230, 1),
    'KELAS3': Color.fromRGBO(245, 245, 245, 1),
    'ICU': Color.fromRGBO(255, 235, 238, 1),
    'HCU': Color.fromRGBO(255, 235, 238, 1),
    'NICU': Color.fromRGBO(253, 231, 255, 1),
    'PERINATOLOGI': Color.fromRGBO(240, 230, 255, 1),
    'KEBIDANAN': Color.fromRGBO(225, 255, 252, 1),
    'ISOLASI': Color.fromRGBO(255, 240, 225, 1),
  };

  static const Map<String, Color> _fgMap = {
    'VIP': Color.fromRGBO(0, 101, 255, 1),
    'KELAS1': Color.fromRGBO(25, 155, 60, 1),
    'KELAS2': Color.fromRGBO(200, 120, 0, 1),
    'KELAS3': Color.fromRGBO(100, 100, 100, 1),
    'ICU': Color.fromRGBO(200, 30, 50, 1),
    'HCU': Color.fromRGBO(200, 30, 50, 1),
    'NICU': Color.fromRGBO(160, 0, 190, 1),
    'PERINATOLOGI': Color.fromRGBO(100, 0, 200, 1),
    'KEBIDANAN': Color.fromRGBO(0, 150, 136, 1),
    'ISOLASI': Color.fromRGBO(200, 90, 0, 1),
  };

  @override
  Widget build(BuildContext context) {
    final bg = _bgMap[kelas] ?? const Color.fromRGBO(245, 245, 245, 1);
    final fg = _fgMap[kelas] ?? const Color.fromRGBO(80, 80, 80, 1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        kelas,
        style: TextStyle(
          color: fg,
          fontFamily: 'PlusJakartaSans',
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
