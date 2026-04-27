import 'package:flutter/material.dart';

/// Komponen skeleton loader konsisten untuk seluruh aplikasi.
///
/// Pemakaian:
/// ```dart
/// // Layout siap pakai:
/// const SkeletonLoader.list();
/// const SkeletonLoader.form();
/// const SkeletonLoader.grid();
/// const SkeletonLoader.dashboard();
///
/// // Custom — bungkus sendiri pakai [SkeletonBox]:
/// SkeletonLoader(child: Column(children: [SkeletonBox(height: 80)]));
/// ```
class SkeletonLoader extends StatelessWidget {
  final Widget child;

  const SkeletonLoader({super.key, required this.child});

  /// Skeleton untuk halaman berbentuk list (notifikasi, favorit, riwayat).
  SkeletonLoader.list({
    super.key,
    int itemCount = 6,
    bool hasLeading = true,
  }) : child = _SkeletonListChild(
          itemCount: itemCount,
          hasLeading: hasLeading,
        );

  /// Skeleton untuk halaman berbentuk form / filter (BAPENDA, RSUD info antrean).
  SkeletonLoader.form({super.key, int fieldCount = 4})
      : child = _SkeletonFormChild(fieldCount: fieldCount);

  /// Skeleton untuk halaman dashboard (banner + stat + card).
  /// Cocok untuk RSUD ketersediaan kamar & jadwal operasi.
  const SkeletonLoader.dashboard({super.key})
      : child = const _SkeletonDashboardChild();

  /// Skeleton untuk halaman berbentuk grid (tambah layanan).
  SkeletonLoader.grid({
    super.key,
    int itemCount = 9,
    int crossAxisCount = 3,
  }) : child = _SkeletonGridChild(
          itemCount: itemCount,
          crossAxisCount: crossAxisCount,
        );

  @override
  Widget build(BuildContext context) {
    return _Shimmer(child: child);
  }
}

/// Primitive box untuk membentuk skeleton kustom.
/// Harus berada di bawah [SkeletonLoader] agar mendapat efek shimmer.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;
  final EdgeInsetsGeometry? margin;
  final BoxShape shape;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.radius = 8,
    this.margin,
    this.shape = BoxShape.rectangle,
  });

  const SkeletonBox.circle({
    super.key,
    required double size,
    this.margin,
  })  : width = size,
        height = size,
        radius = 0,
        shape = BoxShape.circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: _baseColor,
        shape: shape,
        borderRadius:
            shape == BoxShape.rectangle ? BorderRadius.circular(radius) : null,
      ),
    );
  }
}

// ── Internal: warna & animasi shimmer ────────────────────────────────────────

const Color _baseColor = Color(0xFFE3E5EA);
const Color _highlightColor = Color(0xFFF4F5F8);

class _Shimmer extends StatefulWidget {
  final Widget child;
  const _Shimmer({required this.child});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [_baseColor, _highlightColor, _baseColor],
              stops: const [0.35, 0.5, 0.65],
              transform:
                  _SlidingGradientTransform(slidePercent: _ctrl.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * (slidePercent * 2 - 1),
      0,
      0,
    );
  }
}

// ── Layout siap pakai ────────────────────────────────────────────────────────

class _SkeletonListChild extends StatelessWidget {
  final int itemCount;
  final bool hasLeading;
  const _SkeletonListChild({
    required this.itemCount,
    required this.hasLeading,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => _listTile(),
    );
  }

  Widget _listTile() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasLeading) ...[
            const SkeletonBox.circle(size: 38),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(width: 160, height: 12),
                SizedBox(height: 8),
                SkeletonBox(width: double.infinity, height: 10),
                SizedBox(height: 6),
                SkeletonBox(width: 120, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonFormChild extends StatelessWidget {
  final int fieldCount;
  const _SkeletonFormChild({required this.fieldCount});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerCard(),
          const SizedBox(height: 24),
          for (var i = 0; i < fieldCount; i++) ...[
            const SkeletonBox(width: 120, height: 11),
            const SizedBox(height: 8),
            const SkeletonBox(
              width: double.infinity,
              height: 48,
              radius: 12,
            ),
            const SizedBox(height: 18),
          ],
          const SizedBox(height: 4),
          const SkeletonBox(
            width: double.infinity,
            height: 50,
            radius: 999,
          ),
        ],
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: const [
          SkeletonBox.circle(size: 44),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 160, height: 13),
                SizedBox(height: 8),
                SkeletonBox(width: 110, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonDashboardChild extends StatelessWidget {
  const _SkeletonDashboardChild();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner ringkasan
          const SkeletonBox(
            width: double.infinity,
            height: 110,
            radius: 20,
          ),
          const SizedBox(height: 16),
          // Stat row (3 kotak)
          Row(
            children: const [
              Expanded(child: SkeletonBox(height: 78, radius: 14)),
              SizedBox(width: 10),
              Expanded(child: SkeletonBox(height: 78, radius: 14)),
              SizedBox(width: 10),
              Expanded(child: SkeletonBox(height: 78, radius: 14)),
            ],
          ),
          const SizedBox(height: 20),
          // Card konten
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(width: 140, height: 13),
                const SizedBox(height: 14),
                for (var i = 0; i < 4; i++) ...[
                  Row(
                    children: const [
                      SkeletonBox(width: 120, height: 11),
                      Spacer(),
                      SkeletonBox(width: 50, height: 11),
                    ],
                  ),
                  if (i < 3) const SizedBox(height: 14),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonGridChild extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  const _SkeletonGridChild({
    required this.itemCount,
    required this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (_, _) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SkeletonBox.circle(size: 40),
            SizedBox(height: 12),
            SkeletonBox(width: 60, height: 9),
            SizedBox(height: 6),
            SkeletonBox(width: 40, height: 9),
          ],
        ),
      ),
    );
  }
}
