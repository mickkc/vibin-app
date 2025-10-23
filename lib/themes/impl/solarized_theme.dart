import 'package:flutter/material.dart';
import 'package:vibin_app/utils/theme_generator.dart';

import '../../l10n/app_localizations.dart';
import '../base_color_scheme_provider.dart';

class SolarizedTheme extends BaseColorSchemeProvider {

  @override
  String getName(AppLocalizations lm) {
    return lm.settings_app_theme_solarized_title;
  }

  @override
  List<Color> getAccentColors(Brightness brightness) {
    return [
      Color(0xFFb58900),
      Color(0xFFcb4b16),
      Color(0xFFdc322f),
      Color(0xFFd33682),
      Color(0xFF6c71c4),
      Color(0xFF268bd2),
      Color(0xFF2aa198),
      Color(0xFF859900)
    ];
  }
  
  static final _darkSpec = const CustomThemeSpec(
    backgroundColor: Color(0xFF002b36),
    foregroundColor: Color(0xFFfdf6e3),
    highestSurfaceColor: Color(0xFF586e75),
    lowestSurfaceColor: Color(0xFF073642),
    errorColor: Color(0xFFdc322f),
    secondaryColor: Color(0xFF93a1a1),
    brightness: Brightness.dark
  );

  static final _lightSpec = const CustomThemeSpec(
    backgroundColor: Color(0xFFfdf6e3),
    foregroundColor: Color(0xFF002b36),
    highestSurfaceColor: Color(0xFFeee8d5),
    lowestSurfaceColor: Color(0xFFeee8d5),
    errorColor: Color(0xFFdc322f),
    secondaryColor: Color(0xFF93a1a1),
    brightness: Brightness.light,
    backgroundOnPrimary: true,
    backgroundOnSecondary: true,
    backgroundOnError: true
  );

  @override
  ThemeData generateThemeData({required Color accentColor, required Brightness brightness}) {

    final spec = brightness == Brightness.light ? _lightSpec : _darkSpec;

    return ThemeGenerator.generateTheme(accentColor, spec);
  }
}