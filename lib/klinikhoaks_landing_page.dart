import 'dart:ui';
import 'package:flutter/material.dart';

class KlinikHoaksLandingPage extends StatefulWidget {
  const KlinikHoaksLandingPage({super.key});

  @override
  State<KlinikHoaksLandingPage> createState() => _KlinikHoaksLandingPageState();
}

class _KlinikHoaksLandingPageState extends State<KlinikHoaksLandingPage> {
  final TextEditingController _topikController = TextEditingController();
  final TextEditingController _isiController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  String? _fileName;

  @override
  void dispose() {
    _topikController.dispose();
    _isiController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isFormFilled = _topikController.text.isNotEmpty && 
                        _isiController.text.isNotEmpty && 
                        _linkController.text.isNotEmpty && 
                        _fileName != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Header Background
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
                // Header Bar
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
                          'Permohonan Klarifikasi',
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
                // Form Area
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
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Topik'),
                            _buildTextField(
                              controller: _topikController,
                              hint: 'Isi topik laporan',
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 20),
                            _buildLabel('Isi Laporan'),
                            _buildTextField(
                              controller: _isiController,
                              hint: 'Isi laporan',
                              maxLines: 5,
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 20),
                            _buildLabel('Link Bukti/Alamat Website'),
                            _buildTextField(
                              controller: _linkController,
                              hint: '12345',
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 20),
                            _buildLabel('Bukti File'),
                            if (_fileName != null)
                              _buildSelectedFileCard(),
                            _buildFileUploadButton(),
                            const SizedBox(height: 40),
                            _buildSubmitButton(isFormFilled),
                            const SizedBox(height: 20),
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

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'PlusJakartaSans',
          color: Color(0xFF1F2937),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onChanged: onChanged,
        style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontFamily: 'PlusJakartaSans'),
          contentPadding: const EdgeInsets.all(18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF007AFF), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedFileCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF007AFF), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.description, color: Color(0xFF007AFF), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _fileName!,
              style: const TextStyle(
                color: Color(0xFF007AFF),
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _fileName = null),
            child: const Icon(Icons.close, color: Colors.grey, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildFileUploadButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _fileName = 'SS_Web_Phishing.jpg';
        });
      },
      child: CustomPaint(
        painter: DashPainter(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              _fileName == null ? 'Pilih File' : 'Tambah File',
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w400,
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isFilled) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: isFilled ? () {} : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFilled ? const Color(0xFF007AFF) : const Color(0xFFD1D5DB),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: Text(
          'Ajukan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'PlusJakartaSans',
            color: isFilled ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }
}

class DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 5, dashSpace = 3;
    final paint = Paint()
      ..color = const Color(0xFF9CA3AF)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromLTRBR(
      0, 0, size.width, size.height,
      const Radius.circular(30),
    );

    final Path path = Path()..addRRect(rrect);
    
    for (PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0;
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
