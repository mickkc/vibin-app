import 'package:flutter/material.dart';
import 'package:vibin_app/dtos/settings/setting.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/widgets/settings/base_setting_widget.dart';

import '../../../api/api_manager.dart';
import '../../../main.dart';

class ServerStringSettingsField extends StatefulWidget {
  final Setting setting;
  final String title;
  final String? description;
  final IconData? icon;
  final bool isPassword;
  final double? breakpoint;

  const ServerStringSettingsField({
    super.key,
    required this.setting,
    required this.title,
    this.description,
    this.icon,
    this.isPassword = false,
    this.breakpoint
  });

  @override
  State<ServerStringSettingsField> createState() => _ServerStringSettingsFieldState();
}

class _ServerStringSettingsFieldState extends State<ServerStringSettingsField> {

  final _apiManager = getIt<ApiManager>();
  late final _controller = TextEditingController(text: widget.setting.value);
  late final _lm = AppLocalizations.of(context)!;

  late String _currentValue = widget.setting.value;
  late String _lastSavedValue = widget.setting.value;

  Future<void> _save() async {
    try {
      final updated = await _apiManager.service.updateSetting(widget.setting.key, _controller.text);
      setState(() {
        _controller.text = updated.value as String;
        _lastSavedValue = _controller.text;
      });
    }
    catch (e, st) {
      if (!mounted) return;
      logger.handle(e, st, _lm.settings_server_update_error);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseSettingWidget(
      title: widget.title,
      description: widget.description,
      icon: widget.icon,
      rowWidgetWidth: 200,
      breakpoint: widget.breakpoint,
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
      )
    );
  }
}