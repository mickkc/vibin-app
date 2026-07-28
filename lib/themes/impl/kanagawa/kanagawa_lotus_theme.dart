import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/theme_generator.dart';
import '../../base_color_scheme_provider.dart';

class KanagawaLotusTheme extends BaseColorSchemeProvider {

  @override
  String getName(AppLocalizations lm) {
    return lm.settings_app_theme_kanagawa_lotus_title;
  }

  @override
  bool get supportsBrightness => false;

  @override
  List<Color> getAccentColors(Brightness brightness) {
    return [
      Color(0xFFd7474b),
      Color(0xFF6e915f),
      Color(0xFF836f4a),
      Color(0xFF6693bf),
      Color(0xFF624c83),
      Color(0xFF5e857a)
    ];
  }

  static final _spec = const CustomThemeSpec(
    backgroundColor: Color(0xFFf2ecbc),
    foregroundColor: Color(0xFF545464),
    highestSurfaceColor: Color(0xFFE7DBA0),
    lowestSurfaceColor: Color(0xFFEFE8B5),
    errorColor: Color(0xFFd7474b),
    secondaryColor: Color(0xFF8a8980),
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
