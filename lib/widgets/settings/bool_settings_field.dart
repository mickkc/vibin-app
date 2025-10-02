import 'package:flutter/material.dart';
import 'package:vibin_app/settings/settings_key.dart';

import '../../main.dart';
import '../../settings/settings_manager.dart';

class BoolSettingsField extends StatefulWidget {
  final BoolSettingsKey settingsKey;
  final String title;
  final String? description;
  final IconData? icon;

  const BoolSettingsField({
    super.key,
    required this.settingsKey,
    required this.title,
    this.description,
    this.icon,
  });

  @override
  State<BoolSettingsField> createState() => _BoolSettingsFieldState();
}

class _BoolSettingsFieldState extends State<BoolSettingsField> {
  final SettingsManager settingsManager = getIt<SettingsManager>();

  late bool value = settingsManager.get(widget.settingsKey);

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      title: Text(widget.title),
      subtitle: widget.description != null ? Text(widget.description!) : null,
      secondary: widget.icon != null ? Icon(widget.icon) : null,
      onChanged: (bool newValue) {
        settingsManager.set(widget.settingsKey, newValue);
        setState(() {
          value = newValue;
        });
      },
    );
  }
}