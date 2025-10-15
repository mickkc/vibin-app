import 'package:vibin_app/color_schemes/base_color_scheme_provider.dart';

import 'impl/gruvbox_theme.dart';
import 'impl/material3_theme.dart';

enum ColorSchemeKey {
  material3,
  gruvbox,
}

class ColorSchemeList {
  static Map<ColorSchemeKey, BaseColorSchemeProvider> themes = {
    ColorSchemeKey.material3: Material3Theme(),
    ColorSchemeKey.gruvbox: GruvboxTheme(),
  };
}