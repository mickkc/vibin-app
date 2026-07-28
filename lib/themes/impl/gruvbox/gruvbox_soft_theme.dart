import 'package:flutter/material.dart';
import 'package:vibin_app/utils/theme_generator.dart';

import '../../../l10n/app_localizations.dart';
import 'gruvbox_hard_theme.dart';

class GruvboxSoftTheme extends GruvboxHardTheme {

  @override
  String getName(AppLocalizations lm) {
    return lm.settings_app_theme_gruvbox_soft_title;
  }
  
  static final _darkSpec = const CustomThemeSpec(
    backgroundColor: Color(0xFF32302F),
    foregroundColor: Color(0xFFF2E4BE),
    highestSurfaceColor: Color(0xFF504945),
    lowestSurfaceColor: Color(0xFF3C3836),
    errorColor: Color(0xFFFB4934),
    secondaryColor: Color(0xFF7C6F64),
    brightness: Brightness.dark
  );

  static final _lightSpec = const CustomThemeSpec(
    backgroundColor: Color(0xFFF2E4BE),
    foregroundColor: Color(0xFF282828),
    highestSurfaceColor: Color(0xFFD5C4A1),
    lowestSurfaceColor: Color(0xFFEBDBB2),
    errorColor: Color(0xFFCC241D),
    secondaryColor: Color(0xFFBDAE93),
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