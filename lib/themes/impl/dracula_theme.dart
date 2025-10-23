import 'package:flutter/material.dart';
import 'package:vibin_app/utils/theme_generator.dart';

import '../../l10n/app_localizations.dart';
import '../base_color_scheme_provider.dart';

class DraculaTheme extends BaseColorSchemeProvider {

  @override
  String getName(AppLocalizations lm) {
    return lm.settings_app_theme_dracula_title;
  }

  @override
  List<Color> getAccentColors(Brightness brightness) {
    if (brightness == Brightness.light) {
      return [
        Color(0xFFCB3A2A),
        Color(0xFFA34D14),
        Color(0xFF846E15),
        Color(0xFF14710A),
        Color(0xFF036A96),
        Color(0xFF644AC9),
        Color(0xFFA3144D)
      ];
    }
    return [
      Color(0xFFFF5555),
      Color(0xFFFFB86C),
      Color(0xFFF1FA8C),
      Color(0xFF50FA7B),
      Color(0xFF8BE9FD),
      Color(0xFFBD93F9),
      Color(0xFFFF79C6)
    ];
  }
  
  static final _darkSpec = const CustomThemeSpec(
    backgroundColor: Color(0xFF282A36),
    foregroundColor: Color(0xFFF8F8F2),
    highestSurfaceColor: Color(0xFF44475A),
    lowestSurfaceColor: Color(0xFF44475A),
    errorColor: Color(0xFFFF5555),
    secondaryColor: Color(0xFF6272A4),
    brightness: Brightness.dark
  );

  static final _lightSpec = const CustomThemeSpec(
    backgroundColor: Color(0xFFFFFBEB),
    foregroundColor: Color(0xFF1F1F1F),
    highestSurfaceColor: Color(0xFFCFCFDE),
    lowestSurfaceColor: Color(0xFFEEEEF3),
    errorColor: Color(0xFFCB3A2A),
    secondaryColor: Color(0xFFCFCFDE),
    brightness: Brightness.light,
    backgroundOnPrimary: true,
    backgroundOnError: true
  );

  @override
  ThemeData generateThemeData({required Color accentColor, required Brightness brightness}) {

    final spec = brightness == Brightness.light ? _lightSpec : _darkSpec;

    return ThemeGenerator.generateTheme(accentColor, spec);
  }
}