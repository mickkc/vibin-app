import 'package:flutter/material.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/settings/settings_key.dart';
import 'package:vibin_app/settings/settings_manager.dart';
import 'package:vibin_app/widgets/settings/settings_title.dart';

import '../../main.dart';

class OrderedMapSettingsView extends StatefulWidget {

  final String title;
  final String? subtitle;

  final OrderedMapSettingsKey settingsKey;
  final String Function(String, AppLocalizations) nameFunc;

  const OrderedMapSettingsView({
    super.key,
    required this.title,
    this.subtitle,
    required this.settingsKey,
    required this.nameFunc
  });

  @override
  State<OrderedMapSettingsView> createState() => _OrderedMapSettingsViewState();
}

class _OrderedMapSettingsViewState extends State<OrderedMapSettingsView> {

  final _settingsManager = getIt<SettingsManager>();
  
  late List<Entry<String, String>> _currentValue;
  late final _lm = AppLocalizations.of(context)!;
  late final _cs = Theme.of(context).colorScheme;

  @override
  void initState() {
    _currentValue = _settingsManager.getFilledMap(widget.settingsKey, true.toString());
    super.initState();
  }

  void _toggleEntry(String entryKey) {
    setState(() {
      final entry = _currentValue.firstWhere((s) => s.key == entryKey);
      entry.value = (entry.value == false.toString()).toString();
    });
    _save();
  }

  void _save() {
    _settingsManager.set(widget.settingsKey, _currentValue);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsTitle(
          title: widget.title,
          subtitle: widget.subtitle,
        ),
        ReorderableListView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            for (int index = 0; index < _currentValue.length; index++)
              Padding(
                key: Key('$index'),
                padding: const EdgeInsets.all(2.0),
                child: ListTile(
                  title: Text(widget.nameFunc(_currentValue[index].key, _lm)),
                  leading: Checkbox(
                    value: _currentValue[index].value == true.toString(),
                    onChanged: (value) {
                      _toggleEntry(_currentValue[index].key);
                    },
                  ),
                  tileColor: _cs.surfaceContainer,
                ),
              ),
          ],
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final key = _currentValue.elementAt(oldIndex);
              final entry = _currentValue.firstWhere((s) => s.key == key.key);
              _currentValue.remove(entry);
              _currentValue.insert(newIndex, entry);
              _save();
            });
          },
        ),
      ],
    );
  }
}