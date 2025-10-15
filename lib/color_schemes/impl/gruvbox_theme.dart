import 'package:flutter/material.dart';
import 'package:vibin_app/color_schemes/base_color_scheme_provider.dart';
import 'package:vibin_app/utils/theme_generator.dart';

import '../../l10n/app_localizations.dart';

class GruvboxTheme extends BaseColorSchemeProvider {

  @override
  String get id => "gruvbox";

  @override
  String getName(AppLocalizations lm) {
    return lm.settings_app_theme_gruvbox_title;
  }

  @override
  List<Color> getAccentColors(Brightness brightness) {
    if (brightness == Brightness.light) {
      return [
        Color(0xFFCC241D),
        Color(0xFF98971A),
        Color(0xFFD79921),
        Color(0xFF458588),
        Color(0xFFB16286),
        Color(0xFF689D6A),
        Color(0xFFD65D0E)
      ];
    }
    return [
      Color(0xFFFB4934),
      Color(0xFFB8BB26),
      Color(0xFFFABD2F),
      Color(0xFF83A598),
      Color(0xFFD3869B),
      Color(0xFF8EC07C),
      Color(0xFFFE8019)
    ];
  }
  
  final darkSpec = CustomThemeSpec(
    backgroundColor: Color(0xFF1D2021),
    foregroundColor: Color(0xFFFBF1C7),
    highestSurfaceColor: Color(0xFF32302F),
    lowestSurfaceColor: Color(0xFF282828),
    errorColor: Color(0xFFFB4934),
    secondaryColor: Color(0xFF7C6F64),
    brightness: Brightness.dark
  );

  final lightSpec = CustomThemeSpec(
      backgroundColor: Color(0xFFFBF1C7),
      foregroundColor: Color(0xFF1D2021),
      highestSurfaceColor: Color(0xFFEBDBB2),
      lowestSurfaceColor: Color(0xFFD5C4A1),
      errorColor: Color(0xFFCC241D),
      secondaryColor: Color(0xFFBDAE93),
      brightness: Brightness.light
  );

  @override
  ThemeData generateThemeData({required Color accentColor, required Brightness brightness}) {

    final spec = brightness == Brightness.light ? lightSpec : darkSpec;

    return ThemeGenerator.generateTheme(accentColor, spec);
  }
}