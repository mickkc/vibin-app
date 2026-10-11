import 'package:flutter/material.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/utils/error_handler.dart';
import 'package:vibin_app/widgets/settings/base_setting_widget.dart';

import '../../../api/api_manager.dart';
import '../../../main.dart';

class ServerNumberSettingsField<Number> extends StatefulWidget {
  final String settingKey;
  final Number initialValue;
  final String title;
  final String? description;
  final IconData? icon;
  final Number? Function(String) parser;
  final String Function(Number)? formatter;
  final String? errorMessage;

  const ServerNumberSettingsField({
    super.key,
    required this.settingKey,
    required this.initialValue,
    required this.title,
    this.description,
    this.icon,
    required this.parser,
    this.formatter,
    this.errorMessage
  });

  @override
  State<ServerNumberSettingsField> createState() => _ServerIntSettingsFieldState();
}

class _ServerIntSettingsFieldState<Number> extends State<ServerNumberSettingsField<Number>> {

  final _apiManager = getIt<ApiManager>();
  late final _lm = AppLocalizations.of(context)!;
  late final _controller = TextEditingController(text: _format(widget.initialValue));

  late Number _currentValue = widget.initialValue;
  late Number _lastSavedValue = widget.initialValue;

  String _format(Number num) {
    if (widget.formatter != null) {
      return widget.formatter!(num);
    }
    return num.toString();
  }

  Future<void> _save() async {
    try {
      final parsedValue = widget.parser(_controller.text);

      if (parsedValue == null) {
        if (widget.errorMessage != null) {
          ErrorHandler.showErrorDialog(context, widget.errorMessage!);
        }
        return;
      }

      final updated = await _apiManager.service.updateSetting(widget.settingKey, parsedValue.toString());
      setState(() {
        _controller.text = _format(updated.value as Number);
        _lastSavedValue = updated.value as Number;
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
      rowWidgetWidth: 200,
      child: (context, rowCol) => Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          if (_currentValue != _lastSavedValue)
            IconButton(
              onPressed: _save,
              icon: const Icon(Icons.save),
            ),

          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              onSubmitted: (_) => _save(),
              onChanged: (v) => setState(() {
                try {
                  final parsedValue = widget.parser(v);
                  if (parsedValue != null) {
                    _currentValue = parsedValue;
                  }
                }
                catch (e) {
                  _currentValue = _lastSavedValue;
                }
              })
            ),
          ),
        ],
      )
    );
  }
}