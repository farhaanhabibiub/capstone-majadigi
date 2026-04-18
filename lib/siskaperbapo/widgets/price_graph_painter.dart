import 'package:flutter/material.dart';

class PriceGraphPainter extends CustomPainter {
  final List<int> prices;
  final List<String> dates;
  final String Function(int) formatPrice;

  PriceGraphPainter({
    required this.prices,
    required this.dates,
    required this.formatPrice,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.isEmpty) return;

    final paintLine = Paint()
      ..color = const Color.fromRGBO(0, 101, 255, 1)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final paintAxis = Paint()
      ..color = Colors.grey.shade800
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final textStyle = const TextStyle(
      color: Color.fromRGBO(70, 70, 70, 1),
      fontSize: 12,
      fontFamily: 'PlusJakartaSans',
    );
    
    // Calculate dynamic range
    final int minPrice = prices.reduce((a, b) => a < b ? a : b) - 500;
    final int maxPrice = prices.reduce((a, b) => a > b ? a : b) + 500;
    final int range = maxPrice - minPrice;

    final double paddingLeft = 70.0; // Space for Y-axis text
    final double paddingBottom = 24.0; // Space for X-axis text
    final double graphWidth = size.width - paddingLeft;
    final double graphHeight = size.height - paddingBottom;

    // Draw Axes
    canvas.drawLine(Offset(paddingLeft, 0), Offset(paddingLeft, graphHeight), paintAxis);
    canvas.drawLine(Offset(paddingLeft, graphHeight), Offset(size.width, graphHeight), paintAxis);

    // Draw Y labels (Min, Mid, Max)
    final yLabels = [minPrice, minPrice + range ~/ 2, maxPrice];
    for (int i = 0; i < yLabels.length; i++) {
        final double y = graphHeight - ((yLabels[i] - minPrice) / range) * graphHeight;
        final TextSpan span = TextSpan(style: textStyle, text: formatPrice(yLabels[i]));
        final TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
        tp.layout();
        // Shift label slightly left and align vertically
        tp.paint(canvas, Offset(paddingLeft - tp.width - 8, y - tp.height / 2));
    }

    // Prepare line path
    final Path path = Path();

    // Draw X labels and the data line
    for (int i = 0; i < prices.length; i++) {
      // Space dots evenly across the graphWidth
      final double x = paddingLeft + (i / (prices.length > 1 ? prices.length - 1 : 1)) * graphWidth;
      final double y = graphHeight - ((prices[i] - minPrice) / range) * graphHeight;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      final TextSpan span = TextSpan(style: textStyle, text: dates[i]);
      final TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();
      // Center X label horizontally
      tp.paint(canvas, Offset(x - tp.width / 2, graphHeight + 8));
    }

    // Paint the actual line
    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
