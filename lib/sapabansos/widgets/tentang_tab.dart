import 'package:flutter/material.dart';

class TentangTab extends StatelessWidget {
  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);

  const TentangTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildInfoCard(
          iconPath: 'assets/images/icon_info.png',
          title: 'Tentang SAPA BANSOS',
          subtitle: 'Lebih tahu tentang SAPA BANSOS',
          content: 'Sapa Bansos, kepanjangan dari Sistem Aplikasi Pelayanan dan Aduan Bantuan Sosial. Dia merupakan sistem aplikasi untuk pengecekan bantuan sosial berdasarkan Nomor Induk Kependudukan (NIK).',
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          iconPath: 'assets/images/icon_storage.png',
          title: 'Sumber Data',
          subtitle: 'Sumber Data SAPA BANSOS',
          content: 'SAPA BANSOS menggunakan data yang bersumber dari Dinas Sosial Provinsi Jawa Timur.',
          useExtraContent: true,
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String iconPath,
    required String title,
    required String subtitle,
    required String content,
    bool useExtraContent = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color.fromRGBO(0, 101, 255, 0.1),
                child: Image.asset(iconPath, width: 20, height: 20, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: _blue, size: 20)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _textSecondary,
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              content,
              style: const TextStyle(
                color: Color.fromRGBO(70, 70, 70, 1),
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          if (useExtraContent) ...[
             const SizedBox(height: 16),
             Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lorem ipsum',
                     style: TextStyle(
                      color: Color.fromRGBO(70, 70, 70, 1),
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildMiniBadge('meong'),
                      const SizedBox(width: 16),
                      _buildMiniBadge('meong'),
                      const SizedBox(width: 16),
                      _buildMiniBadge('meong'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniBadge(String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 12,
          decoration: BoxDecoration(
            color: _blue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Color.fromRGBO(70, 70, 70, 1),
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
