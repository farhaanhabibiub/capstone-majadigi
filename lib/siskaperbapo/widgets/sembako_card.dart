import 'package:flutter/material.dart';
import '../models/sembako_model.dart';

class SembakoCard extends StatelessWidget {
  final SembakoItem item;
  final VoidCallback onTap;
  final String Function(int) formatRupiah;

  const SembakoCard({
    Key? key,
    required this.item,
    required this.onTap,
    required this.formatRupiah,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(0, 101, 255, 0.1),
              ),
              clipBehavior: Clip.hardEdge,
              child: Image.asset(
                item.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => const Icon(Icons.food_bank_outlined, color: Color.fromRGBO(0, 101, 255, 1)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(
                  color: Color.fromRGBO(32, 32, 32, 1),
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${formatRupiah(item.price)} / kg',
              style: const TextStyle(
                color: Color.fromRGBO(32, 32, 32, 1),
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            _buildMiniBadge(item.status),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniBadge(int status) {
    Color bgColor;
    Color iconColor;
    IconData iconData;

    if (status == 1) {
      bgColor = const Color(0xFFE52B44);
      iconColor = Colors.white;
      iconData = Icons.keyboard_arrow_up;
    } else if (status == -1) {
      bgColor = const Color(0xFF12B366);
      iconColor = Colors.white;
      iconData = Icons.keyboard_arrow_down;
    } else {
      bgColor = Colors.grey;
      iconColor = Colors.white;
      iconData = Icons.remove;
    }

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor, size: 14),
    );
  }
}
