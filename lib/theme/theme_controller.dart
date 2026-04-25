import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  ThemeController._();

  static const _key = 'is_dark_mode';
  static final notifier = ValueNotifier<ThemeMode>(ThemeMode.light);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_key) ?? false;
    notifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static bool get isDark => notifier.value == ThemeMode.dark;

  static Future<void> setDark(bool value) async {
    notifier.value = value ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }
}
