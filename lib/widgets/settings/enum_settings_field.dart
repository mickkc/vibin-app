import 'package:flutter/material.dart';
import 'package:vibin_app/settings/settings_key.dart';
import 'package:vibin_app/widgets/row_small_column.dart';
import 'package:vibin_app/widgets/settings/base_setting_widget.dart';

import '../../main.dart';
import '../../settings/settings_manager.dart';

class EnumSettingsField<T> extends StatefulWidget {
  final EnumSettingsKey<T> settingKey;
  final String title;
  final String? description;
  final IconData? icon;
  final String Function(T) optionLabel;
  final void Function(T)? onChanged;
  final bool Function(T)? isOptionEnabled;

  const EnumSettingsField({
    super.key,
    required this.settingKey,
    required this.title,
    this.description,
    this.icon,
    required this.optionLabel,
    this.onChanged,
    this.isOptionEnabled,
  });

  @override
  State<EnumSettingsField<T>> createState() => _EnumSettingsFieldState<T>();
}

class _EnumSettingsFieldState<T> extends State<EnumSettingsField<T>> {

  final _settingsManager = getIt<SettingsManager>();
  late T _value = _settingsManager.get(widget.settingKey);

  @override
  Widget build(BuildContext context) {
    return BaseSettingWidget(
      title: widget.title,
      description: widget.description,
      icon: widget.icon,
      child: (context, rowCol) => DropdownButton<T>(
        isExpanded: rowCol == RowColumn.column,
        isDense: rowCol == RowColumn.column,
        value: _value,
        onChanged: (T? newValue) {
          if (null is T || newValue != null) {
            _settingsManager.set(widget.settingKey, newValue);
            setState(() {
              _value = newValue as T;
            });
            if (widget.onChanged != null) {
              widget.onChanged!(newValue as T);
            }
          }
        },
        items: widget.settingKey.values.map<DropdownMenuItem<T>>((T option) {

          final enabled = widget.isOptionEnabled?.call(option) ?? true;

          return DropdownMenuItem<T>(
            value: option,
            enabled: enabled,
            child: Text(
              widget.optionLabel(option),
              style: enabled ? null : TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          );
        }).toList(),
      )
    );
  }
}