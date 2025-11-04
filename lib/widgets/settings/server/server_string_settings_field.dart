import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/utils/error_handler.dart';

import '../../../api/api_manager.dart';
import '../../../main.dart';

class ServerStringSettingsField extends StatefulWidget {
  final String settingKey;
  final String initialValue;
  final String title;
  final String? description;
  final IconData? icon;
  final bool isPassword;

  const ServerStringSettingsField({
    super.key,
    required this.settingKey,
    required this.initialValue,
    required this.title,
    this.description,
    this.icon,
    this.isPassword = false,
  });

  @override
  State<ServerStringSettingsField> createState() => _ServerStringSettingsFieldState();
}

class _ServerStringSettingsFieldState extends State<ServerStringSettingsField> {

  final _apiManager = getIt<ApiManager>();
  late final _controller = TextEditingController(text: widget.initialValue);

  late String _currentValue = widget.initialValue;
  late String _lastSavedValue = widget.initialValue;

  Future<void> _save() async {
    try {
      final updated = await _apiManager.service.updateSetting(widget.settingKey, _controller.text);
      setState(() {
        _controller.text = updated.value as String;
        _lastSavedValue = _controller.text;
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
                border: OutlineInputBorder(),
                isDense: true,
              ),
              obscureText: widget.isPassword,
              onSubmitted: (_) => _save(),
              onChanged: (v) => setState(() {
                _currentValue = v;
              })
            ),
          ),
        ],
      ),
    );
  }
}