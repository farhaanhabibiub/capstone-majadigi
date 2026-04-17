import '../models/sembako_model.dart';

class SembakoDummyData {
  static final List<SembakoItem> items = [
    SembakoItem(
      id: '1',
      name: 'Bawang Merah',
      price: 36078,
      status: 1, // naik
      statusText: 'Harga naik',
      imagePath: 'assets/images/bawang_merah.png',
      historyPrices: [35500, 36000, 36478],
      historyDates: ['03/03/26', '08/03/26', '13/03/26'],
      cityPrices: [
        CityPrice('Kabupaten Pasuruan', 39000),
        CityPrice('Kota Batu', 38250),
        CityPrice('Kabupaten Kediri', 38333),
        CityPrice('Kabupaten Jember', 38200),
        CityPrice('Kabupaten Gresik', 37333),
      ],
    ),
    SembakoItem(
      id: '2',
      name: 'Bawang Putih',
      price: 30995,
      status: -1, // turun
      statusText: 'Harga turun',
      imagePath: 'assets/images/bawang_putih.png',
      historyPrices: [32500, 32000, 31650],
      historyDates: ['03/03/26', '08/03/26', '13/03/26'],
      cityPrices: [
        CityPrice('Kabupaten Pasuruan', 33000),
        CityPrice('Kota Batu', 32250),
        CityPrice('Kabupaten Kediri', 33333),
        CityPrice('Kabupaten Jember', 33200),
        CityPrice('Kabupaten Gresik', 32333),
      ],
    ),
    SembakoItem(
      id: '3',
      name: 'Beras Medium',
      price: 11500,
      status: 0, // stabil
      statusText: 'Stabil',
      imagePath: 'assets/images/beras_medium.png',
      historyPrices: [11500, 11500, 11500],
      historyDates: ['03/03/26', '08/03/26', '13/03/26'],
      cityPrices: [
        CityPrice('Kabupaten Pasuruan', 11500),
        CityPrice('Kota Batu', 11500),
        CityPrice('Kabupaten Kediri', 11500),
        CityPrice('Kabupaten Jember', 11500),
        CityPrice('Kabupaten Gresik', 11500),
      ],
    ),
    SembakoItem(
      id: '4',
      name: 'Beras Premium',
      price: 14200,
      status: 1, // naik
      statusText: 'Harga naik',
      imagePath: 'assets/images/beras_premium.png',
      historyPrices: [13800, 14000, 14200],
      historyDates: ['03/03/26', '08/03/26', '13/03/26'],
      cityPrices: [
        CityPrice('Kabupaten Pasuruan', 14500),
        CityPrice('Kota Batu', 14250),
        CityPrice('Kabupaten Kediri', 14300),
        CityPrice('Kabupaten Jember', 14200),
        CityPrice('Kabupaten Gresik', 14000),
      ],
    ),
    SembakoItem(
      id: '5',
      name: 'Cabe Rawit Merah',
      price: 75000,
      status: 1, // naik
      statusText: 'Harga naik',
      imagePath: 'assets/images/cabe_rawit.png',
      historyPrices: [65000, 70000, 75000],
      historyDates: ['03/03/26', '08/03/26', '13/03/26'],
      cityPrices: [
        CityPrice('Kabupaten Pasuruan', 76000),
        CityPrice('Kota Batu', 75000),
        CityPrice('Kabupaten Kediri', 75500),
        CityPrice('Kabupaten Jember', 74000),
        CityPrice('Kabupaten Gresik', 74500),
      ],
    ),
    SembakoItem(
      id: '6',
      name: 'Cabe Merah Besar',
      price: 60000,
      status: -1, // turun
      statusText: 'Harga turun',
      imagePath: 'assets/images/cabe_merah.png',
      historyPrices: [68000, 64000, 60000],
      historyDates: ['03/03/26', '08/03/26', '13/03/26'],
      cityPrices: [
        CityPrice('Kabupaten Pasuruan', 61000),
        CityPrice('Kota Batu', 59000),
        CityPrice('Kabupaten Kediri', 60500),
        CityPrice('Kabupaten Jember', 60000),
        CityPrice('Kabupaten Gresik', 59500),
      ],
    ),
    SembakoItem(
      id: '7',
      name: 'Cabe Merah Keriting',
      price: 16000,
      status: 0, // stabil
      statusText: 'Stabil',
      imagePath: 'assets/images/Cabe_Merah_Keriting.png',
      historyPrices: [16000, 16000, 16000],
      historyDates: ['03/03/26', '08/03/26', '13/03/26'],
      cityPrices: [
        CityPrice('Kabupaten Pasuruan', 16000),
        CityPrice('Kota Batu', 16000),
        CityPrice('Kabupaten Kediri', 16000),
        CityPrice('Kabupaten Jember', 16000),
        CityPrice('Kabupaten Gresik', 16000),
      ],
    ),
    SembakoItem(
      id: '8',
      name: 'Daging Sapi Murni',
      price: 120000,
      status: 1, // naik
      statusText: 'Harga naik',
      imagePath: 'assets/images/daging_sapi.png',
      historyPrices: [118000, 119500, 120000],
      historyDates: ['03/03/26', '08/03/26', '13/03/26'],
      cityPrices: [
        CityPrice('Kabupaten Pasuruan', 121000),
        CityPrice('Kota Batu', 120000),
        CityPrice('Kabupaten Kediri', 120500),
        CityPrice('Kabupaten Jember', 119000),
        CityPrice('Kabupaten Gresik', 118500),
      ],
    ),
  ];
}
