import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/utils/error_handler.dart';

import '../../../api/api_manager.dart';
import '../../../main.dart';

class ServerIntSettingsField extends StatefulWidget {
  final String settingKey;
  final int initialValue;
  final String title;
  final String? description;
  final IconData? icon;

  const ServerIntSettingsField({
    super.key,
    required this.settingKey,
    required this.initialValue,
    required this.title,
    this.description,
    this.icon,
  });

  @override
  State<ServerIntSettingsField> createState() => _ServerIntSettingsFieldState();
}

class _ServerIntSettingsFieldState extends State<ServerIntSettingsField> {

  final _apiManager = getIt<ApiManager>();
  late final _controller = TextEditingController(text: widget.initialValue.toString());

  late int _currentValue = widget.initialValue;
  late int _lastSavedValue = widget.initialValue;

  Future<void> _save() async {
    try {

      final parsedValue = int.tryParse(_controller.text);

      if (parsedValue == null) {
        return;
      }

      final updated = await _apiManager.service.updateSetting(widget.settingKey, _controller.text);
      setState(() {
        _controller.text = (updated.value as int).toString();
        _lastSavedValue = updated.value as int;
      });
    }
    catch (e, st) {
      log("Failed to save setting ${widget.settingKey}: $e", error: e, level: Level.error.value);
      if (mounted) ErrorHandler.showErrorDialog(context, AppLocalizations.of(context)!.settings_server_update_error, error: e, stackTrace: st);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: widget.icon != null ? Icon(widget.icon) : null,
      title: Text(widget.title),
      subtitle: widget.description != null ? Text(widget.description!) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          if (_currentValue != _lastSavedValue)
            IconButton(
              onPressed: _save,
              icon: const Icon(Icons.save),
            ),

          SizedBox(
            width: 200,
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              onSubmitted: (_) => _save(),
              onChanged: (v) => setState(() {
                final parsedValue = int.tryParse(v);
                if (parsedValue != null) {
                  _currentValue = parsedValue;
                }
              })
            ),
          ),
        ],
      ),
    );
  }
}