import 'package:flutter/material.dart';
import 'package:vibin_app/l10n/app_localizations.dart';

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
            child: Text(
              widget.itemFormatter != null ? widget.itemFormatter!(value) : value
            ),
          );
        }).toList(),
      ),
    );
  }
}