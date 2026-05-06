import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:majadigi/widgets/empty_state.dart';
import 'package:majadigi/widgets/error_retry.dart';

void main() {
  group('Reusable widgets smoke tests', () {
    testWidgets('EmptyState renders title, subtitle, and action', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox_outlined,
              title: 'Belum ada data',
              subtitle: 'Tambahkan data pertama Anda.',
              actionLabel: 'Tambah',
              onAction: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Belum ada data'), findsOneWidget);
      expect(find.text('Tambahkan data pertama Anda.'), findsOneWidget);
      expect(find.text('Tambah'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);

      await tester.tap(find.text('Tambah'));
      expect(tapped, isTrue);
    });

    testWidgets('ErrorRetry calls onRetry when retry button tapped',
        (tester) async {
      var retries = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorRetry(
              title: 'Gagal memuat',
              subtitle: 'Periksa koneksi internet Anda.',
              onRetry: () => retries++,
            ),
          ),
        ),
      );

      expect(find.text('Gagal memuat'), findsOneWidget);

      await tester.tap(find.text('Coba Lagi'));
      expect(retries, equals(1));
    });

    test('ErrorRetry.fromException maps known errors to friendly text', () {
      expect(
        ErrorRetry.fromException(Exception('SocketException: failed')),
        isNotEmpty,
      );
      expect(
        ErrorRetry.fromException('plain string error'),
        isNotEmpty,
      );
    });
  });
}
