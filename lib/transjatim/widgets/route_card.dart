import 'package:flutter/material.dart';
import '../models/transjatim_model.dart';
import 'timeline_graph.dart';

class RouteCard extends StatefulWidget {
  final TransjatimRoute route;

  const RouteCard({Key? key, required this.route}) : super(key: key);

  @override
  State<RouteCard> createState() => _RouteCardState();
}

class _RouteCardState extends State<RouteCard> {
  bool _isExpanded = false;
  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          if (_isExpanded) _buildExpandedBody() else _buildCollapsedBody(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color.fromRGBO(235, 243, 255, 1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.directions_bus_rounded, color: _blue, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            widget.route.title,
            style: const TextStyle(
              color: _textPrimary,
              fontFamily: 'PlusJakartaSans',
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (!_isExpanded)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(245, 245, 245, 1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 13, color: _textSecondary),
                const SizedBox(width: 4),
                Text(
                  widget.route.operationalHours,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCollapsedBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on_rounded, size: 20, color: _blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.route.origin,
                style: const TextStyle(color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 9),
          child: Container(width: 2, height: 20, color: const Color.fromRGBO(200, 200, 200, 1)),
        ),
        Row(
          children: [
            const Icon(Icons.location_on_rounded, size: 20, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.route.destination,
                style: const TextStyle(color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => setState(() => _isExpanded = true),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _blue),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Lihat Detail Rute',
              style: TextStyle(color: _blue, fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.access_time_rounded, size: 14, color: _textSecondary),
            const SizedBox(width: 6),
            const Text('Jam operasional ', style: TextStyle(color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 12)),
            Text(widget.route.operationalHours, style: const TextStyle(color: _blue, fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: _blue, borderRadius: BorderRadius.circular(12)),
              child: Text(widget.route.id, style: const TextStyle(color: Colors.white, fontFamily: 'PlusJakartaSans', fontSize: 11, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(widget.route.city, style: const TextStyle(color: _textSecondary, fontFamily: 'PlusJakartaSans', fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
                alignment: Alignment.center,
                child: Text(
                  widget.route.origin,
                  style: const TextStyle(color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.arrow_forward, color: _blue, size: 20),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
                alignment: Alignment.center,
                child: Text(
                  widget.route.destination,
                  style: const TextStyle(color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        TimelineGraph(stops: widget.route.stops),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => setState(() => _isExpanded = false),
            child: const Text(
              'Tutup Detail',
              style: TextStyle(color: _textSecondary, fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }
}
