import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FontScaleOption {
  small(0.85, 'Kecil'),
  normal(1.0, 'Normal'),
  large(1.15, 'Besar'),
  extraLarge(1.3, 'Sangat Besar');

  final double scale;
  final String label;
  const FontScaleOption(this.scale, this.label);
}

class FontScaleController {
  FontScaleController._();

  static const _key = 'font_scale_option';
  static final notifier = ValueNotifier<FontScaleOption>(FontScaleOption.normal);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    notifier.value = FontScaleOption.values.firstWhere(
      (o) => o.name == stored,
      orElse: () => FontScaleOption.normal,
    );
  }

  static FontScaleOption get current => notifier.value;

  static Future<void> set(FontScaleOption option) async {
    notifier.value = option;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, option.name);
  }
}
