import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/theme_generator.dart';
import 'everforest_hard_theme.dart';

class EverforestMediumTheme extends EverforestHardTheme {

  @override
  String getName(AppLocalizations lm) {
    return lm.settings_app_theme_everforest_medium_title;
  }

  static final _darkSpec = const CustomThemeSpec(
    backgroundColor: Color(0xFF2D353B),
    foregroundColor: Color(0xFFD3C6AA),
    highestSurfaceColor: Color(0xFF4F585E),
    lowestSurfaceColor: Color(0xFF343F44),
    errorColor: Color(0xFFE67E80),
    secondaryColor: Color(0xFF7A8478),
    brightness: Brightness.dark
  );

  static final _lightSpec = const CustomThemeSpec(
    backgroundColor: Color(0xFFFDF6E3),
    foregroundColor: Color(0xFF5C6A72),
    highestSurfaceColor: Color(0xFFE0DCC7),
    lowestSurfaceColor: Color(0xFFF4F0D9),
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