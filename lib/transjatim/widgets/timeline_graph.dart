import 'package:flutter/material.dart';

class TimelineGraph extends StatelessWidget {
  final List<String> stops;

  const TimelineGraph({Key? key, required this.stops}) : super(key: key);

  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(stops.length, (index) {
        bool isLast = index == stops.length - 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Image.asset(
                  'assets/images/pin_lokasi.png',
                  width: 20,
                  height: 20,
                ),
                if (!isLast)
                  Container(
                    width: 1,
                    height: 30, // Minimal height between stops
                    color: _textPrimary, // Thin line between nodes
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  stops[index],
                  style: const TextStyle(
                    color: _textPrimary,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
