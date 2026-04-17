import 'package:flutter/material.dart';

class PenerimaResult {
  final String nik;
  final String nama;
  final String kabupaten;
  final String kecamatan;
  final String kelurahan;
  final String program;

  PenerimaResult({
    required this.nik,
    required this.nama,
    required this.kabupaten,
    required this.kecamatan,
    required this.kelurahan,
    required this.program,
  });
}

class BansosProgram {
  final String iconPath;
  final String title;
  final String description;
  final String nilai;
  final String kuota;
  final String tersalur;
  final double progressValue;
  final String progressText;

  BansosProgram({
    required this.iconPath,
    required this.title,
    required this.description,
    required this.nilai,
    required this.kuota,
    required this.tersalur,
    required this.progressValue,
    required this.progressText,
  });
}
