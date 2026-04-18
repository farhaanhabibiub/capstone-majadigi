import '../models/transjatim_model.dart';

class TransjatimDummyData {
  static const List<TransjatimRoute> routes = [
    // ── Surabaya Metropolitan ─────────────────────────────────────────────────
    TransjatimRoute(
      id: 'JTM1',
      title: 'Sidoarjo → Gresik',
      city: 'Surabaya Metropolitan',
      operationalHours: '05:00 – 21:00',
      hasLuxury: true,
      luxuryPriceFlat: 20000,
      stops: [
        TransjatimStop(name: 'Halte Terminal Porong',    lat: -7.5480, lng: 112.6838),
        TransjatimStop(name: 'Halte Pondok Mutiara',     lat: -7.4714, lng: 112.7017),
        TransjatimStop(name: 'Halte Segoromadu I',       lat: -7.1834, lng: 112.6507),
        TransjatimStop(name: 'Terminal Bunder',          lat: -7.1567, lng: 112.5748),
      ],
    ),
    TransjatimRoute(
      id: 'JTM2',
      title: 'Surabaya → Sidoarjo',
      city: 'Surabaya Metropolitan',
      operationalHours: '05:00 – 22:00',
      hasLuxury: true,
      luxuryPriceFlat: 15000,
      stops: [
        TransjatimStop(name: 'Terminal Bungurasih',      lat: -7.3505, lng: 112.7321),
        TransjatimStop(name: 'Halte Waru',               lat: -7.3687, lng: 112.7218),
        TransjatimStop(name: 'Halte Gedangan',           lat: -7.3899, lng: 112.7180),
        TransjatimStop(name: 'Halte Buduran',            lat: -7.4023, lng: 112.7245),
        TransjatimStop(name: 'Terminal Porong Sidoarjo', lat: -7.5480, lng: 112.6838),
      ],
    ),
    TransjatimRoute(
      id: 'JTM3',
      title: 'Surabaya → Mojokerto',
      city: 'Surabaya Metropolitan',
      operationalHours: '05:30 – 20:30',
      stops: [
        TransjatimStop(name: 'Terminal Bungurasih',      lat: -7.3505, lng: 112.7321),
        TransjatimStop(name: 'Halte Sepanjang',          lat: -7.3312, lng: 112.6890),
        TransjatimStop(name: 'Halte Krian',              lat: -7.3875, lng: 112.5890),
        TransjatimStop(name: 'Terminal Kertajaya',       lat: -7.4706, lng: 112.4382),
      ],
    ),

    // ── Malang Raya ───────────────────────────────────────────────────────────
    TransjatimRoute(
      id: 'MLG1',
      title: 'Malang → Batu',
      city: 'Malang Raya',
      operationalHours: '05:00 – 21:00',
      hasLuxury: true,
      luxuryPriceFlat: 30000,
      stops: [
        TransjatimStop(name: 'Terminal Hamid Rusdi',     lat: -7.9894, lng: 112.6483),
        TransjatimStop(name: 'Halte Rambu Kawi',         lat: -7.9650, lng: 112.6260),
        TransjatimStop(name: 'Halte Banjartengah',       lat: -7.9513, lng: 112.5970),
        TransjatimStop(name: 'Terminal Batu',            lat: -7.8706, lng: 112.5235),
      ],
    ),
    TransjatimRoute(
      id: 'MLG2',
      title: 'Arjosari → Landungsari',
      city: 'Malang Raya',
      operationalHours: '05:30 – 20:00',
      stops: [
        TransjatimStop(name: 'Terminal Arjosari',        lat: -7.9261, lng: 112.6543),
        TransjatimStop(name: 'Halte Blimbing',           lat: -7.9389, lng: 112.6432),
        TransjatimStop(name: 'Halte Kota Lama Malang',  lat: -7.9762, lng: 112.6324),
        TransjatimStop(name: 'Halte Dinoyo',             lat: -7.9534, lng: 112.6076),
        TransjatimStop(name: 'Terminal Landungsari',     lat: -7.9289, lng: 112.5876),
      ],
    ),
    TransjatimRoute(
      id: 'MLG3',
      title: 'Malang → Kepanjen',
      city: 'Malang Raya',
      operationalHours: '06:00 – 19:00',
      hasLuxury: true,
      luxuryPriceFlat: 25000,
      stops: [
        TransjatimStop(name: 'Terminal Hamid Rusdi',     lat: -7.9894, lng: 112.6483),
        TransjatimStop(name: 'Halte Klojen',             lat: -7.9799, lng: 112.6271),
        TransjatimStop(name: 'Halte Gondanglegi',        lat: -8.0834, lng: 112.6189),
        TransjatimStop(name: 'Terminal Kepanjen',        lat: -8.1312, lng: 112.5678),
      ],
    ),

    // ── Pasuruan – Probolinggo ────────────────────────────────────────────────
    TransjatimRoute(
      id: 'PSR1',
      title: 'Pasuruan → Probolinggo',
      city: 'Pasuruan – Probolinggo',
      operationalHours: '06:00 – 20:00',
      stops: [
        TransjatimStop(name: 'Terminal Pasuruan',        lat: -7.6457, lng: 112.9071),
        TransjatimStop(name: 'Halte Bangil',             lat: -7.5993, lng: 112.7865),
        TransjatimStop(name: 'Halte Grati',              lat: -7.6623, lng: 112.9756),
        TransjatimStop(name: 'Terminal Probolinggo',     lat: -7.7543, lng: 113.2154),
      ],
    ),

    // ── Kediri – Jombang ──────────────────────────────────────────────────────
    TransjatimRoute(
      id: 'KDR1',
      title: 'Kediri → Jombang',
      city: 'Kediri – Jombang',
      operationalHours: '06:00 – 19:30',
      stops: [
        TransjatimStop(name: 'Terminal Tamanan Kediri',  lat: -7.8234, lng: 112.0134),
        TransjatimStop(name: 'Halte Pare',               lat: -7.7512, lng: 112.1889),
        TransjatimStop(name: 'Halte Kandangan',          lat: -7.6890, lng: 112.2012),
        TransjatimStop(name: 'Terminal Jombang',         lat: -7.5512, lng: 112.2345),
      ],
    ),

    // ── Madiun – Ngawi ────────────────────────────────────────────────────────
    TransjatimRoute(
      id: 'MDN1',
      title: 'Madiun → Ngawi',
      city: 'Madiun – Ngawi',
      operationalHours: '06:00 – 19:00',
      stops: [
        TransjatimStop(name: 'Terminal Madiun',          lat: -7.6234, lng: 111.5234),
        TransjatimStop(name: 'Halte Caruban',            lat: -7.5712, lng: 111.6789),
        TransjatimStop(name: 'Halte Saradan',            lat: -7.5234, lng: 111.8123),
        TransjatimStop(name: 'Terminal Ngawi',           lat: -7.4089, lng: 111.4512),
      ],
    ),

    // ── Jember – Lumajang ─────────────────────────────────────────────────────
    TransjatimRoute(
      id: 'JBR1',
      title: 'Jember → Lumajang',
      city: 'Jember – Lumajang',
      operationalHours: '06:00 – 18:00',
      stops: [
        TransjatimStop(name: 'Terminal Tawang Alun',     lat: -8.1721, lng: 113.7036),
        TransjatimStop(name: 'Halte Tanggul',            lat: -8.1934, lng: 113.4512),
        TransjatimStop(name: 'Halte Lumajang Kota',      lat: -8.1265, lng: 113.2234),
        TransjatimStop(name: 'Terminal Minak Koncar',    lat: -8.1089, lng: 113.2012),
      ],
    ),
  ];

  /// Semua halte unik dari seluruh rute, untuk tampilan peta.
  static List<TransjatimStop> get allStops {
    final seen = <String>{};
    final result = <TransjatimStop>[];
    for (final route in routes) {
      for (final stop in route.stops) {
        if (seen.add(stop.name)) result.add(stop);
      }
    }
    return result;
  }

  /// Rute yang melalui halte tertentu.
  static List<TransjatimRoute> routesForStop(String stopName) =>
      routes.where((r) => r.stops.any((s) => s.name == stopName)).toList();
}
