import 'package:flutter/material.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/settings/settings_key.dart';
import 'package:vibin_app/settings/settings_manager.dart';

class StringSettingsField extends StatefulWidget {
  final StringSettingsKey settingsKey;
  final String label;
  final String? description;
  final IconData? icon;
  final double fieldWidth;

  const StringSettingsField({
    super.key,
    required this.settingsKey,
    required this.label,
    this.description,
    this.icon,
    this.fieldWidth = 100
  });

  @override
  State<StringSettingsField> createState() => _StringSettingsFieldState();
}

class _StringSettingsFieldState extends State<StringSettingsField> {

  final _settingsManager = getIt<SettingsManager>();

  late String _value = _settingsManager.get(widget.settingsKey);
  late final _controller = TextEditingController(text: _value);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: widget.icon != null ? Icon(widget.icon) : null,
      title: Text(widget.label),
      subtitle: widget.description != null ? Text(widget.description!) : null,
      trailing: SizedBox(
        width: widget.fieldWidth,
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          ),
          textAlign: TextAlign.start,
          onSubmitted: (text) {
            _settingsManager.set(widget.settingsKey, text);
            setState(() {
              _value = text;
            });
          },
        ),
      )
    );
  }
}