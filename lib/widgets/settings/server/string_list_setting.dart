import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/widgets/settings/settings_title.dart';

import '../../../api/api_manager.dart';
import '../../../l10n/app_localizations.dart';
import '../../../main.dart';

class StringListSetting extends StatefulWidget {
  final String settingKey;
  final List<dynamic> initialValue;
  final String title;
  final String? description;
  final void Function(List<String>)? onChanged;
  final Widget Function(BuildContext, String)? itemBuilder;

  const StringListSetting({
    super.key,
    required this.settingKey,
    required this.initialValue,
    required this.title,
    this.description,
    this.onChanged,
    this.itemBuilder,
  });

  @override
  State<StringListSetting> createState() => _StringListSettingState();
}

class _StringListSettingState extends State<StringListSetting> {

  final _newItemController = TextEditingController();
  late List<String> _value = widget.initialValue.map((e) => e as String).toList();

  final _apiManager = getIt<ApiManager>();
  late final _lm = AppLocalizations.of(context)!;

  Future<void> _save() async {
    try {
      final updated = await _apiManager.service.updateServerSetting(widget.settingKey, jsonEncode(_value));
      _value = (updated.value as List<dynamic>).map((e) => e as String).toList();
    }
    catch (e) {
      log("Failed to save setting ${widget.settingKey}: $e", error: e, level: Level.error.value);
      if (mounted) showErrorDialog(context, _lm.settings_server_update_error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SettingsTitle(title: widget.title, subtitle: widget.description),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _value.length,
          itemBuilder: (context, index) {
            final item = _value[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                title: widget.itemBuilder != null
                    ? widget.itemBuilder!(context, item)
                    : Text(item),
                tileColor: Theme.of(context).colorScheme.surfaceContainerLow,
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () async {
                    setState(() {
                      _value.removeAt(index);
                    });
                    await _save();
                    if (widget.onChanged != null) {
                      widget.onChanged!(_value);
                    }
                  },
                ),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newItemController,
                  decoration: InputDecoration(
                    labelText: _lm.add_item,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  final newItem = _newItemController.text;
                  if (newItem.isNotEmpty && !_value.contains(newItem)) {
                    setState(() {
                      _value.add(newItem);
                      _newItemController.clear();
                    });
                    await _save();
                    if (widget.onChanged != null) {
                      widget.onChanged!(_value);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ]
    );
  }

}