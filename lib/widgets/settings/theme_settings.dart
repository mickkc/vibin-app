import 'package:flutter/material.dart';

import '../../themes/color_scheme_list.dart';

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
    ).validate();
  }

  ThemeSettings setColorSchemeKey(ColorSchemeKey key) {
    return ThemeSettings(
      themeMode: themeMode,
      accentColor: accentColor,
      colorSchemeKey: key,
    ).validate();
  }

  ThemeSettings validate() {
    final validColorSchemeKey = ColorSchemeList.validateColorSchemeKey(colorSchemeKey);
    final validAccentColor = ColorSchemeList.validateAccentColor(validColorSchemeKey, accentColor);
    return ThemeSettings(
      themeMode: themeMode,
      accentColor: validAccentColor,
      colorSchemeKey: validColorSchemeKey,
    );
  }
}