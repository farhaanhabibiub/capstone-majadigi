import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TentangTab extends StatelessWidget {
  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);

  const TentangTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTentangCard(),
        const SizedBox(height: 16),
        _buildCaraGunakanCard(),
        const SizedBox(height: 16),
        _buildSumberDataCard(),
        const SizedBox(height: 16),
        _buildKontakCard(),
      ],
    );
  }

  // ── 1. Tentang ────────────────────────────────────────────────────────────────
  Widget _buildTentangCard() {
    return _card(
      icon: Icons.info_outline_rounded,
      title: 'Tentang E-TIBI',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _paragraph(
            'E-TIBI (Elektronik Tuberkulosis Identifikasi) adalah aplikasi skrining mandiri TBC yang dikembangkan oleh Dinas Kesehatan Provinsi Jawa Timur untuk memudahkan masyarakat dan tenaga kesehatan mendeteksi risiko Tuberkulosis secara cepat dan akurat.',
          ),
          const SizedBox(height: 12),
          _paragraph(
            'Tuberkulosis (TBC) adalah penyakit menular serius yang disebabkan bakteri Mycobacterium tuberculosis. Deteksi dini adalah kunci keberhasilan pengobatan dan pencegahan penularan.',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _badgeInfo(Icons.speed_outlined, 'Cepat & Mudah'),
              const SizedBox(width: 10),
              _badgeInfo(Icons.science_outlined, 'Berbasis Klinis'),
              const SizedBox(width: 10),
              _badgeInfo(Icons.lock_outline, 'Privasi Aman'),
            ],
          ),
        ],
      ),
    );
  }

  // ── 2. Cara Menggunakan ───────────────────────────────────────────────────────
  Widget _buildCaraGunakanCard() {
    final steps = [
      (
        'Isi Identitas',
        'Lengkapi nama, NIK, jenis kelamin, tahun lahir, berat dan tinggi badan.',
      ),
      (
        'Isi Data Domisili',
        'Masukkan alamat, pekerjaan, dan kabupaten/kota tempat tinggal Anda.',
      ),
      (
        'Jawab 23 Pertanyaan Skrining',
        'Jawab setiap pertanyaan sesuai kondisi yang Anda rasakan dengan jujur. Terdiri dari gejala klinis, riwayat kontak, dan faktor risiko.',
      ),
      (
        'Lihat Hasil & Rekomendasi',
        'Sistem akan menghitung skor risiko dan menampilkan level risiko (Rendah/Sedang/Tinggi) beserta rekomendasi tindakan yang perlu diambil.',
      ),
    ];

    return _card(
      icon: Icons.help_outline_rounded,
      title: 'Cara Menggunakan',
      child: Column(
        children: List.generate(steps.length, (i) {
          final (judul, deskripsi) = steps[i];
          final isLast = i == steps.length - 1;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(color: _blue, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (!isLast) Container(width: 2, height: 44, color: const Color(0xFFE0E0E0)),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(judul,
                          style: const TextStyle(
                              color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text(deskripsi,
                          style: const TextStyle(
                              color: _textSecondary, fontFamily: 'PlusJakartaSans', fontSize: 12, height: 1.5)),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ── 3. Sumber Data ────────────────────────────────────────────────────────────
  Widget _buildSumberDataCard() {
    return _card(
      icon: Icons.storage_outlined,
      title: 'Sumber Data & Metode',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _paragraph(
            'Sistem skrining E-TIBI menggunakan algoritma skor berbobot yang dikembangkan berdasarkan panduan klinis TBC dari WHO dan Kementerian Kesehatan RI.',
          ),
          const SizedBox(height: 14),
          _infoRow(Icons.account_balance_outlined, 'Pengembang', 'Dinkes Provinsi Jawa Timur'),
          const SizedBox(height: 8),
          _infoRow(Icons.medical_information_outlined, 'Dasar panduan', 'Pedoman Nasional TBC Kemenkes RI'),
          const SizedBox(height: 8),
          _infoRow(Icons.quiz_outlined, 'Jumlah pertanyaan', '23 pertanyaan (4 kategori)'),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFCC02)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hasil skrining ini bersifat indikatif dan BUKAN pengganti diagnosis medis. Konfirmasi hanya dapat dilakukan oleh tenaga kesehatan melalui pemeriksaan klinis dan laboratorium.',
                    style: TextStyle(
                        color: Color(0xFF78350F), fontFamily: 'PlusJakartaSans', fontSize: 11, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 4. Kontak ─────────────────────────────────────────────────────────────────
  Widget _buildKontakCard() {
    return _card(
      icon: Icons.contact_support_outlined,
      title: 'Kontak & Informasi Lanjutan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _paragraph(
            'Untuk informasi lebih lanjut tentang TBC, konsultasi, atau melaporkan hasil skrining, hubungi:',
          ),
          const SizedBox(height: 14),
          _kontakItem(
            icon: Icons.phone_outlined,
            label: 'Hotline Dinkes Jatim',
            value: '(031) 8280748',
            onTap: () => _launchUrl('tel:+62318280748'),
          ),
          const SizedBox(height: 10),
          _kontakItem(
            icon: Icons.language_outlined,
            label: 'Website Resmi',
            value: 'dinkes.jatimprov.go.id',
            onTap: () => _launchUrl('https://dinkes.jatimprov.go.id'),
          ),
          const SizedBox(height: 10),
          _kontakItem(
            icon: Icons.email_outlined,
            label: 'Email',
            value: 'dinkes@jatimprov.go.id',
            onTap: () => _launchUrl('mailto:dinkes@jatimprov.go.id'),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _launchUrl('https://dinkes.jatimprov.go.id'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _blue),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.open_in_new, color: _blue, size: 16),
              label: const Text(
                'Kunjungi Portal Dinkes Jatim',
                style: TextStyle(color: _blue, fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────
  Widget _card({required IconData icon, required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(0, 101, 255, 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: _blue, size: 22),
              ),
              const SizedBox(width: 12),
              Text(title,
                  style: const TextStyle(
                      color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _paragraph(String text) => Text(
        text,
        style: const TextStyle(
            color: Color.fromRGBO(70, 70, 70, 1), fontFamily: 'PlusJakartaSans', fontSize: 13, height: 1.6),
        textAlign: TextAlign.justify,
      );

  Widget _badgeInfo(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(0, 101, 255, 0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: _blue, size: 18),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    color: _blue, fontFamily: 'PlusJakartaSans', fontSize: 10, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: _blue, size: 16),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(color: _textSecondary, fontFamily: 'PlusJakartaSans', fontSize: 12)),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _kontakItem({required IconData icon, required String label, required String value, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Icon(icon, color: _blue, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(color: _textSecondary, fontFamily: 'PlusJakartaSans', fontSize: 11)),
                  Text(value,
                      style: const TextStyle(
                          color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC), size: 18),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}
