import 'dart:async';
import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_retry.dart';
import '../widgets/skeleton_loader.dart';
import 'service_registry.dart';

class TambahLayananPage extends StatefulWidget {
  const TambahLayananPage({super.key});

  @override
  State<TambahLayananPage> createState() => _TambahLayananPageState();
}

class _TambahLayananPageState extends State<TambahLayananPage> {
  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _whiteBg = Color.fromRGBO(248, 248, 245, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);

  List<String> _alreadyAdded = [];
  final Set<int> _selected = {};
  bool _isLoading = true;
  bool _isSaving = false;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _loadAlreadyAdded();
  }

  Future<void> _loadAlreadyAdded() async {
    try {
      final ids = await AuthService.instance.fetchAddedServices();
      if (!mounted) return;
      setState(() {
        _alreadyAdded = ids;
        _loadError = null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e;
        _isLoading = false;
      });
    }
  }

  Future<void> _retryLoad() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    await _loadAlreadyAdded();
  }

  List<AddableService> get _availableItems => ServiceRegistry.all
      .where((s) => !_alreadyAdded.contains(s.id))
      .toList();

  Future<void> _onTambah() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final newIds = _selected.map((i) => _availableItems[i].id).toList();
    final allIds = [..._alreadyAdded, ...newIds];
    await AuthService.instance.saveAddedServices(allIds);

    if (!mounted) return;
    setState(() => _isSaving = false);

    await Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.45),
        pageBuilder: (_, _, _) => const _TambahSuccessOverlay(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _whiteBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: _textPrimary),
        ),
        title: const Text(
          'Tambah Layanan',
          style: TextStyle(
            color: _textPrimary,
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _isLoading
          ? SkeletonLoader.grid(itemCount: 9)
          : _loadError != null
              ? ErrorRetry(
                  title: 'Gagal memuat daftar layanan',
                  subtitle: ErrorRetry.fromException(_loadError!),
                  onRetry: _retryLoad,
                )
              : Column(
              children: [
                Expanded(
                  child: _availableItems.isEmpty
                      ? EmptyState(
                          icon: Icons.check_circle_outline_rounded,
                          title: 'Semua layanan sudah ditambahkan',
                          subtitle:
                              'Anda telah menambahkan semua layanan yang tersedia.\nKelola lewat tab Favorit di Beranda.',
                          actionLabel: 'Kembali',
                          onAction: () => Navigator.pop(context),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          itemCount: _availableItems.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.9,
                          ),
                          itemBuilder: (context, index) =>
                              _buildItemCard(index),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          (_selected.isEmpty || _isSaving) ? null : _onTambah,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _blue,
                        disabledBackgroundColor:
                            const Color.fromRGBO(210, 210, 210, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            )
                          : const Text(
                              'Tambah',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildItemCard(int index) {
    final item = _availableItems[index];
    final isSelected = _selected.contains(index);

    return GestureDetector(
      onTap: () => setState(() {
        if (isSelected) {
          _selected.remove(index);
        } else {
          _selected.add(index);
        }
      }),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: isSelected ? Border.all(color: _blue, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(235, 243, 255, 1),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                item.assetPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(item.fallback, color: _blue, size: 26),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _textPrimary,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Success overlay ───────────────────────────────────────────────────────────

class _TambahSuccessOverlay extends StatefulWidget {
  const _TambahSuccessOverlay();

  @override
  State<_TambahSuccessOverlay> createState() => _TambahSuccessOverlayState();
}

class _TambahSuccessOverlayState extends State<_TambahSuccessOverlay> {
  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _whiteBg = Color.fromRGBO(248, 248, 245, 1);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: _whiteBg,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/personalization_success.png',
                    width: 170,
                    height: 170,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 170,
                      height: 170,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromRGBO(235, 243, 255, 1),
                      ),
                      child: const Center(
                        child: CircleAvatar(
                          radius: 42,
                          backgroundColor: _blue,
                          child: Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 46,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Berhasil Ditambahkan!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _blue,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(_blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
