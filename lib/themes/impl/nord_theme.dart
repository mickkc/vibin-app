import 'package:flutter/material.dart';
import 'package:vibin_app/themes/base_color_scheme_provider.dart';
import 'package:vibin_app/utils/theme_generator.dart';

import '../../l10n/app_localizations.dart';

class NordTheme extends BaseColorSchemeProvider {
  @override
  String get id => "nord";

  @override
  String getName(AppLocalizations lm) {
    return lm.settings_app_theme_nord_title;
  }

  @override
  List<Color> getAccentColors(Brightness brightness) {
    return [
      Color(0xffbf616a),
      Color(0xffd08770),
      Color(0xffebcb8b),
      Color(0xffa3be8c),
      Color(0xffb48ead),
      Color(0xff88c0d0)
    ];
  }

  static final _lightSpec = const CustomThemeSpec(
    backgroundColor: Color(0xffeceff4),
    foregroundColor: Color(0xff2e3440),
    highestSurfaceColor: Color(0xffd8dee9),
    lowestSurfaceColor: Color(0xffe5e9f0),
    errorColor: Color(0xffbf616a),
    secondaryColor: Color(0xff4c566a),
    brightness: Brightness.light,
    backgroundOnPrimary: true,
    backgroundOnSecondary: true,
    backgroundOnError: true
  );

  static final _darkSpec = const CustomThemeSpec(
    backgroundColor: Color(0xff2e3440),
    foregroundColor: Color(0xffd8dee9),
    highestSurfaceColor: Color(0xff434c5e),
    lowestSurfaceColor: Color(0xff3b4252),
    errorColor: Color(0xffbf616a),
    secondaryColor: Color(0xff4c566a),
    brightness: Brightness.dark,
    backgroundOnError: false,
    backgroundOnSecondary: false,
    backgroundOnPrimary: false
  );

  @override
  ThemeData generateThemeData({required Color accentColor, required Brightness brightness}) {
    final spec = brightness == Brightness.light ? _lightSpec : _darkSpec;
    return ThemeGenerator.generateTheme(accentColor, spec);
  }
}