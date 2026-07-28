import 'package:flutter/material.dart';
import 'package:vibin_app/utils/theme_generator.dart';

import '../../../l10n/app_localizations.dart';
import '../../base_color_scheme_provider.dart';

class TokyoNightStormTheme extends BaseColorSchemeProvider {

  @override
  String getName(AppLocalizations lm) {
    return lm.settings_app_theme_tokyonight_storm_title;
  }

  @override
  bool get supportsBrightness => false;

  @override
  List<Color> getAccentColors(Brightness brightness) {
    return [
      Color(0xFFf7768e),
      Color(0xFFff9e64),
      Color(0xFFe0af68),
      Color(0xFF9ece6a),
      Color(0xFF73dacb),
      Color(0xFFb4f9f8),
      Color(0xFF2ac3de),
      Color(0xFF7dcfff),
      Color(0xFF7aa2f7),
      Color(0xFFbb9af7)
    ];
  }

  static final _spec = CustomThemeSpec(
    backgroundColor: Color(0xFF24283b),
    foregroundColor: Color(0xFFc0caf5),
    highestSurfaceColor: Color(0xFF454D6F),
    lowestSurfaceColor: Color(0xFF2C3148),
    errorColor: Color(0xFFf7768e),
    secondaryColor: Color(0xFF9aa5ce),
    brightness: Brightness.dark,
    backgroundOnPrimary: true,
    backgroundOnError: true,
    backgroundOnSecondary: true
  );

  @override
  ThemeData generateThemeData({required Color accentColor, required Brightness brightness}) {
    return ThemeGenerator.generateTheme(accentColor, _spec);
  }
}