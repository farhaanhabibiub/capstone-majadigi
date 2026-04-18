import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/transjatim_dummy_data.dart';
import '../models/transjatim_model.dart';

class HalteMapWidget extends StatefulWidget {
  const HalteMapWidget({super.key});

  @override
  State<HalteMapWidget> createState() => _HalteMapWidgetState();
}

class _HalteMapWidgetState extends State<HalteMapWidget> {
  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);

  TransjatimStop? _selected;
  final MapController _mapController = MapController();

  static const LatLng _jatimCenter = LatLng(-7.5361, 112.2384);

  List<TransjatimStop> get _stops => TransjatimDummyData.allStops;

  void _onMarkerTap(TransjatimStop stop) {
    setState(() => _selected = stop);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _jatimCenter,
              initialZoom: 8.0,
              minZoom: 6.0,
              maxZoom: 16.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.majadigi',
              ),
              MarkerLayer(
                markers: _stops.map((stop) {
                  final isSelected = _selected?.name == stop.name;
                  return Marker(
                    point: LatLng(stop.lat, stop.lng),
                    width: isSelected ? 44 : 32,
                    height: isSelected ? 44 : 32,
                    child: GestureDetector(
                      onTap: () => _onMarkerTap(stop),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : _blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: _blue, width: isSelected ? 3 : 0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.directions_bus_rounded,
                          color: isSelected ? _blue : Colors.white,
                          size: isSelected ? 22 : 16,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        if (_selected != null) _buildInfoSheet(_selected!),
      ],
    );
  }

  Widget _buildInfoSheet(TransjatimStop stop) {
    final routes = TransjatimDummyData.routesForStop(stop.name);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, -4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: _blue, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  stop.name,
                  style: const TextStyle(color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _selected = null),
                child: const Icon(Icons.close_rounded, color: _textSecondary, size: 20),
              ),
            ],
          ),
          if (routes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Dilalui ${routes.length} rute:',
              style: const TextStyle(color: _textSecondary, fontFamily: 'PlusJakartaSans', fontSize: 11),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: routes.map((r) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(235, 243, 255, 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${r.id} ${r.title}',
                  style: const TextStyle(color: _blue, fontFamily: 'PlusJakartaSans', fontSize: 11, fontWeight: FontWeight.w600),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
