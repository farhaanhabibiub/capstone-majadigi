import 'package:flutter/material.dart';

class IndicatorBadge extends StatelessWidget {
  final int status;
  final String statusText;

  const IndicatorBadge({Key? key, required this.status, required this.statusText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color accentColor;
    IconData iconData;

    if (status == 1) {
      bgColor = const Color(0xFFFAE7E9);
      accentColor = const Color(0xFFE52B44);
      iconData = Icons.keyboard_arrow_up;
    } else if (status == -1) {
      bgColor = const Color(0xFFE6F8F0);
      accentColor = const Color(0xFF12B366);
      iconData = Icons.keyboard_arrow_down;
    } else {
      bgColor = Colors.grey.shade200;
      accentColor = Colors.grey.shade700;
      iconData = Icons.remove;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            statusText,
            style: TextStyle(
              color: accentColor,
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: Colors.white, size: 10),
          ),
        ],
      ),
    );
  }
}
