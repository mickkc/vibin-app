import 'package:flutter/material.dart';
import 'package:vibin_app/color_schemes/color_scheme_list.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/settings/setting_definitions.dart';
import 'package:vibin_app/settings/settings_manager.dart';

class AccentColorPicker extends StatefulWidget {
  const AccentColorPicker({super.key});

  @override
  State<AccentColorPicker> createState() => _AccentColorPickerState();
}

class _AccentColorPickerState extends State<AccentColorPicker> {

  final SettingsManager settingsManager = getIt<SettingsManager>();

  late Color? selectedColor = settingsManager.get(Settings.accentColor);

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return ValueListenableBuilder(
      valueListenable: themeNotifier,
      builder: (context, value, child) {

        final availableColors = ColorSchemeList.themes[value.colorSchemeKey]!.getAccentColors(Theme.brightnessOf(context));

        return Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: availableColors.map((color) {
            return GestureDetector(
              onTap: () {
                settingsManager.set(Settings.accentColor, color);
                themeNotifier.value = themeNotifier.value.setAccentColor(color);
                setState(() {
                  selectedColor = color;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selectedColor?.toARGB32() == color.toARGB32() ? theme.colorScheme.primary : Colors.transparent,
                    width: 3.0,
                  ),
                ),
                child: null,
              ),
            );
          }).toList()
        );
      }
    );
  }
}