import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'app_route.dart';
import 'auth_service.dart';

class PersonalizationLocationPage extends StatefulWidget {
  const PersonalizationLocationPage({super.key});

  @override
  State<PersonalizationLocationPage> createState() =>
      _PersonalizationLocationPageState();
}

class _PersonalizationLocationPageState
    extends State<PersonalizationLocationPage> {
  bool _isSubmitting = false;
  String? _city;
  String? _regency;
  String? _province;

  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _whiteBg = Color.fromRGBO(248, 248, 245, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);
  static const Color _borderGray = Color.fromRGBO(210, 210, 210, 1);

  Future<void> _handleEnableLocation() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Layanan lokasi belum aktif. Silakan aktifkan lokasi.'),
          ),
        );
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin lokasi ditolak.'),
          ),
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Izin lokasi ditolak permanen. Buka pengaturan aplikasi untuk mengaktifkannya.',
            ),
          ),
        );
        await Geolocator.openAppSettings();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lokasi ditemukan, tetapi detail wilayah tidak tersedia.'),
          ),
        );
        return;
      }

      final place = placemarks.first;

      final province = _pickFirstNonEmpty([
        place.administrativeArea,
        place.subAdministrativeArea,
      ]);

      final regency = _pickFirstNonEmpty([
        place.subAdministrativeArea,
        place.locality,
        place.subLocality,
      ]);

      final city = _pickFirstNonEmpty([
        place.locality,
        place.subAdministrativeArea,
        place.subLocality,
      ]);

      final result = await AuthService.instance.saveUserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        city: city,
        regency: regency,
        province: province,
        source: 'gps',
      );

      if (!mounted) return;

      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message)),
        );
        return;
      }

      setState(() {
        _city = city;
        _regency = regency;
        _province = province;
      });

      _goToServicePage();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil lokasi: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _goToManualLocationPage() async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.locationManualPage,
    );

    if (result is! Map<String, dynamic>) return;

    setState(() {
      _city = result['city'] as String?;
      _regency = result['regency'] as String?;
      _province = result['province'] as String?;
    });

    if (!mounted) return;

    _goToServicePage();
  }

  void _goToServicePage() {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.personalizationServicesPage,
    );
  }

  String? _pickFirstNonEmpty(List<String?> values) {
    for (final value in values) {
      final trimmed = value?.trim() ?? '';
      if (trimmed.isNotEmpty) return trimmed;
    }
    return null;
  }

  String _formatLocationPreview(String? city, String? regency, String? province) {
    final parts = [
      if ((city ?? '').trim().isNotEmpty) city!.trim(),
      if ((regency ?? '').trim().isNotEmpty) regency!.trim(),
      if ((province ?? '').trim().isNotEmpty) province!.trim(),
    ];
    return parts.isEmpty ? '-' : parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final locationPreview = _formatLocationPreview(_city, _regency, _province);

    return Scaffold(
      backgroundColor: _whiteBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: _StepProgressIndicator(
                      currentStep: 1,
                      totalSteps: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _isSubmitting ? null : _goToServicePage,
                    child: const Text(
                      'Lewati',
                      style: TextStyle(
                        color: _blue,
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const Text(
                'LANGKAH 1/2',
                style: TextStyle(
                  color: _blue,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Izinkan Lokasi Anda',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textPrimary,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Aktifkan lokasi untuk menampilkan layanan\npublik yang tersedia di wilayah Anda',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textSecondary,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/personalization_location_map.png',
                    width: 240,
                    height: 240,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        width: 240,
                        height: 240,
                        child: Icon(
                          Icons.location_on_outlined,
                          size: 110,
                          color: _blue,
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (locationPreview != '-') ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _borderGray),
                  ),
                  child: Text(
                    locationPreview,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _textPrimary,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleEnableLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _blue,
                    disabledBackgroundColor:
                    const Color.fromRGBO(210, 210, 210, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _isSubmitting ? 'Memproses...' : 'Aktifkan Lokasi',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: _isSubmitting ? null : _goToManualLocationPage,
                child: const Text(
                  'Pilih Lokasi Manual',
                  style: TextStyle(
                    color: _blue,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepProgressIndicator({
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index < currentStep;
        return Expanded(
          child: Container(
            height: 6,
            margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 6),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color.fromRGBO(0, 101, 255, 1)
                  : const Color.fromRGBO(210, 210, 210, 1),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }
}

