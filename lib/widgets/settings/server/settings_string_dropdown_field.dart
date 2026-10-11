import 'package:flutter/material.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/widgets/row_small_column.dart';
import 'package:vibin_app/widgets/settings/base_setting_widget.dart';

import '../../../api/api_manager.dart';
import '../../../main.dart';

class ServerStringDropdownField extends StatefulWidget {
  final String settingKey;
  final String title;
  final String? description;
  final String initialValue;
  final List<String> options;
  final IconData? icon;
  final String Function(String)? itemFormatter;

  const ServerStringDropdownField({
    super.key,
    required this.settingKey,
    required this.title,
    this.description,
    required this.initialValue,
    required this.options,
    this.icon,
    this.itemFormatter,
  });

  @override
  State<ServerStringDropdownField> createState() => _ServerStringDropdownFieldState();
}

class _ServerStringDropdownFieldState extends State<ServerStringDropdownField> {
  
  late String _currentValue = widget.initialValue;
  final _apiManager = getIt<ApiManager>();
  late final _lm = AppLocalizations.of(context)!;

  Future<void> _save() async {
    try {
      final updated = await _apiManager.service.updateSetting(widget.settingKey, _currentValue);
      setState(() {
        _currentValue = updated.value as String;
      });
    }
    catch (e, st) {
      logger.handle(e, st, _lm.settings_server_update_error);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return BaseSettingWidget(
      title: widget.title,
      description: widget.description,
      icon: widget.icon,
      child: (context, rowCol) => DropdownButton<String>(
        isExpanded: rowCol == RowColumn.column,
        isDense: rowCol == RowColumn.column,
        value: _currentValue,
        onChanged: (String? newValue) async {
          if (newValue != null) {
            setState(() {
              _currentValue = newValue;
            });
            await _save();
          }
        },
        items: widget.options.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              widget.itemFormatter != null ? widget.itemFormatter!(value) : value
            ),
          );
        }).toList(),
      )
    );
  }
}