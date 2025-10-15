import 'package:flutter/material.dart';
import 'package:vibin_app/color_schemes/base_color_scheme_provider.dart';

import '../../l10n/app_localizations.dart';

class Material3Theme extends BaseColorSchemeProvider {

  @override
  String get id => "material3";

  @override
  String getName(AppLocalizations lm) {
    return lm.settings_app_theme_material3_title;
  }

  @override
  List<Color> getAccentColors(Brightness brightness) {
    return [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
    ];
  }

  @override
  ThemeData generateThemeData({required Color accentColor, required Brightness brightness}) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: brightness,
      ),
      useMaterial3: true,
    );
  }
}