import 'package:flutter/material.dart';
import '../models/sapabansos_model.dart';

class SapaBansosDummyData {
  static final PenerimaResult validPenerima = PenerimaResult(
    nik: '3511******0002',
    nama: 'BUN****',
    kabupaten: 'Pakem',
    kecamatan: 'Patemon',
    kelurahan: '2025',
    program: 'Kemiskinan Ekstrem (2025)'
  );

  static final List<BansosProgram> programs = [
    BansosProgram(
      iconPath: 'assets/images/icon_program.png',
      title: 'Program Keluarga Harapan Plus',
      description: 'Meningkatkan taraf hidup dan kesejahteraan bagi KPM (Lanjut Usia) melalui pemanfaatan bantuan sosial berupa uang yang disalurkan secara non tunai.',
      nilai: 'Rp23.828.500.000',
      kuota: '47.657',
      tersalur: '47.226',
      progressValue: 0.991,
      progressText: '99.1%',
    ),
    BansosProgram(
      iconPath: 'assets/images/icon_disabilitas.png',
      title: 'Asistensi Sosial Penyandang Disabilitas',
      description: 'Bantuan uang tunai bagi penyandang disabilitas berat untuk kebutuhan dasar hidup',
      nilai: 'Rp3.304.800.000',
      kuota: '4.000',
      tersalur: '3.672',
      progressValue: 0.918,
      progressText: '91.8%',
    ),
  ];
}
