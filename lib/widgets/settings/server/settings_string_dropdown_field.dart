import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:vibin_app/l10n/app_localizations.dart';

import '../../../api/api_manager.dart';
import '../../../extensions.dart';
import '../../../main.dart';

class ServerStringDropdownField extends StatefulWidget {
  final String settingKey;
  final String title;
  final String? description;
  final String initialValue;
  final List<String> options;
  final IconData? icon;

  const ServerStringDropdownField({
    super.key,
    required this.settingKey,
    required this.title,
    this.description,
    required this.initialValue,
    required this.options,
    this.icon,
  });

  @override
  State<ServerStringDropdownField> createState() => _ServerStringDropdownFieldState();
}

class _ServerStringDropdownFieldState extends State<ServerStringDropdownField> {
  
  late String _currentValue = widget.initialValue;
  final _apiManager = getIt<ApiManager>();

  Future<void> _save() async {
    try {
      final updated = await _apiManager.service.updateServerSetting(widget.settingKey, _currentValue);
      setState(() {
        _currentValue = updated.value as String;
      });
    }
    catch (e) {
      log("Failed to save setting ${widget.settingKey}: $e", error: e, level: Level.error.value);
      if (mounted) showErrorDialog(context, AppLocalizations.of(context)!.settings_server_update_error);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.title),
      subtitle: widget.description != null ? Text(widget.description!) : null,
      leading: widget.icon != null ? Icon(widget.icon) : null,
      trailing: DropdownButton<String>(
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
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}