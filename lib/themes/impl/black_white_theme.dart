import 'dart:ui';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/theme_generator.dart';
import '../base_color_scheme_provider.dart';

class BlackWhiteTheme extends BaseColorSchemeProvider {

  @override
  String getName(AppLocalizations lm) {
    return lm.settings_app_theme_blackwhite_title;
  }

  @override
  bool get supportsAccentColor => false;

  @override
  List<Color> getAccentColors(Brightness brightness) {
    return brightness == Brightness.light ? [Colors.black] : [Colors.white];
  }

  static final _darkSpec = const CustomThemeSpec(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    highestSurfaceColor: Colors.black,
    lowestSurfaceColor: Colors.black,
    errorColor: Colors.white,
    secondaryColor: Colors.white,
    brightness: Brightness.dark,
    backgroundOnSecondary: true,
    backgroundOnError: true,
    backgroundOnPrimary: true
  );

  static final _lightSpec = const CustomThemeSpec(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    highestSurfaceColor: Colors.white,
    lowestSurfaceColor: Colors.white,
    errorColor: Colors.black,
    secondaryColor: Colors.black,
    brightness: Brightness.light,
    backgroundOnPrimary: true,
    backgroundOnError: true,
    backgroundOnSecondary: true
  );

  @override
  ThemeData generateThemeData({required Color accentColor, required Brightness brightness}) {
    return brightness == Brightness.light
        ? ThemeGenerator.generateTheme(Colors.black, _lightSpec)
        : ThemeGenerator.generateTheme(Colors.white, _darkSpec);
  }
}