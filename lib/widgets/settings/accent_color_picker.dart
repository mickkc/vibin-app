import 'package:flutter/material.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/settings/setting_definitions.dart';
import 'package:vibin_app/settings/settings_manager.dart';

class AccentColorPicker extends StatefulWidget {
  const AccentColorPicker({super.key});

  @override
  State<AccentColorPicker> createState() => _AccentColorPickerState();
}

class _AccentColorPickerState extends State<AccentColorPicker> {

  late final theme = Theme.of(context);
  final SettingsManager settingsManager = getIt<SettingsManager>();

  late Color? selectedColor = settingsManager.get(Settings.accentColor);

  final List<Color?> availableColors = [
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
    null
  ];

  @override
  Widget build(BuildContext context) {
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
              color: color ?? theme.colorScheme.surfaceContainerHigh,
              shape: BoxShape.circle,
              border: Border.all(
                color: selectedColor?.toARGB32() == color?.toARGB32() ? theme.colorScheme.primary : Colors.transparent,
                width: 3.0,
              ),
            ),
            child: color == null ? Icon(Icons.close, color: theme.colorScheme.onSurface) : null,
          ),
        );
      }).toList()
    );
  }
}