import 'package:flutter_test/flutter_test.dart';
import 'package:majadigi/beranda/service_registry.dart';

void main() {
  group('ServiceRegistry.findById', () {
    test('returns matching addable service', () {
      final s = ServiceRegistry.findById('sapa_bansos');
      expect(s, isNotNull);
      expect(s!.label, equals('SAPA BANSOS'));
    });

    test('returns null for unknown id', () {
      expect(ServiceRegistry.findById('does_not_exist'), isNull);
    });

    test('all 4 RSUD-specific entries carry a HospitalConfig', () {
      final rsudIds = [
        'rsud_daha_husada',
        'rsud_karsa_husada',
        'rsud_saiful_anwar',
        'rsud_prov_jatim',
      ];
      for (final id in rsudIds) {
        final s = ServiceRegistry.findById(id);
        expect(s, isNotNull, reason: '$id should exist');
        expect(s!.hospital, isNotNull, reason: '$id should have hospital config');
      }
    });
  });

  group('ServiceRegistry.metaFor', () {
    test('returns meta for core (rule-base) features', () {
      for (final id in const ['bapenda', 'rsud', 'transjatim', 'siskaperbapo', 'nomor_darurat']) {
        final meta = ServiceRegistry.metaFor(id);
        expect(meta, isNotNull, reason: 'core meta for $id should exist');
        expect(meta!.label, isNotEmpty);
      }
    });

    test('returns meta for addable features (delegating to findById)', () {
      final meta = ServiceRegistry.metaFor('etibi');
      expect(meta, isNotNull);
      expect(meta!.label, equals('E-TIBI'));
    });

    test('returns null for unknown id', () {
      expect(ServiceRegistry.metaFor('phantom'), isNull);
    });
  });
}
