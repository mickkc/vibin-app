import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/theme_generator.dart';
import 'everforest_hard_theme.dart';

class EverforestSoftTheme extends EverforestHardTheme {

  @override
  String getName(AppLocalizations lm) {
    return lm.settings_app_theme_everforest_soft_title;
  }

  static final _darkSpec = const CustomThemeSpec(
    backgroundColor: Color(0xFF333C43),
    foregroundColor: Color(0xFFD3C6AA),
    highestSurfaceColor: Color(0xFF555F66),
    lowestSurfaceColor: Color(0xFF3A464C),
    errorColor: Color(0xFFE67E80),
    secondaryColor: Color(0xFF7A8478),
    brightness: Brightness.dark
  );

  static final _lightSpec = const CustomThemeSpec(
    backgroundColor: Color(0xFFF3EAD3),
    foregroundColor: Color(0xFF5C6A72),
    highestSurfaceColor: Color(0xFFD8D3BA),
    lowestSurfaceColor: Color(0xFFEAE4CA),
    errorColor: Color(0xFFF85552),
    secondaryColor: Color(0xFF859289),
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