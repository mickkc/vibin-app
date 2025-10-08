import 'package:flutter/material.dart';

class ThemeSettings {
  ThemeMode themeMode;
  Color? accentColor;

  ThemeSettings({this.themeMode = ThemeMode.system, this.accentColor});

  ThemeSettings setThemeMode(ThemeMode mode) {
    return ThemeSettings(
      themeMode: mode,
      accentColor: accentColor,
    );
  }

  ThemeSettings setAccentColor(Color? color) {
    return ThemeSettings(
      themeMode: themeMode,
      accentColor: color,
    );
  }
}