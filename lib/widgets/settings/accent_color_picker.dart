import 'package:flutter/material.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/settings/setting_definitions.dart';
import 'package:vibin_app/settings/settings_manager.dart';

import '../../themes/color_scheme_list.dart';

class AccentColorPicker extends StatefulWidget {

  final Color accentColor;
  final ColorSchemeKey colorSchemeKey;


  const AccentColorPicker({
    super.key,
    required this.accentColor,
    required this.colorSchemeKey,
  });

  @override
  State<AccentColorPicker> createState() => _AccentColorPickerState();
}

class _AccentColorPickerState extends State<AccentColorPicker> {

  final _settingsManager = getIt<SettingsManager>();

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    final colorScheme = ColorSchemeList.get(widget.colorSchemeKey);

    if (!colorScheme.isSupported()) return const SizedBox.shrink();

    final availableColors = colorScheme.getAccentColors(Theme.brightnessOf(context));

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: availableColors.map((color) {
        return GestureDetector(
          onTap: () {
            _settingsManager.set(Settings.accentColor, color);
            themeNotifier.value = themeNotifier.value.setAccentColor(color).validate(context);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.accentColor.toARGB32() == color.toARGB32() ? theme.colorScheme.onSurface : Colors.transparent,
                width: 3.0,
              ),
            ),
            child: null,
          ),
        );
      }).toList()
    );
  }
}