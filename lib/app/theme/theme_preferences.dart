import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferences {
  static const _key = 'theme_mode';

  static Future<void> saveMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    // Encode: 0 system, 1 light, 2 dark
    final val = switch (mode) {
      ThemeMode.system => 0,
      ThemeMode.light => 1,
      ThemeMode.dark => 2,
    };
    await prefs.setInt(_key, val);
  }

  static Future<ThemeMode?> loadMode() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getInt(_key);
    return switch (val) {
      0 => ThemeMode.system,
      1 => ThemeMode.light,
      2 => ThemeMode.dark,
      _ => null,
    };
  }
}
