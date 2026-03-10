import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:majadigi/splash_screen.dart';  // Pastikan mengimpor SplashScreen Anda

void main() {
  testWidgets('SplashScreen displays the correct elements', (WidgetTester tester) async {
    // Build the SplashScreen widget
    await tester.pumpWidget(MaterialApp(home: SplashScreen()));

    // Verify if the specific texts are present
    expect(find.text('Didukung oleh'), findsOneWidget);  // Memeriksa apakah "Didukung oleh" ada
    expect(find.text('Pemerintah Provinsi Jawa Timur'), findsOneWidget);  // Memeriksa apakah "Pemerintah Provinsi Jawa Timur" ada

    // Verify if images are present
    expect(find.byType(Image), findsOneWidget);  // Memeriksa apakah ada widget Image yang ditampilkan

    // Verify if the container is visible
    expect(find.byType(Container), findsWidgets);  // Memeriksa apakah ada widget Container
  });
}