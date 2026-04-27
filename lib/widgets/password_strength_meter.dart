import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Indikator visual kekuatan password (0–4 segmen).
///
/// Skor dihitung dari 4 kriteria:
///  • panjang ≥ 8
///  • mengandung huruf besar & kecil
///  • mengandung angka
///  • mengandung simbol
///
/// Sembunyi otomatis bila [password] kosong.
class PasswordStrengthMeter extends StatelessWidget {
  final String password;

  const PasswordStrengthMeter({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final score = _scorePassword(password);
    final label = _labelFor(score);
    final color = _colorFor(score);

    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(4, (i) {
              final filled = i < score;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: filled ? color : const Color(0xFFE3E5EA),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          Text(
            'Kekuatan: $label',
            style: TextStyle(
              color: color,
              fontFamily: AppTheme.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static int _scorePassword(String pwd) {
    int score = 0;
    if (pwd.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(pwd) && RegExp(r'[a-z]').hasMatch(pwd)) {
      score++;
    }
    if (RegExp(r'\d').hasMatch(pwd)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\/~`]').hasMatch(pwd)) score++;
    return score;
  }

  static String _labelFor(int score) {
    switch (score) {
      case 0:
      case 1:
        return 'Lemah';
      case 2:
        return 'Sedang';
      case 3:
        return 'Kuat';
      default:
        return 'Sangat Kuat';
    }
  }

  static Color _colorFor(int score) {
    switch (score) {
      case 0:
      case 1:
        return AppTheme.danger;
      case 2:
        return AppTheme.warning;
      case 3:
        return const Color(0xFF22A050);
      default:
        return const Color(0xFF1F8B43);
    }
  }
}
