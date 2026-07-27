import 'package:flutter/material.dart';
import 'package:vibin_app/utils/theme_generator.dart';

import '../../../l10n/app_localizations.dart';
import '../../base_color_scheme_provider.dart';

class EvergardenWinterTheme extends BaseColorSchemeProvider {

  @override
  String getName(AppLocalizations lm) {
    return lm.settings_app_theme_evergarden_winter_title;
  }

  @override
  bool get supportsBrightness => false;

  @override
  List<Color> getAccentColors(Brightness brightness) {
    return [
      Color(0xFFf57f82),
      Color(0xFFf7a182),
      Color(0xFFf5d098),
      Color(0xFFdbe6af),
      Color(0xFFcbe3b3),
      Color(0xFFb3e3ca),
      Color(0xFFafd9e6),
      Color(0xFFb2caed),
      Color(0xFFd2bdf3),
      Color(0xFFf3c0e5),
      Color(0xFFfae6ef)
    ];
  }

  static final _spec = const CustomThemeSpec(
    backgroundColor: Color(0xFF1e2528),
    foregroundColor: Color(0xFFf8f9e8),
    highestSurfaceColor: Color(0xFF374145),
    lowestSurfaceColor: Color(0xFF262f33),
    errorColor: Color(0xFFf57f82),
    secondaryColor: Color(0xFF6f8788),
    brightness: Brightness.dark
  );

  @override
  ThemeData generateThemeData({required Color accentColor, required Brightness brightness}) {
    return ThemeGenerator.generateTheme(accentColor, _spec);
  }
}