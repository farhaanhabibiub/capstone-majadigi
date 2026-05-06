import 'package:flutter_test/flutter_test.dart';
import 'package:majadigi/rsud/hospital_config.dart';

void main() {
  group('HospitalConfig.forLocation', () {
    test('Batu maps to Karsa Husada (checked before Malang)', () {
      expect(
        HospitalConfig.forLocation('Batu', '').id,
        equals('karsa_husada'),
      );
    });

    test('Malang maps to Saiful Anwar', () {
      expect(
        HospitalConfig.forLocation('Malang', '').id,
        equals('saiful_anwar'),
      );
    });

    test('Kediri maps to Daha Husada', () {
      expect(
        HospitalConfig.forLocation('Kediri', '').id,
        equals('daha_husada'),
      );
    });

    test('Surabaya maps to Prov Jatim', () {
      expect(
        HospitalConfig.forLocation('Surabaya', '').id,
        equals('prov_jatim'),
      );
    });

    test('matching is case-insensitive', () {
      expect(
        HospitalConfig.forLocation('SURABAYA', '').id,
        equals('prov_jatim'),
      );
      expect(
        HospitalConfig.forLocation('kEdIrI', '').id,
        equals('daha_husada'),
      );
    });

    test('extended East Java coverage routes to nearest hospital', () {
      // Blitar / Tulungagung / Nganjuk / Jombang → Daha Husada (Kediri).
      expect(HospitalConfig.forLocation('Blitar', '').id, equals('daha_husada'));
      expect(HospitalConfig.forLocation('Tulungagung', '').id, equals('daha_husada'));

      // Pasuruan / Probolinggo / Lumajang → Saiful Anwar (Malang).
      expect(HospitalConfig.forLocation('Pasuruan', '').id, equals('saiful_anwar'));
      expect(HospitalConfig.forLocation('Lumajang', '').id, equals('saiful_anwar'));

      // Sidoarjo / Gresik / Mojokerto / Lamongan → Prov Jatim (Surabaya).
      expect(HospitalConfig.forLocation('Sidoarjo', '').id, equals('prov_jatim'));
      expect(HospitalConfig.forLocation('Gresik', '').id, equals('prov_jatim'));
    });

    test('unknown location falls back to Daha Husada', () {
      expect(
        HospitalConfig.forLocation('Bandung', '').id,
        equals('daha_husada'),
      );
      expect(
        HospitalConfig.forLocation('', '').id,
        equals('daha_husada'),
      );
    });

    test('regency field is consulted when city is empty', () {
      expect(
        HospitalConfig.forLocation('', 'Kabupaten Malang').id,
        equals('saiful_anwar'),
      );
    });

    test('returned config has populated CSV asset paths', () {
      final cfg = HospitalConfig.forLocation('Surabaya', '');
      expect(cfg.kamarCsv, isNotEmpty);
      expect(cfg.jadwalCsv, isNotEmpty);
      expect(cfg.antreanCsv, isNotEmpty);
      expect(cfg.name, contains('Jawa Timur'));
    });
  });
}
