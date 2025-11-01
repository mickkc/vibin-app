import 'dart:ui';

import 'package:vibin_app/settings/setting_definitions.dart';
import 'package:vibin_app/themes/impl/catppuccin_themes.dart';

import '../main.dart';
import '../settings/settings_manager.dart';
import 'base_color_scheme_provider.dart';
import 'impl/dracula_theme.dart';
import 'impl/gruvbox_theme.dart';
import 'impl/material3_theme.dart';
import 'impl/nord_theme.dart';
import 'impl/pywal/pywal_theme.dart';
import 'impl/solarized_theme.dart';

enum ColorSchemeKey {
  material3,
  gruvbox,
  catppuccinLatte,
  catppuccinFrappe,
  catppuccinMacchiato,
  catppuccinMocha,
  nord,
  dracula,
  solarized,
  pywal
}

class ColorSchemeList {

  static final Map<ColorSchemeKey, BaseColorSchemeProvider> _allSchemes = {
    ColorSchemeKey.material3: Material3Theme(),
    ColorSchemeKey.gruvbox: GruvboxTheme(),
    ColorSchemeKey.catppuccinLatte: CatppuccinLatteTheme(),
    ColorSchemeKey.catppuccinFrappe: CatppuccinFrappeTheme(),
    ColorSchemeKey.catppuccinMacchiato: CatppuccinMacchiatoTheme(),
    ColorSchemeKey.catppuccinMocha: CatppuccinMochaTheme(),
    ColorSchemeKey.nord: NordTheme(),
    ColorSchemeKey.dracula: DraculaTheme(),
    ColorSchemeKey.solarized: SolarizedTheme(),
    ColorSchemeKey.pywal: PywalTheme(),
  };

  static BaseColorSchemeProvider get(ColorSchemeKey key) {
    return _allSchemes[key]!;
  }

  static BaseColorSchemeProvider getCurrent() {
    final currentKey = getIt<SettingsManager>().get(Settings.colorScheme);
    return get(currentKey);
  }

  /// Validates the accent color for the given color scheme key and brightness.
  /// If the accent color is not supported by the scheme, it returns a valid accent color
  /// and updates the settings manager accordingly.
  static Color validateAccentColor(ColorSchemeKey key, Color accentColor, Brightness brightness) {
    final scheme = get(key);

    if (!scheme.supportsAccentColor) {
      return accentColor;
    }

    final accentColors = scheme.getAccentColors(brightness);
    if (accentColors.any((color) => color.toARGB32() == accentColor.toARGB32())) {
      return accentColor;
    } else {

      var newAccentColor = accentColors.first;

      final oldIndex = getAccentColorIndex(scheme, accentColor, brightness == Brightness.dark ? Brightness.light : Brightness.dark);
      if (oldIndex != null && oldIndex < accentColors.length) {
        newAccentColor = accentColors[oldIndex];
      }

      getIt<SettingsManager>().set(Settings.accentColor, newAccentColor);
      return newAccentColor;
    }
  }

  /// Returns the index of the accent color in the scheme's accent color list, or null if not found.
  static int? getAccentColorIndex(BaseColorSchemeProvider scheme, Color accentColor, Brightness brightness) {

    if (!scheme.supportsAccentColor) {
      return null;
    }

    final accentColors = scheme.getAccentColors(brightness);
    for (int i = 0; i < accentColors.length; i++) {
      if (accentColors[i].toARGB32() == accentColor.toARGB32()) {
        return i;
      }
    }
    return null;
  }

  /// Validates the color scheme key.
  /// If the key is not supported, it returns the default key (material3)
  /// and updates the settings manager accordingly.
  static ColorSchemeKey validateColorSchemeKey(ColorSchemeKey key) {
    if (_allSchemes.containsKey(key) && _allSchemes[key]!.isSupported()) {
      return key;
    } else {
      getIt<SettingsManager>().set(Settings.colorScheme, ColorSchemeKey.material3);
      return ColorSchemeKey.material3;
    }
  }
}