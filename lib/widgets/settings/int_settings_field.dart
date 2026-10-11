import 'package:flutter/material.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/settings/settings_key.dart';
import 'package:vibin_app/settings/settings_manager.dart';
import 'package:vibin_app/widgets/row_small_column.dart';
import 'package:vibin_app/widgets/settings/base_setting_widget.dart';

class IntSettingsInputField extends StatefulWidget {
  final IntSettingsKey settingsKey;
  final String label;
  final String? description;
  final IconData? icon;
  final int? min;
  final int? max;

  const IntSettingsInputField({
    super.key,
    required this.settingsKey,
    required this.label,
    this.description,
    this.icon,
    this.min,
    this.max,
  });

  @override
  State<IntSettingsInputField> createState() => _IntSettingsInputFieldState();
}

class _IntSettingsInputFieldState extends State<IntSettingsInputField> {

  final _settingsManager = getIt<SettingsManager>();

  late int _value = _settingsManager.get(widget.settingsKey);
  late final _controller = TextEditingController(text: _value.toString());

  @override
  Widget build(BuildContext context) {
    return BaseSettingWidget(
      title: widget.label,
      description: widget.description,
      icon: widget.icon,
      rowWidgetWidth: 100,
      child: (context, rowCol) => TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        ),
        textAlign: rowCol == RowColumn.row ? TextAlign.end : TextAlign.start,
        onSubmitted: (text) {
          final intValue = int.tryParse(text);
          if (intValue != null && (widget.min == null || intValue >= widget.min!) && (widget.max == null || intValue <= widget.max!)) {
            _settingsManager.set(widget.settingsKey, intValue);
            setState(() {
              _value = intValue;
              _controller.text = _value.toString();
            });
          } else {
            _controller.text = _value.toString();
          }
        },
      )
    );
  }
}