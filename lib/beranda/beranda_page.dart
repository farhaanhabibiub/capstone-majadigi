import 'package:flutter/material.dart';

class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _whiteBg = Color.fromRGBO(248, 248, 245, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _whiteBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _whiteBg,
        centerTitle: false,
        title: const Text(
          'Beranda',
          style: TextStyle(
            color: _textPrimary,
            fontFamily: 'PlusJakartaSans',
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dummy Beranda',
              style: TextStyle(
                color: _textPrimary,
                fontFamily: 'PlusJakartaSans',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Halaman ini masih sementara. Nanti di sini akan ditampilkan rekomendasi 3 fitur utama untuk pengguna.',
              style: TextStyle(
                color: _textSecondary,
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color.fromRGBO(225, 225, 225, 1),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rekomendasi Fitur',
                    style: TextStyle(
                      color: _textPrimary,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10),
                  _DummyFeatureTile(title: 'Fitur 1'),
                  SizedBox(height: 10),
                  _DummyFeatureTile(title: 'Fitur 2'),
                  SizedBox(height: 10),
                  _DummyFeatureTile(title: 'Fitur 3'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DummyFeatureTile extends StatelessWidget {
  final String title;

  const _DummyFeatureTile({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(248, 248, 245, 1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color.fromRGBO(0, 101, 255, 0.12),
            child: Icon(
              Icons.apps_rounded,
              color: Color.fromRGBO(0, 101, 255, 1),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color.fromRGBO(32, 32, 32, 1),
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}