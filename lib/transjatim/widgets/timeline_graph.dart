import 'package:flutter/material.dart';
import '../models/transjatim_model.dart';

class TimelineGraph extends StatelessWidget {
  final List<TransjatimStop> stops;

  const TimelineGraph({Key? key, required this.stops}) : super(key: key);

  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(stops.length, (index) {
        final isLast = index == stops.length - 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                const Icon(Icons.location_on_rounded, size: 20, color: Color.fromRGBO(0, 101, 255, 1)),
                if (!isLast)
                  Container(width: 1, height: 30, color: _textPrimary),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  stops[index].name,
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
