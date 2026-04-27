import 'package:flutter/material.dart';
import '../models/etibi_model.dart';

class RiwayatTab extends StatelessWidget {
  final List<RiwayatSkrining> riwayatList;
  final Future<void> Function()? onRefresh;
  final void Function(RiwayatSkrining)? onDelete;

  const RiwayatTab({
    super.key,
    required this.riwayatList,
    this.onRefresh,
    this.onDelete,
  });

  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);

  static const Map<String, int> _bulan = {
    'Januari': 1, 'Februari': 2, 'Maret': 3, 'April': 4,
    'Mei': 5, 'Juni': 6, 'Juli': 7, 'Agustus': 8,
    'September': 9, 'Oktober': 10, 'November': 11, 'Desember': 12,
  };

  static DateTime? _parseDate(String tanggal) {
    final parts = tanggal.split(' ');
    if (parts.length != 3) return null;
    final day   = int.tryParse(parts[0]);
    final month = _bulan[parts[1]];
    final year  = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  static String _hariLalu(String tanggal) {
    final date = _parseDate(tanggal);
    if (date == null) return tanggal;
    final selisih = DateTime.now().difference(date).inDays;
    if (selisih == 0) return 'Hari ini';
    if (selisih == 1) return 'Kemarin';
    return '$selisih hari lalu';
  }

  String get _trendLabel {
    if (riwayatList.length < 2) return 'Belum ada data tren';
    final delta = riwayatList[0].skor - riwayatList[1].skor;
    if (delta < 0) return 'Membaik';
    if (delta > 0) return 'Memburuk';
    return 'Stabil';
  }

  Color get _trendColor {
    if (riwayatList.length < 2) return _textSecondary;
    final delta = riwayatList[0].skor - riwayatList[1].skor;
    if (delta < 0) return const Color(0xFF2E7D32);
    if (delta > 0) return const Color(0xFFD32F2F);
    return const Color(0xFFF59E0B);
  }

  IconData get _trendIcon {
    if (riwayatList.length < 2) return Icons.remove;
    final delta = riwayatList[0].skor - riwayatList[1].skor;
    if (delta < 0) return Icons.trending_down_rounded;
    if (delta > 0) return Icons.trending_up_rounded;
    return Icons.trending_flat_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final scrollView = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildSummaryCard()),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Riwayat Skrining',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
          ),
        ),
        if (onDelete != null)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.swipe_left_outlined, size: 13, color: _textSecondary),
                  SizedBox(width: 4),
                  Text(
                    'Geser kiri untuk hapus',
                    style: TextStyle(
                      color: _textSecondary,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        SliverList.separated(
          itemCount: riwayatList.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (ctx, i) {
            final prev = (i + 1 < riwayatList.length) ? riwayatList[i + 1] : null;
            final card = RiwayatCard(
              riwayat: riwayatList[i],
              prevRiwayat: prev,
              onTap: () => _showDetail(ctx, riwayatList[i]),
            );
            if (onDelete == null) return card;
            return Dismissible(
              key: ValueKey(
                riwayatList[i].docId ?? riwayatList[i].createdAtMs.toString(),
              ),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outline, color: Colors.white, size: 24),
                    SizedBox(height: 4),
                    Text(
                      'Hapus',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              confirmDismiss: (_) async {
                return await showDialog<bool>(
                  context: ctx,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text(
                      'Hapus Riwayat?',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    content: const Text(
                      'Data skrining ini akan dihapus permanen.',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: 'PlusJakartaSans',
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text(
                          'Hapus',
                          style: TextStyle(
                            color: Color(0xFFD32F2F),
                            fontFamily: 'PlusJakartaSans',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ) ?? false;
              },
              onDismissed: (_) => onDelete!(riwayatList[i]),
              child: card,
            );
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );

    if (onRefresh != null) {
      return RefreshIndicator(
        color: _blue,
        onRefresh: onRefresh!,
        child: scrollView,
      );
    }
    return scrollView;
  }

  void _showDetail(BuildContext context, RiwayatSkrining r) {
    Color levelColor;
    switch (r.levelRisiko) {
      case 'Tinggi': levelColor = const Color(0xFFD32F2F); break;
      case 'Sedang': levelColor = const Color(0xFFF59E0B); break;
      default: levelColor = const Color(0xFF2E7D32);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    'Detail Hasil Skrining',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: levelColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Risiko ${r.levelRisiko}',
                      style: TextStyle(
                        color: levelColor,
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Color(0xFFF0F0F0)),
              const SizedBox(height: 16),
              _detailRow('Tanggal Skrining', r.tanggal),
              _detailRow('Skor Total', '${r.skor} / ${r.skorMax} poin'),
              _detailRow('Hasil', r.hasil),
              _detailRow('Faskes', r.faskes),
              _detailRow('Kabupaten', r.kabupaten),
              if (r.noTelp != '-') _detailRow('No. Telp Faskes', r.noTelp),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: levelColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, color: levelColor, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        r.levelRisiko == 'Tinggi'
                            ? 'Segera kunjungi fasilitas kesehatan terdekat untuk pemeriksaan lebih lanjut.'
                            : r.levelRisiko == 'Sedang'
                                ? 'Disarankan berkonsultasi dengan tenaga kesehatan untuk evaluasi lebih lanjut.'
                                : 'Pertahankan pola hidup sehat dan lakukan skrining secara berkala.',
                        style: TextStyle(
                          color: levelColor,
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                color: _textSecondary,
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(color: _textSecondary)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: _textPrimary,
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final latest   = riwayatList.isNotEmpty ? riwayatList[0] : null;
    final total    = riwayatList.length;
    final hasTren  = riwayatList.length >= 2;

    Color latestColor = const Color(0xFF2E7D32);
    if (latest != null) {
      if (latest.levelRisiko == 'Tinggi') latestColor = const Color(0xFFD32F2F);
      if (latest.levelRisiko == 'Sedang') latestColor = const Color(0xFFF59E0B);
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color.fromRGBO(0, 101, 255, 1), Color(0xFF3D8BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history_rounded, color: Colors.white70, size: 16),
              SizedBox(width: 6),
              Text(
                'Ringkasan Skrining',
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _summaryItem(
                label: 'Total Skrining',
                value: '$total kali',
                icon: Icons.assignment_outlined,
              ),
              _verticalDivider(),
              _summaryItem(
                label: 'Terakhir',
                value: latest != null ? _hariLalu(latest.tanggal) : '-',
                icon: Icons.access_time_rounded,
              ),
              _verticalDivider(),
              _summaryItem(
                label: 'Tren',
                value: hasTren ? _trendLabel : 'Pertama',
                icon: _trendIcon,
                valueColor: hasTren ? _trendColor : Colors.white70,
              ),
            ],
          ),
          if (latest != null) ...[
            const SizedBox(height: 14),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Hasil terakhir:',
                  style: TextStyle(
                    color: Colors.white70,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: latestColor.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: latestColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'Risiko ${latest.levelRisiko}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Skor ${latest.skor}/${latest.skorMax}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryItem({
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: valueColor ?? Colors.white, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontFamily: 'PlusJakartaSans',
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() =>
      Container(width: 1, height: 40, color: Colors.white24);
}

// ── Riwayat Card ──────────────────────────────────────────────────────────────
class RiwayatCard extends StatelessWidget {
  final RiwayatSkrining riwayat;
  final RiwayatSkrining? prevRiwayat;
  final VoidCallback? onTap;

  const RiwayatCard({
    super.key,
    required this.riwayat,
    this.prevRiwayat,
    this.onTap,
  });

  static const Color _textPrimary   = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);

  static const Map<String, int> _bulan = {
    'Januari': 1, 'Februari': 2, 'Maret': 3, 'April': 4,
    'Mei': 5, 'Juni': 6, 'Juli': 7, 'Agustus': 8,
    'September': 9, 'Oktober': 10, 'November': 11, 'Desember': 12,
  };

  static DateTime? _parseDate(String tanggal) {
    final parts = tanggal.split(' ');
    if (parts.length != 3) return null;
    final day   = int.tryParse(parts[0]);
    final month = _bulan[parts[1]];
    final year  = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  Color get _levelColor {
    switch (riwayat.levelRisiko) {
      case 'Tinggi': return const Color(0xFFD32F2F);
      case 'Sedang': return const Color(0xFFF59E0B);
      default:       return const Color(0xFF2E7D32);
    }
  }

  Color get _levelBg {
    switch (riwayat.levelRisiko) {
      case 'Tinggi': return const Color(0xFFFFEBEE);
      case 'Sedang': return const Color(0xFFFFF8E1);
      default:       return const Color(0xFFE8F5E9);
    }
  }

  int? get _deltaSkor {
    if (prevRiwayat == null) return null;
    return riwayat.skor - prevRiwayat!.skor;
  }

  int? get _selisihHari {
    if (prevRiwayat == null) return null;
    final a = _parseDate(riwayat.tanggal);
    final b = _parseDate(prevRiwayat!.tanggal);
    if (a == null || b == null) return null;
    return a.difference(b).inDays.abs();
  }

  @override
  Widget build(BuildContext context) {
    final double progress = riwayat.skorMax > 0 ? riwayat.skor / riwayat.skorMax : 0;
    final delta = _deltaSkor;
    final hari  = _selisihHari;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tanggal Skrining',
                        style: TextStyle(
                          color: _textSecondary,
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        riwayat.tanggal,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _levelBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7, height: 7,
                        decoration: BoxDecoration(
                          color: _levelColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Risiko ${riwayat.levelRisiko}',
                        style: TextStyle(
                          color: _levelColor,
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFCCCCCC),
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Skor Risiko',
                  style: TextStyle(
                    color: _textSecondary,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                  ),
                ),
                Text(
                  '${riwayat.skor} / ${riwayat.skorMax}',
                  style: TextStyle(
                    color: _levelColor,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                backgroundColor: const Color(0xFFF0F0F0),
                valueColor: AlwaysStoppedAnimation<Color>(_levelColor),
              ),
            ),
            if (delta != null) ...[
              const SizedBox(height: 10),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              const SizedBox(height: 10),
              _buildDeltaRow(delta, hari),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                _infoChip(Icons.location_on_outlined, riwayat.kabupaten),
                if (riwayat.noTelp != '-') ...[
                  const SizedBox(width: 10),
                  _infoChip(Icons.phone_outlined, riwayat.noTelp),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeltaRow(int delta, int? hari) {
    final bool membaik  = delta < 0;
    final bool stabil   = delta == 0;
    final Color color   = membaik
        ? const Color(0xFF2E7D32)
        : stabil
            ? const Color(0xFFF59E0B)
            : const Color(0xFFD32F2F);
    final IconData icon = membaik
        ? Icons.trending_down_rounded
        : stabil
            ? Icons.trending_flat_rounded
            : Icons.trending_up_rounded;
    final String deltaStr = delta > 0 ? '+$delta' : '$delta';
    final String label    = membaik ? 'Membaik' : stabil ? 'Stabil' : 'Memburuk';

    return Row(
      children: [
        const Text(
          'vs skrining sebelumnya',
          style: TextStyle(
            color: _textSecondary,
            fontFamily: 'PlusJakartaSans',
            fontSize: 11,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Text(
                stabil ? 'Stabil' : '$deltaStr poin  ·  $label',
                style: TextStyle(
                  color: color,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (hari != null) ...[
          const SizedBox(width: 6),
          Text(
            '$hari hr',
            style: const TextStyle(
              color: _textSecondary,
              fontFamily: 'PlusJakartaSans',
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: _textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: _textSecondary,
            fontFamily: 'PlusJakartaSans',
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
