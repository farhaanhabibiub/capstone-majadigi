import '../models/sapabansos_model.dart';

class SapaBansosData {
  static const List<BansosProgram> programs = [
    BansosProgram(
      iconPath: 'assets/images/icon_program.png',
      title: 'Program Keluarga Harapan Plus',
      description:
          'Bantuan sosial uang tunai non-tunai bagi KPM Lanjut Usia untuk meningkatkan taraf hidup dan kesejahteraan.',
      kategori: 'Lansia',
      nilai: 'Rp23.828.500.000',
      jumlahPenerima: 47657,
      jumlahTersalur: 47226,
      progressValue: 0.991,
    ),
    BansosProgram(
      iconPath: 'assets/images/icon_disabilitas.png',
      title: 'Asistensi Sosial Penyandang Disabilitas',
      description:
          'Bantuan uang tunai bagi penyandang disabilitas berat untuk pemenuhan kebutuhan dasar hidup sehari-hari.',
      kategori: 'Disabilitas',
      nilai: 'Rp3.304.800.000',
      jumlahPenerima: 4000,
      jumlahTersalur: 3672,
      progressValue: 0.918,
    ),
    BansosProgram(
      iconPath: 'assets/images/icon_storage.png',
      title: 'Bantuan Pangan Non Tunai (BPNT)',
      description:
          'Bantuan pangan berupa beras, telur, dan bahan pokok lainnya yang disalurkan melalui kartu elektronik ke warung gotong royong.',
      kategori: 'Pangan',
      nilai: 'Rp2.869.240.800.000',
      jumlahPenerima: 1196350,
      jumlahTersalur: 1161283,
      progressValue: 0.971,
    ),
    BansosProgram(
      iconPath: 'assets/images/icon_info.png',
      title: 'Bantuan Sosial Tunai (BST)',
      description:
          'Bantuan tunai langsung bagi keluarga miskin dan rentan yang terdampak kenaikan harga bahan pokok.',
      kategori: 'Keluarga Miskin',
      nilai: 'Rp1.424.430.000.000',
      jumlahPenerima: 890269,
      jumlahTersalur: 867123,
      progressValue: 0.974,
    ),
    BansosProgram(
      iconPath: 'assets/images/icon_program.png',
      title: 'PBI-JKN (Iuran BPJS Kesehatan)',
      description:
          'Pembayaran iuran BPJS Kesehatan bagi masyarakat miskin dan tidak mampu agar dapat mengakses layanan kesehatan secara gratis.',
      kategori: 'Kesehatan',
      nilai: 'Rp6.214.323.600.000',
      jumlahPenerima: 2456789,
      jumlahTersalur: 2398234,
      progressValue: 0.976,
    ),
    BansosProgram(
      iconPath: 'assets/images/icon_disabilitas.png',
      title: 'ATENSI – Asistensi Rehabilitasi Sosial',
      description:
          'Program rehabilitasi sosial bagi anak, remaja, dan penyandang masalah kesejahteraan sosial berbasis keluarga dan komunitas.',
      kategori: 'Anak & Remaja',
      nilai: 'Rp45.672.000.000',
      jumlahPenerima: 12450,
      jumlahTersalur: 11234,
      progressValue: 0.902,
    ),
    BansosProgram(
      iconPath: 'assets/images/icon_storage.png',
      title: 'Percepatan Penghapusan Kemiskinan Ekstrem',
      description:
          'Program terpadu lintas sektor untuk menghapus kemiskinan ekstrem melalui bantuan tunai, pemberdayaan ekonomi, dan jaminan sosial.',
      kategori: 'Keluarga Miskin',
      nilai: 'Rp745.122.500.000',
      jumlahPenerima: 312450,
      jumlahTersalur: 298123,
      progressValue: 0.954,
    ),
  ];

  static const List<String> kategoriList = [
    'Semua',
    'Lansia',
    'Disabilitas',
    'Pangan',
    'Keluarga Miskin',
    'Kesehatan',
    'Anak & Remaja',
  ];
}
