import 'package:flutter/material.dart';
import '../models/sapabansos_model.dart';

class ProgramCard extends StatelessWidget {
  final BansosProgram program;
  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);

  const ProgramCard({Key? key, required this.program}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                child: Image.asset(program.iconPath, width: 24, height: 24, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: _blue, size: 24)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  program.title,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            program.description,
            style: const TextStyle(
              color: Color.fromRGBO(70, 70, 70, 1),
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nilai Penyaluran',
                        style: TextStyle(color: _textPrimary, fontSize: 12, fontFamily: 'PlusJakartaSans'),
                      ),
                      Text(
                        program.nilai,
                        style: const TextStyle(color: _textPrimary, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'PlusJakartaSans'),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Kuota',
                        style: TextStyle(color: _textPrimary, fontSize: 12, fontFamily: 'PlusJakartaSans'),
                      ),
                      Text(
                        program.kuota,
                        style: const TextStyle(color: _textPrimary, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'PlusJakartaSans'),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tersalur',
                        style: TextStyle(color: _textPrimary, fontSize: 12, fontFamily: 'PlusJakartaSans'),
                      ),
                      Text(
                        program.tersalur,
                        style: const TextStyle(color: _textPrimary, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'PlusJakartaSans'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        program.progressText,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _blue, width: 1.5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: program.progressValue,
                            backgroundColor: Colors.white,
                            valueColor: const AlwaysStoppedAnimation<Color>(_blue),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
