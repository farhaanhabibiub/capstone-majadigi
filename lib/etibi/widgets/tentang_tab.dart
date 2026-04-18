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
        Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color.fromRGBO(0, 101, 255, 0.1),
                    child: Image.asset('assets/images/icon_info.png', width: 20, height: 20, errorBuilder: (c,e,s) => const Icon(Icons.info_outline, color: _blue, size: 20)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                         Text(
                          'Tentang E-TIBI',
                          style: TextStyle(color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 2),
                         Text(
                          'Lebih tahu tentang E-TIBI',
                          style: TextStyle(color: _textSecondary, fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w400),
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
                child: const Text(
                  'E-TIBI adalah Aplikasi skrining mandiri Tuberkulosis (TBC) berbasis website. Aplikasi yang dikembangkan oleh Dinas Kesehatan Provinsi Jawa Timur ini memudahkan tenaga kesehatan dan masyarakat untuk melakukan skrining Tuberkulosis secara mandiri. Setelah mengisi beberapa pertanyaan kurang dari semenit, pengguna bisa langsung mengetahui status pemeriksaan, yaitu terduga TBC atau tidak terduga TBC.',
                  style: TextStyle(
                    color: Color.fromRGBO(70, 70, 70, 1),
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
