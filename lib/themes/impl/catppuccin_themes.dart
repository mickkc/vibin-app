import 'package:flutter/material.dart';
import 'package:vibin_app/themes/base_color_scheme_provider.dart';
import 'package:vibin_app/utils/theme_generator.dart';

import '../../l10n/app_localizations.dart';

class CatppuccinLatteTheme extends BaseColorSchemeProvider {

  @override
  String get id => "catppuccin_latte";

  @override
  bool get supportsBrightness => false;

  @override
  String getName(AppLocalizations lm) {
    return lm.settings_app_theme_catppuccin_latte_title;
  }

  static final _spec = const CustomThemeSpec(
    backgroundColor: Color(0xffeff1f5),
    foregroundColor: Color(0xff4c4f69),
    highestSurfaceColor: Color(0xffccd0da),
    lowestSurfaceColor: Color(0xffe6e9ef),
    errorColor: Color(0xffd20f39),
    secondaryColor: Color(0xff9ca0b0),
    brightness: Brightness.light
  );

  @override
  List<Color> getAccentColors(Brightness brightness) {
    return const [
      Color(0xffdc8a78),
      Color(0xffdd7878),
      Color(0xffea76cb),
      Color(0xff8839ef),
      Color(0xffd20f39),
      Color(0xffe64553),
      Color(0xfffe640b),
      Color(0xffdf8e1d),
      Color(0xff40a02b),
      Color(0xff179299),
      Color(0xff04a5e5),
      Color(0xff1e66f5),
      Color(0xff7287fd)
    ];
  }

  @override
  ThemeData generateThemeData({required Color accentColor, required Brightness brightness}) {
    return ThemeGenerator.generateTheme(accentColor, _spec);
  }
}

class CatppuccinFrappeTheme extends BaseColorSchemeProvider {

  @override
  String get id => "catppuccin_frappe";

  @override
  bool get supportsBrightness => false;

  @override
  String getName(AppLocalizations lm) {
    return lm.settings_app_theme_catppuccin_frappe_title;
  }

  static final _spec = const CustomThemeSpec(
    backgroundColor: Color(0xff303446),
    foregroundColor: Color(0xffc6d0f5),
    highestSurfaceColor: Color(0xff51576d),
    lowestSurfaceColor: Color(0xff414559),
    errorColor: Color(0xffe78284),
    secondaryColor: Color(0xff949cbb),
    brightness: Brightness.dark,
    backgroundOnPrimary: true,
    backgroundOnSecondary: true,
    backgroundOnError: true
  );

  @override
  List<Color> getAccentColors(Brightness brightness) {
    return const [
      Color(0xffeebebe),
      Color(0xfff4b8e4),
      Color(0xffca9ee6),
      Color(0xffe78284),
      Color(0xffea999c),
      Color(0xffef9f76),
      Color(0xffe5c890),
      Color(0xffa6d189),
      Color(0xff81c8be),
      Color(0xff85c1dc),
      Color(0xff8caaee),
      Color(0xffbabbf1)
    ];
  }

  @override
  ThemeData generateThemeData({required Color accentColor, required Brightness brightness}) {
    return ThemeGenerator.generateTheme(accentColor, _spec);
  }
}

class CatppuccinMacchiatoTheme extends BaseColorSchemeProvider {

  @override
  String get id => "catppuccin_macchiato";

  @override
  bool get supportsBrightness => false;

  @override
  String getName(AppLocalizations lm) {
    return lm.settings_app_theme_catppuccin_macchiato_title;
  }

  static final _spec = const CustomThemeSpec(
      backgroundColor: Color(0xff24273a),
      foregroundColor: Color(0xffcad3f5),
      highestSurfaceColor: Color(0xff494d64),
      lowestSurfaceColor: Color(0xff363a4f),
      errorColor: Color(0xffed8796),
      secondaryColor: Color(0xff939ab7),
      brightness: Brightness.dark,
      backgroundOnPrimary: true,
      backgroundOnSecondary: true,
      backgroundOnError: true
  );

  @override
  List<Color> getAccentColors(Brightness brightness) {
    return const [
      Color(0xfff0c6c6),
      Color(0xfff5bde6),
      Color(0xffc6a0f6),
      Color(0xffed8796),
      Color(0xffee99a0),
      Color(0xfff5a97f),
      Color(0xffeed49f),
      Color(0xffa6da95),
      Color(0xff8bd5ca),
      Color(0xff7dc4e4),
      Color(0xff8aadf4),
      Color(0xffb7bdf8)
    ];
  }

  @override
  ThemeData generateThemeData({required Color accentColor, required Brightness brightness}) {
    return ThemeGenerator.generateTheme(accentColor, _spec);
  }
}

class CatppuccinMochaTheme extends BaseColorSchemeProvider {

  @override
  String get id => "catppuccin_mocha";

  @override
  bool get supportsBrightness => false;

  @override
  String getName(AppLocalizations lm) {
    return lm.settings_app_theme_catppuccin_mocha_title;
  }

  static final _spec = const CustomThemeSpec(
      backgroundColor: Color(0xff1e1e2e),
      foregroundColor: Color(0xffcdd6f4),
      highestSurfaceColor: Color(0xff45475a),
      lowestSurfaceColor: Color(0xff313244),
      errorColor: Color(0xfff38ba8),
      secondaryColor: Color(0xff9399b2),
      brightness: Brightness.dark,
      backgroundOnPrimary: true,
      backgroundOnSecondary: true,
      backgroundOnError: true
  );

  @override
  List<Color> getAccentColors(Brightness brightness) {
    return const [
      Color(0xfff2cdcd),
      Color(0xfff5c2e7),
      Color(0xffcba6f7),
      Color(0xfff38ba8),
      Color(0xffeba0ac),
      Color(0xfffab387),
      Color(0xfff9e2af),
      Color(0xffa6e3a1),
      Color(0xff94e2d5),
      Color(0xff74c7ec),
      Color(0xff89b4fa),
      Color(0xffb4befe)
    ];
  }

  @override
  ThemeData generateThemeData({required Color accentColor, required Brightness brightness}) {
    return ThemeGenerator.generateTheme(accentColor, _spec);
  }
}