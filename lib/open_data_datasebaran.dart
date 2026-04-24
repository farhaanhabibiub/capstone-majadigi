import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenDataDataSebaranPage extends StatefulWidget {
  const OpenDataDataSebaranPage({super.key});

  @override
  State<OpenDataDataSebaranPage> createState() => _OpenDataDataSebaranPageState();
}

class _OpenDataDataSebaranPageState extends State<OpenDataDataSebaranPage> {
  bool _isDeskripsiExpanded = true;
  bool _isMetadataExpanded = true;
  bool _isPeriodeExpanded = true;
  bool _is2025Expanded = true;
  bool _showAllRows = false;

  static const _allKecamatan = <Map<String, dynamic>>[
    {'nama': 'Majalengka', 'kuliner': '1.250', 'fashion': '450', 'kerajinan': '120'},
    {'nama': 'Jatiwangi', 'kuliner': '890', 'fashion': '320', 'kerajinan': '560'},
    {'nama': 'Kadipaten', 'kuliner': '1.100', 'fashion': '510', 'kerajinan': '95'},
    {'nama': 'Cigasong', 'kuliner': '750', 'fashion': '280', 'kerajinan': '150'},
    {'nama': 'Dawuan', 'kuliner': '630', 'fashion': '195', 'kerajinan': '88'},
    {'nama': 'Kasokandel', 'kuliner': '540', 'fashion': '170', 'kerajinan': '63'},
    {'nama': 'Sukahaji', 'kuliner': '480', 'fashion': '145', 'kerajinan': '74'},
    {'nama': 'Sindangwangi', 'kuliner': '420', 'fashion': '130', 'kerajinan': '91'},
    {'nama': 'Leuwimunding', 'kuliner': '395', 'fashion': '120', 'kerajinan': '55'},
    {'nama': 'Palasah', 'kuliner': '360', 'fashion': '108', 'kerajinan': '47'},
    {'nama': 'Rajagaluh', 'kuliner': '510', 'fashion': '185', 'kerajinan': '210'},
    {'nama': 'Sindang', 'kuliner': '330', 'fashion': '98', 'kerajinan': '42'},
    {'nama': 'Panyingkiran', 'kuliner': '310', 'fashion': '92', 'kerajinan': '38'},
    {'nama': 'Ligung', 'kuliner': '580', 'fashion': '210', 'kerajinan': '120'},
    {'nama': 'Kertajati', 'kuliner': '470', 'fashion': '160', 'kerajinan': '85'},
    {'nama': 'Jatitujuh', 'kuliner': '290', 'fashion': '85', 'kerajinan': '32'},
    {'nama': 'Lemahsugih', 'kuliner': '260', 'fashion': '75', 'kerajinan': '95'},
    {'nama': 'Malausma', 'kuliner': '215', 'fashion': '62', 'kerajinan': '78'},
    {'nama': 'Banjaran', 'kuliner': '380', 'fashion': '115', 'kerajinan': '140'},
    {'nama': 'Cingambul', 'kuliner': '245', 'fashion': '70', 'kerajinan': '110'},
    {'nama': 'Talaga', 'kuliner': '440', 'fashion': '148', 'kerajinan': '165'},
    {'nama': 'Bantarujeg', 'kuliner': '200', 'fashion': '58', 'kerajinan': '85'},
    {'nama': 'Cikijing', 'kuliner': '320', 'fashion': '95', 'kerajinan': '120'},
    {'nama': 'Cikalong', 'kuliner': '175', 'fashion': '50', 'kerajinan': '62'},
    {'nama': 'Maja', 'kuliner': '560', 'fashion': '195', 'kerajinan': '105'},
    {'nama': 'Argapura', 'kuliner': '185', 'fashion': '54', 'kerajinan': '235'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 250,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF007AFF), Color(0xFF0062D1)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SizedBox(
                    height: 56,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const Text(
                          'Detail Data',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontFamily: 'PlusJakartaSans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Data Sebaran UMKM Berdasarkan Sektor Per Kecamatan Tahun 2025',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'PlusJakartaSans',
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 6,
                            children: [
                              _metaChip(Icons.calendar_today_outlined, '31 Maret 2025'),
                              _metaChip(Icons.business_outlined, 'Ekonomi'),
                              _metaChip(Icons.table_chart_outlined, 'Dataset'),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildExpandableCard(
                            title: 'Deskripsi Dataset',
                            isExpanded: _isDeskripsiExpanded,
                            onTap: () => setState(
                                () => _isDeskripsiExpanded = !_isDeskripsiExpanded),
                            content: _buildDeskripsiContent(),
                          ),
                          const SizedBox(height: 16),
                          _buildExpandableCard(
                            title: 'Informasi Metadata',
                            isExpanded: _isMetadataExpanded,
                            onTap: () => setState(
                                () => _isMetadataExpanded = !_isMetadataExpanded),
                            content: _buildMetadataContent(),
                          ),
                          const SizedBox(height: 16),
                          _buildExpandableCard(
                            title: 'Periode Update',
                            isExpanded: _isPeriodeExpanded,
                            onTap: () => setState(
                                () => _isPeriodeExpanded = !_isPeriodeExpanded),
                            content: _buildPeriodeContent(),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF6B7280)),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(
                fontSize: 12,
                fontFamily: 'PlusJakartaSans',
                color: Color(0xFF6B7280))),
      ],
    );
  }

  Widget _buildExpandableCard({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 15, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            onTap: onTap,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFFEBF5FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: const Color(0xFF007AFF),
                size: 20,
              ),
            ),
          ),
          if (isExpanded) content,
        ],
      ),
    );
  }

  Widget _buildDeskripsiContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Dataset ini berisi rincian jumlah unit Usaha Mikro, Kecil, dan Menengah (UMKM) yang tersebar di 26 kecamatan di Kabupaten Majalengka. Data dikelompokkan berdasarkan sektor usaha (Kuliner, Fashion, Kerajinan, Jasa, dll) untuk mempermudah pemetaan potensi ekonomi daerah.',
          style: TextStyle(
            fontSize: 13,
            fontFamily: 'PlusJakartaSans',
            color: Color(0xFF4B5563),
            height: 1.6,
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _metaRow('Dataset diperbarui', '31 Maret 2025'),
            _metaRow('Dataset dibuat', '10 Januari 2025'),
            _metaRow('Cakupan dataset', 'Seluruh kecamatan di Kabupaten Majalengka'),
            _metaRow('Produsen', 'Dinas Koperasi dan UKM Kabupaten Majalengka'),
            _metaRow('Kontak produsen', '0233-281XXX — diskopukm@majalengkakab.go.id'),
            _metaRow('Satuan dataset', 'Unit Usaha'),
            _metaRow('Frekuensi Update', 'Tahunan'),
          ],
        ),
      ),
    );
  }

  Widget _metaRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'PlusJakartaSans',
            color: Color(0xFF1F2937),
            height: 1.5,
          ),
          children: [
            TextSpan(
                text: '$key: ',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
                text: value,
                style: const TextStyle(color: Color(0xFF4B5563))),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodeContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          _buildYearItem('2026'),
          const SizedBox(height: 12),
          _buildYearExpandableItem('2025'),
        ],
      ),
    );
  }

  Widget _buildYearItem(String year) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Text(
        '$year — Data sedang dipersiapkan',
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'PlusJakartaSans',
          fontWeight: FontWeight.w500,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _buildYearExpandableItem(String year) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _is2025Expanded = !_is2025Expanded),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _is2025Expanded
                    ? const Color(0xFF007AFF)
                    : Colors.grey.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Text(
                  year,
                  style: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                Icon(
                  _is2025Expanded ? Icons.expand_less : Icons.expand_more,
                  color: const Color(0xFF4B5563),
                ),
              ],
            ),
          ),
        ),
        if (_is2025Expanded) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Preview Dataset',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'PlusJakartaSans',
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '26 kecamatan • 3 sektor ditampilkan',
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'PlusJakartaSans',
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDatasetTable(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _downloadDataset,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.download_outlined, color: Colors.white, size: 20),
              label: const Text(
                'Unduh Dataset',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'PlusJakartaSans',
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDatasetTable() {
    final displayRows =
        _showAllRows ? _allKecamatan : _allKecamatan.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('KECAMATAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                Expanded(flex: 2, child: Text('KULINER', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                Expanded(flex: 2, child: Text('FASHION', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                Expanded(flex: 2, child: Text('KERAJINAN', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
              ],
            ),
          ),
          // Rows
          ...displayRows.map((row) => _buildTableRow(
                row['nama'] as String,
                row['kuliner'] as String,
                row['fashion'] as String,
                row['kerajinan'] as String,
              )),
          // Toggle footer
          InkWell(
            onTap: () => setState(() => _showAllRows = !_showAllRows),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _showAllRows
                        ? 'Tutup'
                        : 'Lihat Semua ${_allKecamatan.length} Kecamatan',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'PlusJakartaSans',
                      color: Color(0xFF007AFF),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _showAllRows ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 16,
                    color: const Color(0xFF007AFF),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(
      String kecamatan, String kuliner, String fashion, String kerajinan) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(color: Colors.grey.withValues(alpha: 0.08))),
      ),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text(kecamatan,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'PlusJakartaSans',
                      color: Color(0xFF1F2937)))),
          Expanded(
              flex: 2,
              child: Text(kuliner,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'PlusJakartaSans',
                      color: Color(0xFF1F2937)))),
          Expanded(
              flex: 2,
              child: Text(fashion,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'PlusJakartaSans',
                      color: Color(0xFFDC2626)))),
          Expanded(
              flex: 2,
              child: Text(kerajinan,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'PlusJakartaSans',
                      color: Color(0xFF2563EB)))),
        ],
      ),
    );
  }

  Future<void> _downloadDataset() async {
    const url = 'https://opendata.jatimprov.go.id/';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka portal. Kunjungi opendata.jatimprov.go.id'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
