import 'package:flutter/material.dart';
import 'package:vibin_app/themes/impl/evergarden/evergarden_winter_theme.dart';
import 'package:vibin_app/utils/theme_generator.dart';

import '../../../l10n/app_localizations.dart';

class EvergardenFallTheme extends EvergardenWinterTheme {

  @override
  String getName(AppLocalizations lm) {
    return lm.settings_app_theme_evergarden_fall_title;
  }

  static final _spec = const CustomThemeSpec(
    backgroundColor: Color(0xFF232a2e),
    foregroundColor: Color(0xFFf8f9e8),
    highestSurfaceColor: Color(0xFF374145),
    lowestSurfaceColor: Color(0xFF2b3337),
    errorColor: Color(0xFFf57f82),
    secondaryColor: Color(0xFF6f8788),
    brightness: Brightness.dark
  );

  @override
  ThemeData generateThemeData({required Color accentColor, required Brightness brightness}) {
    return ThemeGenerator.generateTheme(accentColor, _spec);
  }
}