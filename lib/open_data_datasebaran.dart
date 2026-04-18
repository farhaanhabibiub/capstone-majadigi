import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Header Background (Matched with OpenDataLandingPage)
          Container(
            width: double.infinity,
            height: 250,
            decoration: const BoxDecoration(
              color: Color(0xFF007AFF),
              image: DecorationImage(
                image: AssetImage('assets/images/header_texture.png'),
                fit: BoxFit.cover,
                opacity: 0.6,
              ),
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
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                          'Cari Data',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontFamily: 'PlusJakartaSans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Content Area
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Data Sebaran UMKM Berdasarkan Sektor Per Kecamatan Tahun 2025',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'PlusJakartaSans',
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildMetaInfo(Icons.calendar_today_outlined, '07 Oktober 2021'),
                                const SizedBox(width: 16),
                                _buildMetaInfo(Icons.business_outlined, 'Ekonomi'),
                                const SizedBox(width: 16),
                                _buildMetaInfo(Icons.filter_list, 'Dataset'),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Deskripsi Dataset Card
                            _buildExpandableCard(
                              title: 'Deskripsi Dataset',
                              isExpanded: _isDeskripsiExpanded,
                              onTap: () => setState(() => _isDeskripsiExpanded = !_isDeskripsiExpanded),
                              content: _buildDeskripsiContent(),
                            ),
                            const SizedBox(height: 16),
                            // Informasi Metadata Card
                            _buildExpandableCard(
                              title: 'Informasi Metadata',
                              isExpanded: _isMetadataExpanded,
                              onTap: () => setState(() => _isMetadataExpanded = !_isMetadataExpanded),
                              content: _buildMetadataContent(),
                            ),
                            const SizedBox(height: 16),
                            // Periode Update Card
                            _buildExpandableCard(
                              title: 'Periode Update',
                              isExpanded: _isPeriodeExpanded,
                              onTap: () => setState(() => _isPeriodeExpanded = !_isPeriodeExpanded),
                              content: _buildPeriodeContent(),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
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

  Widget _buildMetaInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black87),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
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
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: onTap,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF5FF),
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
            fontSize: 14,
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
            _buildMetadataRow('Dataset diperbarui', '31 Maret 2026'),
            _buildMetadataRow('Dataset dibuat', '10 Januari 2025'),
            _buildMetadataRow('Pengukuran dataset', 'DATA SEBARAN UMKM BERDASARKAN SEKTOR PER KECAMATAN Tingkat Penyajian PEMERINTAH KABUPATEN MAJALENGKA'),
            _buildMetadataRow('Cakupan dataset', 'DATA SEBARAN UMKM BERDASARKAN SEKTOR PER KECAMATAN'),
            _buildMetadataRow('Produsen', 'Dinas Koperasi dan UKM Kabupaten Majalengka'),
            _buildMetadataRow('Kontak produsen', '0233 281XXX — diskopukm@majalengkakab.go.id'),
            _buildMetadataRow('Satuan dataset', 'Unit Usaha'),
            _buildMetadataRow('Frekuensi Dataset', 'Tahunan'),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'PlusJakartaSans',
            color: Color(0xFF1F2937),
            height: 1.5,
          ),
          children: [
            TextSpan(text: '$key : ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value, style: const TextStyle(color: Color(0xFF4B5563))),
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
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Text(
        year,
        style: const TextStyle(
          fontSize: 16,
          fontFamily: 'PlusJakartaSans',
          fontWeight: FontWeight.w500,
          color: Color(0xFF1F2937),
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
              border: Border.all(color: _is2025Expanded ? const Color(0xFF007AFF) : Colors.grey.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  year,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2937),
                  ),
                ),
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
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Preview Dataset',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'PlusJakartaSans',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDatasetTable(),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Unduh Dataset',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'PlusJakartaSans',
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildDatasetTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
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
          // Table Body
          _buildTableRow('Majalengka', '1250', '450', '120', fashionColor: const Color(0xFFDC2626), craftColor: const Color(0xFF2563EB)),
          _buildTableRow('Jatiwangi', '890', '320', '560', fashionColor: const Color(0xFFDC2626), craftColor: const Color(0xFF2563EB)),
          _buildTableRow('Kadipaten', '1100', '510', '95', fashionColor: const Color(0xFFDC2626), craftColor: const Color(0xFF2563EB)),
          _buildTableRow('Cigasong', '750', '280', '150', fashionColor: const Color(0xFFDC2626), craftColor: const Color(0xFF2563EB)),
          
          // Table Footer
          InkWell(
            onTap: () {},
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
              ),
              child: const Text(
                'Lihat Selengkapnya',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'PlusJakartaSans',
                  color: Color(0xFF007AFF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(String kecamatan, String kuliner, String fashion, String kerajinan, {Color? fashionColor, Color? craftColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(kecamatan, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)))),
          Expanded(flex: 2, child: Text(kuliner, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)))),
          Expanded(flex: 2, child: Text(fashion, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: fashionColor ?? const Color(0xFF1F2937)))),
          Expanded(flex: 2, child: Text(kerajinan, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: craftColor ?? const Color(0xFF1F2937)))),
        ],
      ),
    );
  }
}
