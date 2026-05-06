import 'package:flutter_test/flutter_test.dart';
import 'package:majadigi/personalization_rule_base.dart';

void main() {
  group('PersonalizationRuleBase.resolveFeatures', () {
    test('returns 5 default features when no category selected', () {
      final result = PersonalizationRuleBase.resolveFeatures(
        selectedCategoryIds: [],
        city: 'Kediri',
        regency: '',
      );

      expect(result, hasLength(5));
      expect(result, containsAll(['bapenda', 'transjatim', 'siskaperbapo', 'nomor_darurat']));
      // RSUD generic id should be replaced with location-specific RSUD.
      expect(result.any((id) => id.startsWith('rsud_')), isTrue);
      expect(result.contains('rsud'), isFalse);
    });

    test('returns 5 features for single category (kesehatan)', () {
      final result = PersonalizationRuleBase.resolveFeatures(
        selectedCategoryIds: ['kesehatan'],
        city: 'Malang',
        regency: '',
      );

      expect(result, hasLength(5));
      // First-rank for kesehatan is rsud → resolved to nearest RSUD.
      expect(result.first, equals('rsud_saiful_anwar'));
      expect(result, containsAll(['etibi', 'nomor_darurat', 'sapa_bansos', 'klinik_hoaks']));
    });

    test('multi-category aggregates score across categories', () {
      // ekonomi:    [bapenda(5), siskaperbapo(4), sapa_bansos(3), open_data(2), klinik_hoaks(1)]
      // kesehatan:  [rsud(5),    etibi(4),        nomor_darurat(3), sapa_bansos(2), klinik_hoaks(1)]
      final result = PersonalizationRuleBase.resolveFeatures(
        selectedCategoryIds: ['ekonomi', 'kesehatan'],
        city: 'Kediri',
        regency: '',
      );

      expect(result, hasLength(5));
      // 3 features tied at score 5: bapenda, sapa_bansos, rsud (resolved).
      // Tiebreaker is alphabetical on resolved id, so all three should appear.
      expect(result, contains('bapenda'));
      expect(result, contains('sapa_bansos'));
      expect(result.any((id) => id.startsWith('rsud_')), isTrue);
      // etibi (4) and siskaperbapo (4) round out the top-5.
      expect(result, contains('etibi'));
      expect(result, contains('siskaperbapo'));
    });

    test('falls back to defaults when all categories are unknown', () {
      final result = PersonalizationRuleBase.resolveFeatures(
        selectedCategoryIds: ['unknown_a', 'unknown_b'],
        city: 'Kediri',
        regency: '',
      );

      expect(result, hasLength(5));
      expect(result, containsAll(['bapenda', 'transjatim', 'siskaperbapo', 'nomor_darurat']));
    });

    test('result is deterministic for the same input', () {
      final a = PersonalizationRuleBase.resolveFeatures(
        selectedCategoryIds: ['ekonomi', 'sosial', 'pemerintahan'],
        city: 'Surabaya',
        regency: '',
      );
      final b = PersonalizationRuleBase.resolveFeatures(
        selectedCategoryIds: ['ekonomi', 'sosial', 'pemerintahan'],
        city: 'Surabaya',
        regency: '',
      );
      expect(a, equals(b));
    });

    test('rsud token is replaced exactly once with location-specific id', () {
      final result = PersonalizationRuleBase.resolveFeatures(
        selectedCategoryIds: ['kesehatan'],
        city: 'Surabaya',
        regency: '',
      );

      expect(result.contains('rsud'), isFalse);
      final rsudCount = result.where((id) => id.startsWith('rsud_')).length;
      expect(rsudCount, equals(1));
      expect(result, contains('rsud_prov_jatim'));
    });
  });
}
