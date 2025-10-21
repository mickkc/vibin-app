import 'package:flutter/material.dart';

import '../themes/text_theme.dart';

class ThemeGenerator {

  static ThemeData generateTheme(Color primaryColor, CustomThemeSpec spec) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: spec.brightness,
        primary: primaryColor,
        onPrimary: spec.backgroundOnPrimary ? spec.backgroundColor : spec.foregroundColor,
        primaryContainer: blendColors(primaryColor, spec.backgroundColor, 0.2),
        onPrimaryContainer: spec.backgroundOnPrimary ? spec.backgroundColor : spec.foregroundColor,
        primaryFixed: blendColors(primaryColor, spec.backgroundColor, 0.3),
        primaryFixedDim: blendColors(primaryColor, spec.backgroundColor, 0.1),
        onPrimaryFixed: spec.backgroundOnPrimary ? spec.backgroundColor : spec.foregroundColor,
        onPrimaryFixedVariant: spec.foregroundColor.withAlpha(179),
        secondary: spec.secondaryColor,
        onSecondary: spec.backgroundOnSecondary ? spec.backgroundColor : spec.foregroundColor,
        secondaryContainer: blendColors(spec.secondaryColor, spec.backgroundColor, 0.2),
        onSecondaryContainer: spec.backgroundOnSecondary ? spec.backgroundColor : spec.foregroundColor,
        secondaryFixed: blendColors(spec.secondaryColor, spec.backgroundColor, 0.3),
        secondaryFixedDim: blendColors(spec.secondaryColor, spec.backgroundColor, 0.1),
        onSecondaryFixed: spec.backgroundOnSecondary ? spec.backgroundColor : spec.foregroundColor,
        onSecondaryFixedVariant: spec.foregroundColor.withAlpha(179),
        tertiary: spec.foregroundColor.withAlpha(205),
        onTertiary: spec.backgroundColor,
        tertiaryContainer: spec.foregroundColor.withAlpha(230),
        onTertiaryContainer: spec.backgroundColor,
        tertiaryFixed: spec.foregroundColor.withAlpha(243),
        tertiaryFixedDim: spec.foregroundColor.withAlpha(154),
        onTertiaryFixed: spec.backgroundColor,
        onTertiaryFixedVariant: spec.backgroundColor.withAlpha(179),
        error: spec.errorColor,
        onError: spec.backgroundOnError ? spec.backgroundColor : spec.foregroundColor,
        errorContainer: blendColors(spec.errorColor, spec.backgroundColor, 0.2),
        onErrorContainer: spec.backgroundOnError ? spec.backgroundColor : spec.foregroundColor,
        surface: spec.backgroundColor,
        onSurface: spec.foregroundColor,
        surfaceDim: spec.highestSurfaceColor.withAlpha(230),
        surfaceBright: spec.highestSurfaceColor.withAlpha(243),
        surfaceContainerLowest: spec.lowestSurfaceColor,
        surfaceContainerLow: blendColors(spec.lowestSurfaceColor, spec.highestSurfaceColor, 0.3),
        surfaceContainer: blendColors(spec.lowestSurfaceColor, spec.highestSurfaceColor, 0.5),
        surfaceContainerHigh: blendColors(spec.lowestSurfaceColor, spec.highestSurfaceColor, 0.7),
        surfaceContainerHighest: spec.highestSurfaceColor,
        onSurfaceVariant: spec.foregroundColor.withAlpha(179),
        outline: spec.foregroundColor.withAlpha(128),
        outlineVariant: spec.foregroundColor.withAlpha(77),
        shadow: spec.backgroundColor.withAlpha(128),
        scrim: spec.backgroundColor.withAlpha(179),
        inverseSurface: spec.foregroundColor,
        onInverseSurface: spec.backgroundColor,
        inversePrimary: primaryColor,
        surfaceTint: primaryColor,
      ),
      scaffoldBackgroundColor: spec.backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: spec.highestSurfaceColor,
        foregroundColor: spec.foregroundColor,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: spec.highestSurfaceColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: spec.lowestSurfaceColor,
          foregroundColor: primaryColor,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: spec.foregroundColor,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: spec.lowestSurfaceColor,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: spec.foregroundColor,
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: spec.lowestSurfaceColor,
        textTheme: ButtonTextTheme.primary,
      ),
      iconTheme: IconThemeData(
        color: spec.foregroundColor,
      ),
      fontFamily: TextThemes.defaultFontFamily,
      textTheme: TextThemes.defaultTextTheme

    );

    return base;
  }

  static Color blendColors(Color a, Color b, double t) {
    return Color.lerp(a, b, t) ?? a;
  }
}

class CustomThemeSpec {
  final Color backgroundColor;
  final Color foregroundColor;
  final Color highestSurfaceColor;
  final Color lowestSurfaceColor;
  final Color errorColor;
  final Color secondaryColor;
  final Brightness brightness;
  final bool useMaterial3;

  final bool backgroundOnPrimary;
  final bool backgroundOnSecondary;
  final bool backgroundOnError;

  CustomThemeSpec({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.highestSurfaceColor,
    required this.lowestSurfaceColor,
    required this.errorColor,
    required this.secondaryColor,
    required this.brightness,
    this.useMaterial3 = true,
    this.backgroundOnPrimary = false,
    this.backgroundOnSecondary = false,
    this.backgroundOnError = false,
  });
}