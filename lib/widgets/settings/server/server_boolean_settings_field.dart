import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/utils/error_handler.dart';

import '../../../api/api_manager.dart';
import '../../../main.dart';

class ServerBooleanSettingsField extends StatefulWidget {
  final String settingKey;
  final bool initialValue;
  final String title;
  final String? description;
  final IconData? icon;

  const ServerBooleanSettingsField({
    super.key,
    required this.settingKey,
    required this.initialValue,
    required this.title,
    this.description,
    this.icon,
  });

  @override
  State<ServerBooleanSettingsField> createState() => _ServerBooleanSettingsFieldState();
}

class _ServerBooleanSettingsFieldState extends State<ServerBooleanSettingsField> {

  late bool _currentValue = widget.initialValue;
  final _apiManager = getIt<ApiManager>();


  Future<void> _save() async {
    try {
      final updated = await _apiManager.service.updateSetting(widget.settingKey, _currentValue.toString());
      setState(() {
        _currentValue = updated.value as bool;
      });
    }
    catch (e, st) {
      log("Failed to save setting ${widget.settingKey}: $e", error: e, level: Level.error.value);
      if (mounted) ErrorHandler.showErrorDialog(context, AppLocalizations.of(context)!.settings_server_update_error, error: e, stackTrace: st);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(widget.title),
      subtitle: widget.description != null ? Text(widget.description!) : null,
      secondary: widget.icon != null ? Icon(widget.icon) : null,
      value: _currentValue,
      onChanged: (bool newValue) async {
        setState(() {
          _currentValue = newValue;
        });
        await _save();
      },
    );
  }
}