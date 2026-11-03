import 'package:flutter/material.dart';
import 'package:vibin_app/dtos/settings/setting.dart';
import 'package:vibin_app/l10n/app_localizations.dart';

import '../../../api/api_manager.dart';
import '../../../main.dart';

class ServerBooleanSettingsField extends StatefulWidget {
  final Setting setting;
  final String title;
  final String? description;
  final IconData? icon;
  final bool enabled;

  const ServerBooleanSettingsField({
    super.key,
    required this.setting,
    required this.title,
    this.description,
    this.icon,
    this.enabled = true
  });

  @override
  State<ServerBooleanSettingsField> createState() => _ServerBooleanSettingsFieldState();
}

class _ServerBooleanSettingsFieldState extends State<ServerBooleanSettingsField> {

  late bool _currentValue = widget.setting.value;
  final _apiManager = getIt<ApiManager>();
  late final _lm = AppLocalizations.of(context)!;


  Future<void> _save() async {
    try {
      final updated = await _apiManager.service.updateSetting(widget.setting.key, _currentValue.toString());
      setState(() {
        _currentValue = updated.value as bool;
      });
    }
    catch (e, st) {
      logger.handle(e, st, _lm.settings_server_update_error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(widget.title),
      subtitle: widget.description != null ? Text(widget.description!) : null,
      secondary: widget.icon != null ? Icon(widget.icon) : null,
      value: _currentValue,
      onChanged: widget.enabled ? (bool newValue) async {
        setState(() {
          _currentValue = newValue;
        });
        await _save();
      } : null,
    );
  }
}