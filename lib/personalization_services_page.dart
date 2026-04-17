import 'package:flutter/material.dart';

import 'app_route.dart';
import 'auth_service.dart';

class PersonalizationServicesPage extends StatefulWidget {
  const PersonalizationServicesPage({super.key});

  @override
  State<PersonalizationServicesPage> createState() =>
      _PersonalizationServicesPageState();
}

class _PersonalizationServicesPageState
    extends State<PersonalizationServicesPage> {
  bool _isSubmitting = false;
  final Set<String> _selectedIds = <String>{};

  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _whiteBg = Color.fromRGBO(248, 248, 245, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);
  static const Color _cardBorder = Color.fromRGBO(224, 224, 224, 1);
  static const Color _selectedBg = Color.fromRGBO(236, 245, 255, 1);

  static const List<_ServiceOption> _services = [
    _ServiceOption(
      id: 'mobilitas',
      title: 'Mobilitas',
      assetPath: 'assets/images/feature_mobilitas.png',
      fallbackIcon: Icons.directions_car_filled_rounded,
    ),
    _ServiceOption(
      id: 'ekonomi',
      title: 'Ekonomi',
      assetPath: 'assets/images/feature_ekonomi.png',
      fallbackIcon: Icons.payments_rounded,
    ),
    _ServiceOption(
      id: 'pekerjaan',
      title: 'Pekerjaan',
      assetPath: 'assets/images/feature_pekerjaan.png',
      fallbackIcon: Icons.work_rounded,
    ),
    _ServiceOption(
      id: 'kesehatan',
      title: 'Kesehatan',
      assetPath: 'assets/images/feature_kesehatan.png',
      fallbackIcon: Icons.local_hospital_rounded,
    ),
    _ServiceOption(
      id: 'sosial',
      title: 'Sosial',
      assetPath: 'assets/images/feature_sosial.png',
      fallbackIcon: Icons.handshake_rounded,
    ),
    _ServiceOption(
      id: 'pemerintahan',
      title: 'Pemerintahan',
      assetPath: 'assets/images/feature_pemerintahan.png',
      fallbackIcon: Icons.account_balance_rounded,
    ),
    _ServiceOption(
      id: 'keamanan',
      title: 'Keamanan',
      assetPath: 'assets/images/feature_keamanan.png',
      fallbackIcon: Icons.shield_rounded,
    ),
  ];

  void _toggleService(String id) {
    if (_isSubmitting) return;

    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _submit({required bool skipped}) async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final selectedServices = _services
          .where((item) => _selectedIds.contains(item.id))
          .toList();

      final result = await AuthService.instance.saveUserServicePreferences(
        serviceIds: selectedServices.map((e) => e.id).toList(),
        serviceNames: selectedServices.map((e) => e.title).toList(),
      );

      if (!mounted) return;

      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message)),
        );
        return;
      }

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.personalizationSuccessPage,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildServiceCard(_ServiceOption item) {
    final isSelected = _selectedIds.contains(item.id);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleService(item.id),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? _selectedBg : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? _blue : _cardBorder,
              width: isSelected ? 1.4 : 1,
            ),
            boxShadow: isSelected
                ? [
              const BoxShadow(
                color: Color.fromRGBO(0, 101, 255, 0.08),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 34,
                height: 34,
                child: Image.asset(
                  item.assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) {
                    return Icon(
                      item.fallbackIcon,
                      size: 28,
                      color: isSelected ? _blue : _textPrimary,
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _textPrimary,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _whiteBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: _StepProgressIndicator(
                      currentStep: 2,
                      totalSteps: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _isSubmitting ? null : () => _submit(skipped: true),
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
              const SizedBox(height: 34),
              const Text(
                'LANGKAH 2/2',
                style: TextStyle(
                  color: _blue,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pilih Layanan yang Dibutuhkan',
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
                'Kami akan menampilkan layanan yang paling\nrelevan di beranda Anda',
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
                child: SingleChildScrollView(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _services.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.82,
                    ),
                    itemBuilder: (context, index) {
                      final item = _services[index];
                      return _buildServiceCard(item);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : () => _submit(skipped: false),
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
                    _isSubmitting ? 'Menyimpan...' : 'Mulai',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
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

class _ServiceOption {
  final String id;
  final String title;
  final String assetPath;
  final IconData fallbackIcon;

  const _ServiceOption({
    required this.id,
    required this.title,
    required this.assetPath,
    required this.fallbackIcon,
  });
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