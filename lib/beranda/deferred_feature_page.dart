import 'package:flutter/material.dart';

/// Wrapper widget yang me-load library Dart `deferred as` saat pertama kali
/// di-mount, lalu merender halaman fitur sesungguhnya. Setelah library di-load,
/// pemanggilan berikutnya untuk route yang sama instan (Dart meng-cache hasil
/// `loadLibrary`).
///
/// Dipakai oleh [AppRoutes] untuk fitur addable (Sapa Bansos, E-Tibi,
/// Klinik Hoaks, Open Data) sehingga kode-nya tidak ikut di-load ke memory
/// saat startup app — hanya saat user benar-benar membuka fitur tersebut.
class DeferredFeaturePage extends StatefulWidget {
  final Future<void> Function() loader;
  final WidgetBuilder builder;
  final String featureLabel;

  const DeferredFeaturePage({
    super.key,
    required this.loader,
    required this.builder,
    required this.featureLabel,
  });

  @override
  State<DeferredFeaturePage> createState() => _DeferredFeaturePageState();
}

class _DeferredFeaturePageState extends State<DeferredFeaturePage> {
  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _bg = Color.fromRGBO(248, 248, 245, 1);

  late Future<void> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.loader();
  }

  void _retry() {
    setState(() {
      _future = widget.loader();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _buildLoading();
        }
        if (snapshot.hasError) {
          return _buildError(snapshot.error);
        }
        return widget.builder(context);
      },
    );
  }

  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(_blue),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Memuat ${widget.featureLabel}…',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color.fromRGBO(80, 80, 80, 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(Object? error) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded,
                    size: 56, color: Color.fromRGBO(180, 180, 180, 1)),
                const SizedBox(height: 16),
                Text(
                  'Gagal memuat ${widget.featureLabel}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color.fromRGBO(32, 32, 32, 1),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Periksa koneksi internet Anda lalu coba lagi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    color: Color.fromRGBO(110, 110, 110, 1),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _retry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Coba Lagi',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
