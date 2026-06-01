import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vibin_app/dtos/tags/tag.dart';
import 'package:vibin_app/widgets/edit/tag_search_bar.dart';

import '../../../api/api_manager.dart';
import '../../../l10n/app_localizations.dart';
import '../../../main.dart';

class ServerTagListField extends StatefulWidget {

  final String settingKey;
  final String title;
  final String? description;
  final List<Tag> initialValues;
  final IconData? icon;

  const ServerTagListField({
    super.key,
    required this.settingKey,
    required this.title,
    this.description,
    required this.initialValues,
    this.icon,
  });

  @override
  State<ServerTagListField> createState() => _ServerTagListFieldState();
}

class _ServerTagListFieldState extends State<ServerTagListField> {
  
  late final List<Tag> _selectedTags = List.from(widget.initialValues);

  final _apiManager = getIt<ApiManager>();
  late final _lm = AppLocalizations.of(context)!;

  Future<void> _save() async {
    try {
      final tagIds = _selectedTags.map((tag) => tag.id).toList();
      await _apiManager.service.updateSetting(widget.settingKey, jsonEncode(tagIds));
    }
    catch (e, st) {
      logger.handle(e, st, _lm.settings_server_update_error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: widget.icon != null ? Icon(widget.icon) : null,
          title: Text(widget.title),
          subtitle: widget.description != null ? Text(widget.description!) : null,
        ),
        
        Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              if (_selectedTags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: _selectedTags.map((option) {
                    return Chip(
                      label: Text(option.name),
                      onDeleted: () {
                        setState(() {
                          _selectedTags.remove(option);
                        });
                        _save();
                      }
                    );
                  }).toList(),
                ),

              TagSearchBar(
                ignoredTags: _selectedTags,
                onTagSelected: (Tag tag) {
                  setState(() {
                    _selectedTags.add(tag);
                  });
                  _save();
                },
              )
            ]
          ),
        )
      ],
    );
  }
}