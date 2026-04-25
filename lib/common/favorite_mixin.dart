import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'favorite_service.dart';

/// Mixin untuk `State` yang butuh tombol favorit (simpan/buka).
///
/// Subclass wajib override [favoriteKey] dan [favoriteLabel]. Mixin akan:
/// 1. Load status favorit saat initState.
/// 2. Sediakan [toggleFavorite] untuk ganti status + tampilkan snackbar.
///
/// Pemakaian:
/// ```dart
/// class _FooPageState extends State<FooPage> with FavoriteMixin {
///   @override
///   String get favoriteKey => 'fav_foo';
///   @override
///   String get favoriteLabel => 'FOO';
/// }
/// ```
mixin FavoriteMixin<T extends StatefulWidget> on State<T> {
  bool _isFavorite = false;

  bool get isFavorite => _isFavorite;

  String get favoriteKey;

  String get favoriteLabel;

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final value = await FavoriteService.isFavorite(favoriteKey);
    if (!mounted) return;
    setState(() => _isFavorite = value);
  }

  Future<void> toggleFavorite() async {
    final next = !_isFavorite;
    await FavoriteService.setFavorite(favoriteKey, next);
    if (!mounted) return;
    setState(() => _isFavorite = next);
    showFavoriteSnackBar(
      context: context,
      added: next,
      label: favoriteLabel,
    );
  }
}

void showFavoriteSnackBar({
  required BuildContext context,
  required bool added,
  required String label,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      backgroundColor: added ? AppTheme.primary : AppTheme.neutralDark,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
      content: Row(
        children: [
          Icon(
            added ? Icons.bookmark_rounded : Icons.bookmark_remove_rounded,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              added
                  ? '$label ditambahkan ke favorit'
                  : '$label dihapus dari favorit',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: AppTheme.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
