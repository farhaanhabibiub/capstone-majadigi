import 'package:flutter/material.dart';

/// Model satu kartu berita / artikel di Beranda & halaman Arsip.
class ArtikelItem {
  final String tag;
  final Color tagColor;
  final String title;
  final String assetPath;
  final String date;
  final String url;

  const ArtikelItem({
    required this.tag,
    required this.tagColor,
    required this.title,
    required this.assetPath,
    required this.date,
    required this.url,
  });
}

// ── Palet warna tag ───────────────────────────────────────────────────────────
const Color _tagTeknologi = Color.fromRGBO(0, 101, 255, 1);
const Color _tagKebijakan = Color.fromRGBO(202, 138, 4, 1);
const Color _tagLayanan = Color.fromRGBO(13, 148, 136, 1);
const Color _tagEkonomi = Color.fromRGBO(217, 70, 239, 1);
const Color _tagKesehatan = Color.fromRGBO(220, 38, 38, 1);
const Color _tagSosial = Color.fromRGBO(245, 158, 11, 1);
const Color _tagInfrastruktur = Color.fromRGBO(71, 85, 105, 1);
const Color _tagPariwisata = Color.fromRGBO(2, 132, 199, 1);

/// Daftar lengkap berita & artikel untuk halaman Arsip.
/// Beranda hanya menampilkan 3 artikel teratas.
const List<ArtikelItem> kBeritaArtikels = [
  ArtikelItem(
    tag: 'TEKNOLOGI',
    tagColor: _tagTeknologi,
    title: 'BAPENDA Jatim Luncurkan Fitur Pembayaran Digital',
    assetPath: 'assets/images/artikel_1.png',
    date: '11 April 2026',
    url:
        'https://rri.co.id/surabaya/regional/1189034/bapenda-jatim-mudahkan-bayar-pajak-dengan-inovasi-digital',
  ),
  ArtikelItem(
    tag: 'KEBIJAKAN',
    tagColor: _tagKebijakan,
    title: 'Update Aturan Pajak Kendaraan Bermotor 2026',
    assetPath: 'assets/images/artikel_2.png',
    date: '15 Maret 2026',
    url:
        'https://nasional.kontan.co.id/news/resmi-berlaku-april-2026-pajak-mobil-motor-listrik-tak-lagi-rp-0-ini-aturannya',
  ),
  ArtikelItem(
    tag: 'LAYANAN',
    tagColor: _tagLayanan,
    title: 'Integrasi Layanan Kesehatan RSUD Dr. Soetomo',
    assetPath: 'assets/images/artikel_3.png',
    date: '15 Maret 2026',
    url: 'https://rsudrsoetomo.jatimprov.go.id/',
  ),
  ArtikelItem(
    tag: 'KESEHATAN',
    tagColor: _tagKesehatan,
    title: 'Skrining TBC Mandiri Capai 1 Juta Pengguna',
    assetPath: 'assets/images/artikel_1.png',
    date: '02 Maret 2026',
    url: 'https://dinkes.jatimprov.go.id/',
  ),
  ArtikelItem(
    tag: 'EKONOMI',
    tagColor: _tagEkonomi,
    title: 'Harga Bahan Pokok Stabil Jelang Idul Fitri 2026',
    assetPath: 'assets/images/artikel_2.png',
    date: '24 Februari 2026',
    url: 'https://siskaperbapo.jatimprov.go.id/',
  ),
  ArtikelItem(
    tag: 'SOSIAL',
    tagColor: _tagSosial,
    title: 'Sapa Bansos Salurkan Bantuan ke 250 Ribu KK',
    assetPath: 'assets/images/artikel_3.png',
    date: '18 Februari 2026',
    url: 'https://dinsos.jatimprov.go.id/',
  ),
  ArtikelItem(
    tag: 'INFRASTRUKTUR',
    tagColor: _tagInfrastruktur,
    title: 'TransJatim Tambah 5 Koridor Baru di 2026',
    assetPath: 'assets/images/artikel_1.png',
    date: '10 Februari 2026',
    url: 'https://dishub.jatimprov.go.id/',
  ),
  ArtikelItem(
    tag: 'PARIWISATA',
    tagColor: _tagPariwisata,
    title: 'Bromo Tengger Semeru Kembali Buka Penuh',
    assetPath: 'assets/images/artikel_2.png',
    date: '01 Februari 2026',
    url: 'https://disbudpar.jatimprov.go.id/',
  ),
  ArtikelItem(
    tag: 'TEKNOLOGI',
    tagColor: _tagTeknologi,
    title: 'Open Data Jatim Rilis 120 Dataset Baru',
    assetPath: 'assets/images/artikel_3.png',
    date: '20 Januari 2026',
    url: 'https://opendata.jatimprov.go.id/',
  ),
  ArtikelItem(
    tag: 'KEBIJAKAN',
    tagColor: _tagKebijakan,
    title: 'Klinik Hoaks Jatim Verifikasi 3.500 Laporan',
    assetPath: 'assets/images/artikel_1.png',
    date: '12 Januari 2026',
    url: 'https://klinikhoaks.jatimprov.go.id/',
  ),
];
