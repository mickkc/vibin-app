import 'dart:ui';

import 'package:vibin_app/settings/setting_definitions.dart';
import 'package:vibin_app/themes/impl/catppuccin_themes.dart';

import '../main.dart';
import '../settings/settings_manager.dart';
import 'base_color_scheme_provider.dart';
import 'impl/dracula_theme.dart';
import 'impl/gruvbox_theme.dart';
import 'impl/material3_theme.dart';
import 'impl/nord_theme.dart';
import 'impl/pywal/pywal_theme.dart';
import 'impl/solarized_theme.dart';

enum ColorSchemeKey {
  material3,
  gruvbox,
  catppuccinLatte,
  catppuccinFrappe,
  catppuccinMacchiato,
  catppuccinMocha,
  nord,
  dracula,
  solarized,
  pywal
}

class ColorSchemeList {

  static final Map<ColorSchemeKey, BaseColorSchemeProvider> _allSchemes = {
    ColorSchemeKey.material3: Material3Theme(),
    ColorSchemeKey.gruvbox: GruvboxTheme(),
    ColorSchemeKey.catppuccinLatte: CatppuccinLatteTheme(),
    ColorSchemeKey.catppuccinFrappe: CatppuccinFrappeTheme(),
    ColorSchemeKey.catppuccinMacchiato: CatppuccinMacchiatoTheme(),
    ColorSchemeKey.catppuccinMocha: CatppuccinMochaTheme(),
    ColorSchemeKey.nord: NordTheme(),
    ColorSchemeKey.dracula: DraculaTheme(),
    ColorSchemeKey.solarized: SolarizedTheme(),
    ColorSchemeKey.pywal: PywalTheme(),
  };

  static BaseColorSchemeProvider get(ColorSchemeKey key) {
    return _allSchemes[key]!;
  }

  static BaseColorSchemeProvider getCurrent() {
    final currentKey = getIt<SettingsManager>().get(Settings.colorScheme);
    return get(currentKey);
  }
}