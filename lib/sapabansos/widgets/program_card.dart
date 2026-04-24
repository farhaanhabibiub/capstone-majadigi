import 'package:flutter/material.dart';
import '../models/sapabansos_model.dart';

class ProgramCard extends StatelessWidget {
  final BansosProgram program;
  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _green = Color(0xFF27AE60);
  static const Color _red = Color(0xFFE52B44);

  const ProgramCard({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                child: Image.asset(
                  program.iconPath,
                  width: 22,
                  height: 22,
                  errorBuilder: (c, e, s) => const Icon(Icons.volunteer_activism, color: _blue, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program.title,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(0, 101, 255, 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        program.kategori,
                        style: const TextStyle(
                          color: _blue,
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC), size: 20),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _miniStat('Penerima', program.kuota, _blue),
              const SizedBox(width: 8),
              _miniStat('Tersalur', program.tersalur, _green),
              const SizedBox(width: 8),
              _miniStat('Belum', program.belumTersalur, _red),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: program.progressValue,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFF0F0F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(_green),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                program.progressText,
                style: const TextStyle(
                  color: _textPrimary,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF999999),
                fontFamily: 'PlusJakartaSans',
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
