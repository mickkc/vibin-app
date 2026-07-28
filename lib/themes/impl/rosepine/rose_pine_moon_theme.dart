import 'package:flutter/material.dart';
import 'package:vibin_app/utils/theme_generator.dart';

import '../../../l10n/app_localizations.dart';
import '../../base_color_scheme_provider.dart';

class RosePineMoonTheme extends BaseColorSchemeProvider {

  @override
  String getName(AppLocalizations lm) {
    return lm.settings_app_theme_rosepine_moon_title;
  }

  @override
  bool get supportsBrightness => false;

  @override
  List<Color> getAccentColors(Brightness brightness) {
    return [
      Color(0xFFeb6f92),
      Color(0xFFf6c177),
      Color(0xFFea9a97),
      Color(0xFF3e8fb0),
      Color(0xFF9ccfd8),
      Color(0xFFc4a7e7)
    ];
  }

  static final _spec = CustomThemeSpec(
    backgroundColor: Color(0xFF232136),
    foregroundColor: Color(0xFFe0def4),
    highestSurfaceColor: Color(0xFF393552),
    lowestSurfaceColor: Color(0xFF393552),
    errorColor: Color(0xFFeb6f92),
    secondaryColor: Color(0xFF908caa),
    brightness: Brightness.dark
  );

  @override
  ThemeData generateThemeData({required Color accentColor, required Brightness brightness}) {
    return ThemeGenerator.generateTheme(accentColor, _spec);
  }
}