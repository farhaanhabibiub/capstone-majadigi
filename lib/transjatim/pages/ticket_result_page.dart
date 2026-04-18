import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/transjatim_model.dart';

class TicketResultPage extends StatelessWidget {
  final TicketOrder order;

  const TicketResultPage({super.key, required this.order});

  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _whiteBg = Color.fromRGBO(248, 248, 245, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);
  static const Color _green = Color.fromRGBO(34, 197, 94, 1);

  String _formatRupiah(int amount) {
    final s = amount.toString();
    final buf = StringBuffer('Rp ');
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _whiteBg,
      appBar: AppBar(
        backgroundColor: _blue,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Tiket Berhasil',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSuccessBanner(),
            const SizedBox(height: 16),
            _buildTicketCard(context),
            const SizedBox(height: 16),
            _buildInfoNote(),
            const SizedBox(height: 24),
            _buildHomeButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(240, 253, 244, 1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: _green, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pembayaran Berhasil!',
                  style: TextStyle(color: _green, fontFamily: 'PlusJakartaSans', fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tunjukkan QR code ke petugas bus',
                  style: TextStyle(color: _green.withValues(alpha: 0.8), fontFamily: 'PlusJakartaSans', fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: _blue,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                      child: Text(order.route.id, style: const TextStyle(color: Colors.white, fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                    Text(
                      order.ticketClass.label,
                      style: const TextStyle(color: Colors.white, fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  order.route.title,
                  style: const TextStyle(color: Colors.white, fontFamily: 'PlusJakartaSans', fontSize: 16, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(order.fromStop, style: const TextStyle(color: Colors.white, fontFamily: 'PlusJakartaSans', fontSize: 12), textAlign: TextAlign.center),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                    ),
                    Flexible(
                      child: Text(order.toStop, style: const TextStyle(color: Colors.white, fontFamily: 'PlusJakartaSans', fontSize: 12), textAlign: TextAlign.center),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Dashed divider
          _DashedDivider(),
          // QR Section
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color.fromRGBO(230, 230, 230, 1)),
                  ),
                  child: QrImageView(
                    data: order.qrData,
                    version: QrVersions.auto,
                    size: 180,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'ID: ${order.orderId}',
                  style: const TextStyle(color: _textSecondary, fontFamily: 'PlusJakartaSans', fontSize: 11, letterSpacing: 1.2),
                ),
              ],
            ),
          ),
          // Dashed divider
          _DashedDivider(),
          // Detail rows
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _detailRow('Penumpang', '${order.passengerCount} orang'),
                const SizedBox(height: 10),
                _detailRow('Pembayaran', order.paymentMethod.toUpperCase()),
                const SizedBox(height: 10),
                _detailRow('Tanggal', _formatDate(order.bookingTime)),
                const SizedBox(height: 12),
                Container(height: 1, color: const Color.fromRGBO(230, 230, 230, 1)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Bayar', style: TextStyle(color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 14, fontWeight: FontWeight.w700)),
                    Text(_formatRupiah(order.totalPrice), style: const TextStyle(color: _blue, fontFamily: 'PlusJakartaSans', fontSize: 16, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: _textSecondary, fontFamily: 'PlusJakartaSans', fontSize: 13)),
        Text(value, style: const TextStyle(color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildInfoNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 251, 235, 1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color.fromRGBO(251, 191, 36, 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 18, color: Color.fromRGBO(217, 119, 6, 1)),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Simpan screenshot tiket ini. Tunjukkan QR code kepada petugas saat naik bus. Tiket berlaku untuk tanggal pemesanan.',
              style: TextStyle(color: Color.fromRGBO(146, 64, 14, 1), fontFamily: 'PlusJakartaSans', fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        style: ElevatedButton.styleFrom(
          backgroundColor: _blue,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
        child: const Text(
          'Kembali ke Beranda',
          style: TextStyle(color: Colors.white, fontFamily: 'PlusJakartaSans', fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      const dashWidth = 8.0;
      const dashSpace = 4.0;
      final count = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
      return Row(
        children: List.generate(count, (_) => Row(children: [
          Container(width: dashWidth, height: 1, color: const Color.fromRGBO(220, 220, 220, 1)),
          const SizedBox(width: dashSpace),
        ])),
      );
    });
  }
}
