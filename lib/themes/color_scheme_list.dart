import 'package:vibin_app/themes/impl/catppuccin_themes.dart';

import 'base_color_scheme_provider.dart';
import 'impl/gruvbox_theme.dart';
import 'impl/material3_theme.dart';

enum ColorSchemeKey {
  material3,
  gruvbox,
  catppuccinLatte,
  catppuccinFrappe,
  catppuccinMacchiato,
  catppuccinMocha,
}

class ColorSchemeList {
  static Map<ColorSchemeKey, BaseColorSchemeProvider> themes = {
    ColorSchemeKey.material3: Material3Theme(),
    ColorSchemeKey.gruvbox: GruvboxTheme(),
    ColorSchemeKey.catppuccinLatte: CatppuccinLatteTheme(),
    ColorSchemeKey.catppuccinFrappe: CatppuccinFrappeTheme(),
    ColorSchemeKey.catppuccinMacchiato: CatppuccinMacchiatoTheme(),
    ColorSchemeKey.catppuccinMocha: CatppuccinMochaTheme(),
  };
}