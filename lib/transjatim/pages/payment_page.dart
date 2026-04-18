import 'dart:math';
import 'package:flutter/material.dart';
import '../models/transjatim_model.dart';
import 'ticket_result_page.dart';

class PaymentPage extends StatefulWidget {
  final TransjatimRoute route;
  final int fromIndex;
  final int toIndex;
  final TicketClass ticketClass;
  final int passengerCount;

  const PaymentPage({
    super.key,
    required this.route,
    required this.fromIndex,
    required this.toIndex,
    required this.ticketClass,
    required this.passengerCount,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _whiteBg = Color.fromRGBO(248, 248, 245, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);

  String? _selectedMethod;

  static const List<_PaymentMethod> _methods = [
    _PaymentMethod(id: 'qris', label: 'QRIS', icon: Icons.qr_code_2_rounded, group: 'Digital'),
    _PaymentMethod(id: 'gopay', label: 'GoPay', icon: Icons.account_balance_wallet_rounded, group: 'Digital'),
    _PaymentMethod(id: 'ovo', label: 'OVO', icon: Icons.account_balance_wallet_rounded, group: 'Digital'),
    _PaymentMethod(id: 'dana', label: 'DANA', icon: Icons.account_balance_wallet_rounded, group: 'Digital'),
    _PaymentMethod(id: 'bca', label: 'BCA Virtual Account', icon: Icons.account_balance_rounded, group: 'Transfer Bank'),
    _PaymentMethod(id: 'bri', label: 'BRI Virtual Account', icon: Icons.account_balance_rounded, group: 'Transfer Bank'),
    _PaymentMethod(id: 'mandiri', label: 'Mandiri Virtual Account', icon: Icons.account_balance_rounded, group: 'Transfer Bank'),
    _PaymentMethod(id: 'tunai', label: 'Tunai (di bus)', icon: Icons.payments_rounded, group: 'Lainnya'),
  ];

  int get _pricePerPax =>
      widget.route.calculatePrice(widget.fromIndex, widget.toIndex, widget.ticketClass);

  int get _totalPrice => _pricePerPax * widget.passengerCount;

  String _formatRupiah(int amount) {
    final s = amount.toString();
    final buf = StringBuffer('Rp ');
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  void _pay() {
    if (_selectedMethod == null) return;
    final orderId = 'TJ${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(999)}';
    final order = TicketOrder(
      orderId: orderId,
      route: widget.route,
      fromIndex: widget.fromIndex,
      toIndex: widget.toIndex,
      ticketClass: widget.ticketClass,
      passengerCount: widget.passengerCount,
      paymentMethod: _selectedMethod!,
      bookingTime: DateTime.now(),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => TicketResultPage(order: order)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groups = <String>[];
    for (final m in _methods) {
      if (!groups.contains(m.group)) groups.add(m.group);
    }

    return Scaffold(
      backgroundColor: _whiteBg,
      appBar: AppBar(
        backgroundColor: _blue,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pembayaran',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderSummary(),
                  const SizedBox(height: 16),
                  ...groups.map((g) => _buildMethodGroup(
                        g,
                        _methods.where((m) => m.group == g).toList(),
                      )),
                ],
              ),
            ),
          ),
          _buildPayButton(),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _blue, borderRadius: BorderRadius.circular(20)),
                child: Text(
                  widget.route.id,
                  style: const TextStyle(color: Colors.white, fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Text(widget.route.city, style: const TextStyle(color: _textSecondary, fontFamily: 'PlusJakartaSans', fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${widget.route.stops[widget.fromIndex].name} → ${widget.route.stops[widget.toIndex].name}',
            style: const TextStyle(color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          _summaryRow('Kelas', widget.ticketClass.label),
          const SizedBox(height: 6),
          _summaryRow('Penumpang', '${widget.passengerCount} orang'),
          const SizedBox(height: 6),
          _summaryRow('Harga/penumpang', _formatRupiah(_pricePerPax)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(235, 243, 255, 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Pembayaran', style: TextStyle(color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 14, fontWeight: FontWeight.w700)),
                Text(_formatRupiah(_totalPrice), style: const TextStyle(color: _blue, fontFamily: 'PlusJakartaSans', fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: _textSecondary, fontFamily: 'PlusJakartaSans', fontSize: 13)),
        Text(value, style: const TextStyle(color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildMethodGroup(String group, List<_PaymentMethod> methods) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(group, style: const TextStyle(color: _textSecondary, fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w600)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: methods.asMap().entries.map((e) {
              final idx = e.key;
              final m = e.value;
              final isFirst = idx == 0;
              final isLast = idx == methods.length - 1;
              return _buildMethodTile(m, isFirst, isLast);
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMethodTile(_PaymentMethod method, bool isFirst, bool isLast) {
    final isSelected = _selectedMethod == method.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromRGBO(235, 243, 255, 1) : Colors.transparent,
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(16) : Radius.zero,
            bottom: isLast ? const Radius.circular(16) : Radius.zero,
          ),
          border: isSelected ? Border.all(color: _blue.withValues(alpha: 0.3)) : null,
        ),
        child: Row(
          children: [
            Icon(method.icon, color: isSelected ? _blue : _textSecondary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                method.label,
                style: TextStyle(
                  color: isSelected ? _blue : _textPrimary,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? _blue : _textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -4))],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _selectedMethod != null ? _pay : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _blue,
            disabledBackgroundColor: const Color.fromRGBO(200, 200, 200, 1),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          ),
          child: Text(
            _selectedMethod != null ? 'Bayar ${_formatRupiah(_totalPrice)}' : 'Pilih Metode Pembayaran',
            style: const TextStyle(color: Colors.white, fontFamily: 'PlusJakartaSans', fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _PaymentMethod {
  final String id;
  final String label;
  final IconData icon;
  final String group;
  const _PaymentMethod({required this.id, required this.label, required this.icon, required this.group});
}
