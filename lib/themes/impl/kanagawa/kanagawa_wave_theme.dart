import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/theme_generator.dart';
import '../../base_color_scheme_provider.dart';

class KanagawaWaveTheme extends BaseColorSchemeProvider {

  @override
  String getName(AppLocalizations lm) {
    return lm.settings_app_theme_kanagawa_wave_title;
  }

  @override
  bool get supportsBrightness => false;

  @override
  List<Color> getAccentColors(Brightness brightness) {
    return [
      Color(0xFFe82424),
      Color(0xFF98bb6c),
      Color(0xFFe6c384),
      Color(0xFF7fb4ca),
      Color(0xFF938aa9),
      Color(0xFF7aa89f)
    ];
  }

  static final _spec = const CustomThemeSpec(
    backgroundColor: Color(0xFF1f1f28),
    foregroundColor: Color(0xFFdcd7ba),
    highestSurfaceColor: Color(0xFF2a2a37),
    lowestSurfaceColor: Color(0xFF22222C),
    errorColor: Color(0xFFe82424),
    secondaryColor: Color(0xFF727169),
    brightness: Brightness.dark
  );

  @override
  ThemeData generateThemeData({required Color accentColor, required Brightness brightness}) {
    return ThemeGenerator.generateTheme(accentColor, _spec);
  }
}
