import 'package:flutter/material.dart';
import '../data/sapabansos_dummy_data.dart';

class PenerimaTab extends StatefulWidget {
  const PenerimaTab({Key? key}) : super(key: key);

  @override
  State<PenerimaTab> createState() => _PenerimaTabState();
}

class _PenerimaTabState extends State<PenerimaTab> {
  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);

  int _searchStatus = 0; // 0: initial, 1: found, 2: not found
  final TextEditingController _nikController = TextEditingController();

  @override
  void dispose() {
    _nikController.dispose();
    super.dispose();
  }

  void _searchData() {
    FocusScope.of(context).unfocus();
    String nik = _nikController.text.trim();
    if (nik.isEmpty) {
      setState(() => _searchStatus = 0);
      return;
    }
    
    // Dummy condition based on prompt
    if (nik == '3511172108790002') {
      setState(() => _searchStatus = 1);
    } else {
      setState(() => _searchStatus = 2);
    }
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
            'Masukkan NIK untuk mengetahui informasi penerimaan\nsecara akurat dan cepat',
            style: TextStyle(
              color: _textSecondary,
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _blue, width: 1.5),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _nikController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                color: _blue,
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Masukkan NIK',
                hintStyle: TextStyle(
                  color: Color(0xFFBDBDBD),
                  fontFamily: 'PlusJakartaSans',
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _searchData,
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.search, color: Colors.white, size: 18),
              label: const Text(
                'Cari data',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (_searchStatus != 0) ...[
            const SizedBox(height: 24),
            Container(
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
                  if (_searchStatus == 1) ...[
                     _buildInfoRow('NIK', SapaBansosDummyData.validPenerima.nik),
                     _buildInfoRow('Nama', SapaBansosDummyData.validPenerima.nama),
                     _buildInfoRow('Kabupaten', SapaBansosDummyData.validPenerima.kabupaten),
                     _buildInfoRow('Kecamatan', SapaBansosDummyData.validPenerima.kecamatan),
                     _buildInfoRow('Kelurahan', SapaBansosDummyData.validPenerima.kelurahan),
                     _buildInfoRow('Program', SapaBansosDummyData.validPenerima.program),
                  ] else ...[
                     Row(
                       children: const [
                         Icon(Icons.error, color: Color(0xFFE52B44), size: 20),
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
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
