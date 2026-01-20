// lib/widgets/sun_rise_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeModePrefKey = 'planit_theme_mode';

class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.light) {
    _loadFromPrefs();
  }

  /// Toggle between light and dark (keeps system out of the flow for simplicity)
  void toggle() {
    if (state == ThemeMode.dark) {
      set(ThemeMode.light);
    } else {
      set(ThemeMode.dark);
    }
  }

  /// Set explicit theme mode and persist it
  Future<void> set(ThemeMode mode) async {
    if (mode == state) return;
    state = mode;
    await _saveToPrefs(mode);
  }

  Future<void> _saveToPrefs(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = _encode(mode);
      await prefs.setString(_kThemeModePrefKey, value);
    } catch (_) {
      // ignore errors (best-effort persistence)
    }
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final s = prefs.getString(_kThemeModePrefKey);
      if (s != null) {
        final mode = _decode(s);
        state = mode;
      } else {
        // default: light (match your app preference)
        state = ThemeMode.light;
      }
    } catch (_) {
      // ignore; default remains
    }
  }

  String _encode(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
      default:
        return 'system';
    }
  }

  ThemeMode _decode(String s) {
    switch (s) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeController, ThemeMode>((ref) {
  return ThemeController();
});
