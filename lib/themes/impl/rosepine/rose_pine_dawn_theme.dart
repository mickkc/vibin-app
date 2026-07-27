import 'package:flutter/material.dart';
import 'package:vibin_app/utils/theme_generator.dart';

import '../../../l10n/app_localizations.dart';
import '../../base_color_scheme_provider.dart';

class RosePineDawnTheme extends BaseColorSchemeProvider {

  @override
  String getName(AppLocalizations lm) {
    return lm.settings_app_theme_rosepine_dawn_title;
  }

  @override
  bool get supportsBrightness => false;

  @override
  List<Color> getAccentColors(Brightness brightness) {
    return [
      Color(0xFFb4637a),
      Color(0xFFea9d34),
      Color(0xFFd7827e),
      Color(0xFF286983),
      Color(0xFF56949f),
      Color(0xFF907aa9)
    ];
  }

  static final _spec = CustomThemeSpec(
    backgroundColor: Color(0xFFfaf4ed),
    foregroundColor: Color(0xFF464261),
    highestSurfaceColor: Color(0xFFf2e9e1),
    lowestSurfaceColor: Color(0xFFfffaf3),
    errorColor: Color(0xFFb4637a),
    secondaryColor: Color(0xFF797593),
    brightness: Brightness.light,
    backgroundOnPrimary: true,
    backgroundOnError: true,
    backgroundOnSecondary: true
  );

  @override
  ThemeData generateThemeData({required Color accentColor, required Brightness brightness}) {
    return ThemeGenerator.generateTheme(accentColor, _spec);
  }
}