import 'package:flutter/material.dart';
import 'package:vibin_app/utils/theme_generator.dart';

import '../../../l10n/app_localizations.dart';
import '../../base_color_scheme_provider.dart';

class TokyoNightTheme extends BaseColorSchemeProvider {

  @override
  String getName(AppLocalizations lm) {
    return lm.settings_app_theme_tokyonight_title;
  }

  @override
  List<Color> getAccentColors(Brightness brightness) {
    if (brightness == Brightness.light) {
      return [
        Color(0xFF8c4351),
        Color(0xFF965027),
        Color(0xFF8f5e15),
        Color(0xFF634f30),
        Color(0xFF385f0d),
        Color(0xFF33635c),
        Color(0xFF006c86),
        Color(0xFF0f4b6e),
        Color(0xFF2959aa),
        Color(0xFF5a3e8e)
      ];
    }

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

  static final _darkSpec = CustomThemeSpec(
    backgroundColor: Color(0xFF1a1b26),
    foregroundColor: Color(0xFFc0caf5),
    highestSurfaceColor: Color(0xFF343952),
    lowestSurfaceColor: Color(0xFF212331),
    errorColor: Color(0xFFf7768e),
    secondaryColor: Color(0xFF9aa5ce),
    brightness: Brightness.dark,
    backgroundOnPrimary: true,
    backgroundOnError: true,
    backgroundOnSecondary: true
  );

  static final _lightSpec = CustomThemeSpec(
    backgroundColor: Color(0xFFe6e7ed),
    foregroundColor: Color(0xFF343b58),
    highestSurfaceColor: Color(0xFFBABBC1),
    lowestSurfaceColor: Color(0xFFDBDCE2),
    errorColor: Color(0xFF8c4351),
    secondaryColor: Color(0xFF6c6e75),
    brightness: Brightness.light,
    backgroundOnPrimary: true,
    backgroundOnError: true,
    backgroundOnSecondary: true
  );

  @override
  ThemeData generateThemeData({required Color accentColor, required Brightness brightness}) {

    final spec = brightness == Brightness.light ? _lightSpec : _darkSpec;

    return ThemeGenerator.generateTheme(accentColor, spec);
  }
}