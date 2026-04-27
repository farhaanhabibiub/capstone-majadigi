import 'package:flutter/material.dart';

/// Tag konstan untuk Hero animation lintas halaman.
/// Menjaga string tag tetap konsisten antar halaman pemanggil dan tujuan.
class HeroTags {
  HeroTags._();

  static const String profileAvatar = 'hero_profile_avatar';
  static String serviceCard(String id) => 'hero_service_card_$id';
}

/// Page route dengan transisi slide dari kanan + fade halus.
/// Digunakan untuk navigasi forward antar halaman utama.
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  SlidePageRoute({
    required WidgetBuilder builder,
    super.settings,
  }) : super(
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 220),
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(curved),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.4, end: 1.0).animate(curved),
                child: child,
              ),
            );
          },
        );
}

/// Page route dengan transisi fade — cocok untuk modal/dialog full-screen,
/// halaman search, dan layar yang muncul "menumpuk" tanpa arah spasial.
class FadePageRoute<T> extends PageRouteBuilder<T> {
  FadePageRoute({
    required WidgetBuilder builder,
    super.settings,
    super.opaque = true,
  }) : super(
          transitionDuration: const Duration(milliseconds: 220),
          reverseTransitionDuration: const Duration(milliseconds: 180),
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
                reverseCurve: Curves.easeIn,
              ),
              child: child,
            );
          },
        );
}
