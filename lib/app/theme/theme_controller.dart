import 'package:flutter/material.dart';
import 'theme_preferences.dart';

class ThemeController {
  ThemeController._internal();
  static final ThemeController instance = ThemeController._internal();

  // Current theme mode notifier
  final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.system);

  Future<void> load() async {
    final saved = await ThemePreferences.loadMode();
    mode.value = saved ?? ThemeMode.system;
  }

  Future<void> set(ThemeMode newMode) async {
    mode.value = newMode;
    await ThemePreferences.saveMode(newMode);
  }
}
