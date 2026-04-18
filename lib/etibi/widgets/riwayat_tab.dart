import 'package:flutter/material.dart';
import '../models/etibi_model.dart';

class RiwayatTab extends StatelessWidget {
  final List<RiwayatSkrining> riwayatList;

  const RiwayatTab({Key? key, required this.riwayatList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverPadding(
          padding: EdgeInsets.only(bottom: 16),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Riwayat Skrining',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color.fromRGBO(32, 32, 32, 1),
              ),
            ),
          ),
        ),
        SliverList.separated(
          itemCount: riwayatList.length,
          itemBuilder: (context, index) {
            return RiwayatCard(riwayat: riwayatList[index]);
          },
          separatorBuilder: (context, index) => const SizedBox(height: 16),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 24.0, bottom: 20),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color.fromRGBO(0, 101, 255, 1), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text('Lihat Lebih Banyak', style: TextStyle(color: Color.fromRGBO(0, 101, 255, 1), fontFamily: 'PlusJakartaSans', fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class RiwayatCard extends StatelessWidget {
  final RiwayatSkrining riwayat;
  
  const RiwayatCard({Key? key, required this.riwayat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isBad = riwayat.hasil == 'Terindikasi TBC';
    final Color badgeColor = isBad ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32);
    const Color textPrimary = Color.fromRGBO(32, 32, 32, 1);
    
    return Container(
      padding: const EdgeInsets.all(16),
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
         children: [
            _buildRow('Tanggal Skrining', riwayat.tanggal),
            Padding(
               padding: const EdgeInsets.only(bottom: 6),
               child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     const SizedBox(
                        width: 120,
                        child: Text('Hasil Skrining', style: TextStyle(color: textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 13)),
                     ),
                     const Text(' : ', style: TextStyle(color: textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 13)),
                     Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(12)),
                        child: Text(riwayat.hasil, style: const TextStyle(color: Colors.white, fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w600)),
                     )
                  ],
               ),
            ),
            _buildRow('Faskes Kunjungan', riwayat.faskes),
            _buildRow('Kabupaten/Kota', riwayat.kabupaten),
            _buildRow('Nomor Telepon', riwayat.noTelp),
         ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    const Color textPrimary = Color.fromRGBO(32, 32, 32, 1);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 13),
            ),
          ),
          const Text(
            ' : ',
            style: TextStyle(color: textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 13),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
