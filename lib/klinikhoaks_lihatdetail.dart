import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'klinikhoaks_model.dart';

class KlinikHoaksLihatDetail extends StatelessWidget {
  final LaporanHoaks laporan;

  const KlinikHoaksLihatDetail({super.key, required this.laporan});

  static const _blue = Color(0xFF007AFF);

  @override
  Widget build(BuildContext context) {
    final statusColor = laporan.status == 'Selesai'
        ? const Color(0xFF32D583)
        : laporan.status == 'Diverifikasi'
            ? _blue
            : const Color(0xFFFDB022);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF007AFF), Color(0xFF0062D1)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SizedBox(
                    height: 56,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const Text(
                          'Detail Tiket',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'PlusJakartaSans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('Nomor Tiket'),
                                    GestureDetector(
                                      onTap: () {
                                        Clipboard.setData(
                                          ClipboardData(text: laporan.tiketId),
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Nomor tiket disalin'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      child: Stack(
                                        children: [
                                          _box(laporan.tiketId),
                                          const Positioned(
                                            right: 12,
                                            top: 0,
                                            bottom: 0,
                                            child: Icon(
                                              Icons.copy_rounded,
                                              size: 14,
                                              color: _blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('Status'),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          laporan.status,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'PlusJakartaSans',
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _label('Tanggal Pengajuan'),
                          _box(laporan.tanggal),
                          const SizedBox(height: 20),
                          _label('Topik'),
                          _box(laporan.topik),
                          const SizedBox(height: 20),
                          _label('Isi Laporan'),
                          _box(laporan.isiLaporan, maxLines: 10),
                          const SizedBox(height: 20),
                          _label('Link Bukti / Alamat Website'),
                          _box(laporan.linkBukti),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'PlusJakartaSans',
            color: Color(0xFF1F2937),
          ),
        ),
      );

  Widget _box(String text, {int maxLines = 1}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          text.isEmpty ? '-' : text,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'PlusJakartaSans',
            color: Color(0xFF4B5563),
            height: 1.5,
          ),
        ),
      );
}
