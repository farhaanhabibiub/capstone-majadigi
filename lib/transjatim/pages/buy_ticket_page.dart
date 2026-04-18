import 'package:flutter/material.dart';
import '../models/transjatim_model.dart';
import 'payment_page.dart';

class BuyTicketPage extends StatefulWidget {
  final TransjatimRoute route;
  const BuyTicketPage({super.key, required this.route});

  @override
  State<BuyTicketPage> createState() => _BuyTicketPageState();
}

class _BuyTicketPageState extends State<BuyTicketPage> {
  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _whiteBg = Color.fromRGBO(248, 248, 245, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);

  TicketClass _ticketClass = TicketClass.economy;
  int _fromIndex = 0;
  int _toIndex = 1;
  int _passengerCount = 1;

  List<DropdownMenuItem<int>> get _fromItems => List.generate(
        widget.route.stops.length - 1,
        (i) => DropdownMenuItem(value: i, child: Text(widget.route.stops[i].name, overflow: TextOverflow.ellipsis)),
      );

  List<DropdownMenuItem<int>> get _toItems => List.generate(
        widget.route.stops.length,
        (i) => DropdownMenuItem(value: i, child: Text(widget.route.stops[i].name, overflow: TextOverflow.ellipsis)),
      ).where((item) => item.value! > _fromIndex).toList();

  int get _pricePerPax =>
      widget.route.calculatePrice(_fromIndex, _toIndex, _ticketClass);

  int get _totalPrice => _pricePerPax * _passengerCount;

  String _formatRupiah(int amount) {
    final s = amount.toString();
    final buf = StringBuffer('Rp ');
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  void _onFromChanged(int? val) {
    if (val == null) return;
    setState(() {
      _fromIndex = val;
      if (_toIndex <= _fromIndex) _toIndex = _fromIndex + 1;
    });
  }

  void _proceed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          route: widget.route,
          fromIndex: _fromIndex,
          toIndex: _toIndex,
          ticketClass: _ticketClass,
          passengerCount: _passengerCount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Beli Tiket',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRouteInfo(),
            const SizedBox(height: 16),
            if (widget.route.hasLuxury) ...[
              _buildClassSelector(),
              const SizedBox(height: 16),
            ],
            _buildStopSelector(),
            const SizedBox(height: 16),
            _buildPassengerSelector(),
            const SizedBox(height: 16),
            _buildPriceSummary(),
            const SizedBox(height: 24),
            _buildProceedButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteInfo() {
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
              Text(
                widget.route.city,
                style: const TextStyle(color: _textSecondary, fontFamily: 'PlusJakartaSans', fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.route.title,
            style: const TextStyle(color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 14, color: _textSecondary),
              const SizedBox(width: 4),
              Text(
                widget.route.operationalHours,
                style: const TextStyle(color: _textSecondary, fontFamily: 'PlusJakartaSans', fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassSelector() {
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
          const Text(
            'Kelas',
            style: TextStyle(color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _classChip(TicketClass.economy, 'Ekonomi', Icons.directions_bus_rounded),
              const SizedBox(width: 10),
              _classChip(TicketClass.luxury, 'Luxury', Icons.star_rounded),
            ],
          ),
          if (_ticketClass == TicketClass.luxury) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(235, 243, 255, 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 14, color: _blue),
                  const SizedBox(width: 6),
                  Text(
                    'Harga flat ${_formatRupiah(widget.route.luxuryPriceFlat)}/penumpang (seluruh rute)',
                    style: const TextStyle(color: _blue, fontFamily: 'PlusJakartaSans', fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _classChip(TicketClass cls, String label, IconData icon) {
    final isSelected = _ticketClass == cls;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _ticketClass = cls),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? _blue : const Color.fromRGBO(245, 245, 245, 1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? _blue : Colors.transparent),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : _textSecondary, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : _textSecondary,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStopSelector() {
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
          const Text(
            'Pilih Halte',
            style: TextStyle(color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _dropdownField(
            label: 'Dari',
            icon: Icons.radio_button_checked_rounded,
            iconColor: _blue,
            value: _fromIndex,
            items: _fromItems,
            onChanged: _onFromChanged,
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Container(width: 2, height: 20, color: const Color.fromRGBO(200, 200, 200, 1)),
          ),
          const SizedBox(height: 4),
          _dropdownField(
            label: 'Ke',
            icon: Icons.location_on_rounded,
            iconColor: Colors.red,
            value: _toIndex,
            items: _toItems,
            onChanged: (val) { if (val != null) setState(() => _toIndex = val); },
          ),
        ],
      ),
    );
  }

  Widget _dropdownField({
    required String label,
    required IconData icon,
    required Color iconColor,
    required int value,
    required List<DropdownMenuItem<int>> items,
    required ValueChanged<int?> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: _textSecondary, fontFamily: 'PlusJakartaSans', fontSize: 11)),
              DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: value,
                  isExpanded: true,
                  style: const TextStyle(color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.w600),
                  items: items,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPassengerSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.person_rounded, color: _blue, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Jumlah Penumpang',
              style: TextStyle(color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          _counterButton(Icons.remove, () {
            if (_passengerCount > 1) setState(() => _passengerCount--);
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '$_passengerCount',
              style: const TextStyle(color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          _counterButton(Icons.add, () {
            if (_passengerCount < 5) setState(() => _passengerCount++);
          }),
        ],
      ),
    );
  }

  Widget _counterButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(235, 243, 255, 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: _blue, size: 18),
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(235, 243, 255, 1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _blue.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _priceRow('Harga/penumpang', _formatRupiah(_pricePerPax)),
          const SizedBox(height: 6),
          _priceRow('Penumpang', '× $_passengerCount'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(thickness: 1, color: Color.fromRGBO(0, 101, 255, 0.2)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 15, fontWeight: FontWeight.w700),
              ),
              Text(
                _formatRupiah(_totalPrice),
                style: const TextStyle(color: _blue, fontFamily: 'PlusJakartaSans', fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: _textSecondary, fontFamily: 'PlusJakartaSans', fontSize: 13)),
        Text(value, style: const TextStyle(color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildProceedButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _proceed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _blue,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
        child: const Text(
          'Pesan Tiket',
          style: TextStyle(color: Colors.white, fontFamily: 'PlusJakartaSans', fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
