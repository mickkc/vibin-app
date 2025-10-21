import 'package:flutter/material.dart';
import 'package:vibin_app/settings/settings_key.dart';

import '../../main.dart';
import '../../settings/settings_manager.dart';

class EnumSettingsField<T> extends StatefulWidget {
  final EnumSettingsKey<T> settingKey;
  final String title;
  final String? description;
  final IconData? icon;
  final String Function(T) optionLabel;
  final void Function(T)? onChanged;

  const EnumSettingsField({
    super.key,
    required this.settingKey,
    required this.title,
    this.description,
    this.icon,
    required this.optionLabel,
    this.onChanged,
  });

  @override
  State<EnumSettingsField<T>> createState() => _EnumSettingsFieldState<T>();
}

class _EnumSettingsFieldState<T> extends State<EnumSettingsField<T>> {

  final _settingsManager = getIt<SettingsManager>();
  late T _value = _settingsManager.get(widget.settingKey);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.title),
      subtitle: widget.description != null ? Text(widget.description!) : null,
      trailing: DropdownButton<T>(
        value: _value,
        onChanged: (T? newValue) {
          if (newValue != null) {
            _settingsManager.set(widget.settingKey, newValue);
            setState(() {
              _value = newValue;
            });
            if (widget.onChanged != null) {
              widget.onChanged!(newValue);
            }
          }
        },
        items: widget.settingKey.values.map<DropdownMenuItem<T>>((T option) {
          return DropdownMenuItem<T>(
            value: option,
            child: Text(widget.optionLabel(option)),
          );
        }).toList(),
      ),
      leading: widget.icon != null ? Icon(widget.icon) : null,
    );
  }
}