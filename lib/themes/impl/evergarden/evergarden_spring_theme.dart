import 'package:flutter/material.dart';
import 'package:vibin_app/themes/impl/evergarden/evergarden_winter_theme.dart';
import 'package:vibin_app/utils/theme_generator.dart';

import '../../../l10n/app_localizations.dart';

class EvergardenSpringTheme extends EvergardenWinterTheme {

  @override
  String getName(AppLocalizations lm) {
    return lm.settings_app_theme_evergarden_spring_title;
  }

  static final _spec = const CustomThemeSpec(
    backgroundColor: Color(0xFF2b3438),
    foregroundColor: Color(0xFFf8f9e8),
    highestSurfaceColor: Color(0xFF3e4a4f),
    lowestSurfaceColor: Color(0xFF343e43),
    errorColor: Color(0xFFf57f82),
    secondaryColor: Color(0xFF6f8788),
    brightness: Brightness.dark
  );

  @override
  ThemeData generateThemeData({required Color accentColor, required Brightness brightness}) {
    return ThemeGenerator.generateTheme(accentColor, _spec);
  }
}