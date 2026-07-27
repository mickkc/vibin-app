import 'package:flutter/material.dart';
import 'package:vibin_app/utils/theme_generator.dart';

import '../../../l10n/app_localizations.dart';
import '../../base_color_scheme_provider.dart';

class EvergardenSummerTheme extends BaseColorSchemeProvider {

  @override
  String getName(AppLocalizations lm) {
    return lm.settings_app_theme_evergarden_summer_title;
  }

  @override
  bool get supportsBrightness => false;

  @override
  List<Color> getAccentColors(Brightness brightness) {
    return [
      Color(0xFFc58687),
      Color(0xFFc69883),
      Color(0xFFc4aa80),
      Color(0xFFabb182),
      Color(0xFF91a77a),
      Color(0xFF719f96),
      Color(0xFF7799a3),
      Color(0xFF8294ad),
      Color(0xFFa897b8),
      Color(0xFFc499b8),
      Color(0xFFc29fb2)
    ];
  }

  static final _spec = const CustomThemeSpec(
    backgroundColor: Color(0xFFf5efe6),
    foregroundColor: Color(0xFF2b3034),
    highestSurfaceColor: Color(0xFFe6e1d3),
    lowestSurfaceColor: Color(0xFFede8dd),
    errorColor: Color(0xFFc58687),
    secondaryColor: Color(0xFF829084),
    brightness: Brightness.light,
    backgroundOnSecondary: true,
    backgroundOnError: true,
    backgroundOnPrimary: true
  );

  @override
  ThemeData generateThemeData({required Color accentColor, required Brightness brightness}) {
    return ThemeGenerator.generateTheme(accentColor, _spec);
  }
}