import 'package:flutter/material.dart';
import 'package:vibin_app/l10n/app_localizations.dart';

abstract class BaseColorSchemeProvider {

  String getName(AppLocalizations lm);

  bool get supportsBrightness => true;
  bool get supportsAccentColor => true;

  bool isSupported() => true;

  List<Color> getAccentColors(Brightness brightness);

  ThemeData generateThemeData({
    required Color accentColor,
    required Brightness brightness,
  });
}