import 'package:flutter/material.dart';

class TextThemes {

  static const defaultHeadlineFontFamily = 'Roboto Flex';
  static const defaultFontFamily = 'Roboto Flex';

  static const defaultTextTheme = TextTheme(
    headlineLarge: TextStyle(
      fontFamily: defaultHeadlineFontFamily,
      fontSize: 40,
      fontVariations: [
        FontVariation('wght', 1000),
        FontVariation('opsz', 48),
        FontVariation('GRAD', -100),
        FontVariation('WDTH', 151),
        FontVariation('XTRA', 600),
      ]
    ),
    headlineMedium: TextStyle(
      fontFamily: defaultHeadlineFontFamily,
      fontSize: 32,
      fontVariations: [
        FontVariation('wght', 1000),
        FontVariation('opsz', 36),
        FontVariation('GRAD', -100),
        FontVariation('WDTH', 151),
        FontVariation('XTRA', 600),
      ],
    ),
    headlineSmall: TextStyle(
      fontFamily: defaultHeadlineFontFamily,
      fontSize: 28,
      fontVariations: [
        FontVariation('wght', 1000),
        FontVariation('opsz', 24),
        FontVariation('GRAD', -100),
        FontVariation('WDTH', 151),
        FontVariation('XTRA', 600),
      ]
    ),
  );
}