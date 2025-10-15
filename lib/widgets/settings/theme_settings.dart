import 'package:flutter/material.dart';
import 'package:vibin_app/color_schemes/color_scheme_list.dart';

class ThemeSettings {
  ThemeMode themeMode;
  Color accentColor;
  ColorSchemeKey colorSchemeKey;

  ThemeSettings({this.themeMode = ThemeMode.system, this.accentColor = Colors.green, this.colorSchemeKey = ColorSchemeKey.material3});

  ThemeSettings setThemeMode(ThemeMode mode) {
    return ThemeSettings(
      themeMode: mode,
      accentColor: accentColor,
      colorSchemeKey: colorSchemeKey,
    );
  }

  ThemeSettings setAccentColor(Color color) {
    return ThemeSettings(
      themeMode: themeMode,
      accentColor: color,
      colorSchemeKey: colorSchemeKey,
    );
  }

  ThemeSettings setColorSchemeKey(ColorSchemeKey key) {
    return ThemeSettings(
      themeMode: themeMode,
      accentColor: accentColor,
      colorSchemeKey: key,
    );
  }
}