import 'package:flutter/material.dart';

import '../../main.dart';
import '../../settings/setting_definitions.dart';
import '../../settings/settings_manager.dart';
import '../../themes/color_scheme_list.dart';

class ThemeSettings {
  ThemeMode themeMode;
  Color accentColor;
  ColorSchemeKey colorSchemeKey;
  Locale? locale;

  ThemeSettings({
    this.themeMode = ThemeMode.system,
    this.accentColor = Colors.green,
    this.colorSchemeKey = ColorSchemeKey.material3,
    this.locale
  });

  ThemeSettings setThemeMode(ThemeMode mode) {
    return ThemeSettings(
      themeMode: mode,
      accentColor: accentColor,
      colorSchemeKey: colorSchemeKey,
      locale: locale
    );
  }

  ThemeSettings setAccentColor(Color color) {
    return ThemeSettings(
      themeMode: themeMode,
      accentColor: color,
      colorSchemeKey: colorSchemeKey,
      locale: locale
    );
  }

  ThemeSettings setColorSchemeKey(ColorSchemeKey key) {
    return ThemeSettings(
      themeMode: themeMode,
      accentColor: accentColor,
      colorSchemeKey: key,
      locale: locale
    );
  }

  ThemeSettings setLanguage(Locale? newLocale) {
    return ThemeSettings(
      themeMode: themeMode,
      accentColor: accentColor,
      colorSchemeKey: colorSchemeKey,
      locale: newLocale
    );
  }

  ThemeSettings validate(BuildContext context) {

    final brightness = switch (themeMode) {
      ThemeMode.system => MediaQuery.of(context).platformBrightness,
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
    };

    final validColorSchemeKey = ColorSchemeList.validateColorSchemeKey(colorSchemeKey);
    final validAccentColor = ColorSchemeList.validateAccentColor(validColorSchemeKey, accentColor, brightness);

    if (validColorSchemeKey == colorSchemeKey && validAccentColor == accentColor) {
      return this;
    }

    final settingsManager = getIt<SettingsManager>();
    settingsManager.set(Settings.colorScheme, validColorSchemeKey);
    settingsManager.set(Settings.accentColor, validAccentColor);

    return ThemeSettings(
      themeMode: themeMode,
      accentColor: validAccentColor,
      colorSchemeKey: validColorSchemeKey,
      locale: locale
    );
  }
}