import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Pastikan import ini mengarah ke file main.dart atau file SplashScreen kamu
import 'package:majadigi/splash_screen.dart';
void main() {
  testWidgets('SplashScreen displays the correct elements', (WidgetTester tester) async {
    // 1. Render/bangun UI SplashScreen di dalam memori testing
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    // 2. HAPUS ATAU KOMEN BARIS INI:
    // expect(find.text('Didukung oleh'), findsOneWidget);

    // 3. GANTI DENGAN MENCARI WIDGET IMAGE:
    expect(find.byType(Image), findsOneWidget);
  });
}