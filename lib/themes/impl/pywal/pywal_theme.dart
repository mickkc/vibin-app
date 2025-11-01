import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/themes/base_color_scheme_provider.dart';
import 'package:vibin_app/themes/impl/pywal/pywal_data.dart';
import 'package:vibin_app/utils/theme_generator.dart';

class PywalTheme implements BaseColorSchemeProvider {

  @override
  String getName(AppLocalizations lm) {
    return lm.settings_app_theme_pywal_title;
  }

  @override
  List<Color> getAccentColors(Brightness brightness) {
    final data = getPywalData();
    if (data == null) {
      throw Exception("Pywal colors not found");
    }

    return [
      HexColor.fromHex(data.colors.color2),
      HexColor.fromHex(data.colors.color3),
      HexColor.fromHex(data.colors.color4),
      HexColor.fromHex(data.colors.color5),
      HexColor.fromHex(data.colors.color6),
      HexColor.fromHex(data.colors.color7),
      HexColor.fromHex(data.colors.color8),
      HexColor.fromHex(data.colors.color9),
      HexColor.fromHex(data.colors.color10),
      HexColor.fromHex(data.colors.color11),
      HexColor.fromHex(data.colors.color12),
      HexColor.fromHex(data.colors.color13),
      HexColor.fromHex(data.colors.color14),
      HexColor.fromHex(data.colors.color15),
    ];
  }

  @override
  bool get supportsAccentColor => true;

  @override
  bool get supportsBrightness => false;

  @override
  ThemeData generateThemeData({required Color accentColor, required Brightness brightness}) {
    final data = getPywalData();
    if (data == null) {
      throw Exception("Pywal colors not found");
    }

    final backgroundColor = HexColor.fromHex(data.special.background);
    final foregroundColor = HexColor.fromHex(data.special.foreground);

    final lowestSurfaceColor = ThemeGenerator.blendColors(backgroundColor, foregroundColor, 0.15);
    final highestSurfaceColor = ThemeGenerator.blendColors(backgroundColor, foregroundColor, 0.30);

    final errorColor = HexColor.fromHex(data.colors.color14);

    final secondaryColor = HexColor.fromHex(data.colors.color2);

    return ThemeGenerator.generateTheme(
      accentColor,
      CustomThemeSpec(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        highestSurfaceColor: highestSurfaceColor,
        lowestSurfaceColor: lowestSurfaceColor,
        errorColor: errorColor,
        secondaryColor: secondaryColor,
        brightness: backgroundColor.computeLuminance() > 0.5 ? Brightness.light : Brightness.dark,
      )
    );
  }

  @override
  bool isSupported() {
    return _getFile() != null;
  }

  static PywalData? getPywalData() {

    final pywalFile = _getFile();

    if (pywalFile == null) return null;

    final content = pywalFile.readAsStringSync();
    final PywalData? data = content.isNotEmpty ?  PywalData.fromJson(
      jsonDecode(content)
    ) : null;

    return data;
  }

  static File? _getFile() {
    if (kIsWeb || !Platform.isLinux) return null;

    final homeDir = Platform.environment['HOME'];
    final pywalFile = Uri.file('$homeDir/.cache/wal/colors.json');

    final file = File.fromUri(pywalFile);
    if (!file.existsSync()) return null;

    return file;
  }
}