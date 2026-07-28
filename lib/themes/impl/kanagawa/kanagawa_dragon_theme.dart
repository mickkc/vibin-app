import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/theme_generator.dart';
import '../../base_color_scheme_provider.dart';

class KanagawaDragonTheme extends BaseColorSchemeProvider {

  @override
  String getName(AppLocalizations lm) {
    return lm.settings_app_theme_kanagawa_dragon_title;
  }

  @override
  bool get supportsBrightness => false;

  @override
  List<Color> getAccentColors(Brightness brightness) {
    return [
      Color(0xFFe46876),
      Color(0xFF87a987),
      Color(0xFFe6c384),
      Color(0xFF7fb4ca),
      Color(0xFF938aa9),
      Color(0xFF7aa89f)
    ];
  }

  static final _spec = const CustomThemeSpec(
      backgroundColor: Color(0xFF181616),
      foregroundColor: Color(0xFFc5c9c5),
      highestSurfaceColor: Color(0xFF282727),
      lowestSurfaceColor: Color(0xFF1C1A1A),
      errorColor: Color(0xFFe46876),
      secondaryColor: Color(0xFFa6a69c),
      brightness: Brightness.dark
  );

  @override
  ThemeData generateThemeData({required Color accentColor, required Brightness brightness}) {
    return ThemeGenerator.generateTheme(accentColor, _spec);
  }
}
