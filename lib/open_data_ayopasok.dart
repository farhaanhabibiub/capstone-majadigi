import 'package:flutter/material.dart';

class OpenDataAyoPasokPage extends StatelessWidget {
  const OpenDataAyoPasokPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Blue Header
          Container(
            width: double.infinity,
            height: 120,
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
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Cari Data',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontFamily: 'PlusJakartaSans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // To balance the back button
                  ],
                ),
              ),
            ),
          ),
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ayo pasok bahan panganmu!!',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildMetaInfo(Icons.calendar_today, '07 Oktober 2021'),
                      const SizedBox(width: 16),
                      _buildMetaInfo(Icons.book, 'Ekonomi'),
                      const SizedBox(width: 16),
                      _buildMetaInfo(Icons.filter_list, 'Infografis'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/ayopasok.png',
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaInfo(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black87),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'PlusJakartaSans',
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}