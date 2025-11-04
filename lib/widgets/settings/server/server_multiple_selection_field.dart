import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:vibin_app/utils/error_handler.dart';

import '../../../api/api_manager.dart';
import '../../../l10n/app_localizations.dart';
import '../../../main.dart';

class ServerMultipleSelectionField<T> extends StatefulWidget {
  final String settingKey;
  final String title;
  final String? description;
  final IconData? icon;
  final List<T> initialValues;
  final String Function(T) displayString;
  final String Function(List<T>) toServerFormat;
  final Function(List<T>, Function(List<T>)) dialog;

  const ServerMultipleSelectionField({
    super.key,
    required this.settingKey,
    required this.title,
    this.description,
    this.icon,
    required this.initialValues,
    required this.displayString,
    required this.toServerFormat,
    required this.dialog,
  });

  @override
  State<ServerMultipleSelectionField<T>> createState() => _ServerMultipleSelectionFieldState<T>();
}

class _ServerMultipleSelectionFieldState<T> extends State<ServerMultipleSelectionField<T>> {

  late List<T> _selectedValues = List.from(widget.initialValues);

  final apiManager = getIt<ApiManager>();
  late final lm = AppLocalizations.of(context)!;

  Future<void> _save() async {
    try {
      final serverValue = widget.toServerFormat(_selectedValues);
      await apiManager.service.updateSetting(widget.settingKey, serverValue);
    }
    catch (e, st) {
      log("Failed to save setting ${widget.settingKey}: $e", error: e, level: Level.error.value);
      if (mounted) ErrorHandler.showErrorDialog(context, lm.settings_server_update_error, error: e, stackTrace: st);
    }
  }

  Future<void> _showDialog() async {
    await widget.dialog(_selectedValues, (newValues) {
      setState(() {
        _selectedValues = newValues;
      });
      _save();
    });
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: widget.icon != null ? Icon(widget.icon) : null,
          title: Text(widget.title, style: theme.textTheme.titleMedium),
          subtitle: widget.description != null ? Text(widget.description!) : null,
        ),

        Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              if (_selectedValues.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: _selectedValues.map((option) {
                    return Chip(
                      label: Text(widget.displayString(option)),
                      onDeleted: () {
                        setState(() {
                          _selectedValues.remove(option);
                        });
                        _save();
                      }
                    );
                  }).toList(),
                ),

              TextButton(
                onPressed: _showDialog,
                child: Text(lm.add_item),
              ),
            ],
          ),
        )
      ],
    );
  }
}