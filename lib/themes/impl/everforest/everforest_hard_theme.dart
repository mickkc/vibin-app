import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/theme_generator.dart';
import '../../base_color_scheme_provider.dart';

class EverforestHardTheme extends BaseColorSchemeProvider {

  @override
  String getName(AppLocalizations lm) {
    return lm.settings_app_theme_everforest_hard_title;
  }

  @override
  List<Color> getAccentColors(Brightness brightness) {
    if (brightness == Brightness.light) {
      return [
        Color(0xFFF85552),
        Color(0xFFDFA000),
        Color(0xFF8DA101),
        Color(0xFF3A94C5),
        Color(0xFFDF69BA),
        Color(0xFF35A77C),
        Color(0xFFF57D26)
      ];
    }
    return [
      Color(0xFFE67E80),
      Color(0xFFDBBC7F),
      Color(0xFFA7C080),
      Color(0xFF7FBBB3),
      Color(0xFFD699B6),
      Color(0xFF83C092),
      Color(0xFFE69875)
    ];
  }

  static final _darkSpec = const CustomThemeSpec(
    backgroundColor: Color(0xFF272E33),
    foregroundColor: Color(0xFFD3C6AA),
    highestSurfaceColor: Color(0xFF495156),
    lowestSurfaceColor: Color(0xFF374145),
    errorColor: Color(0xFFE67E80),
    secondaryColor: Color(0xFF7A8478),
    brightness: Brightness.dark
  );

  static final _lightSpec = const CustomThemeSpec(
    backgroundColor: Color(0xFFFFFBEF),
    foregroundColor: Color(0xFF5C6A72),
    highestSurfaceColor: Color(0xFFE8E5D5),
    lowestSurfaceColor: Color(0xFFF2EFDF),
    errorColor: Color(0xFFF85552),
    secondaryColor: Color(0xFF859289),
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