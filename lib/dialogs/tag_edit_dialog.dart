import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/auth/auth_state.dart';
import 'package:vibin_app/dtos/tags/tag.dart';
import 'package:vibin_app/dtos/tags/tag_edit_data.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/main.dart';

import '../dtos/permission_type.dart';
import '../utils/error_handler.dart';

class TagEditDialog extends StatefulWidget {
  final int? tagId;
  final String? initialName;
  final String? initialDescription;
  final int? initialImportance;
  final Function(Tag) onSave;
  final Function()? onDelete;

  const TagEditDialog({
    super.key,
    this.tagId,
    this.initialName,
    this.initialDescription,
    this.initialImportance,
    required this.onSave,
    this.onDelete
  });

  @override
  State<TagEditDialog> createState() => _TagEditDialogState();
}

class _TagEditDialogState extends State<TagEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  late int _importance;

  final _apiManager = getIt<ApiManager>();
  final _authState = getIt<AuthState>();

  late final _lm = AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _descriptionController = TextEditingController(text: widget.initialDescription ?? '');
    _importance = widget.initialImportance ?? 10;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<bool> _checkIfTagExists(String name) async {
    try {
      await _apiManager.service.getTagByName(name);
      return true;
    }
    catch (e) {
      return false;
    }
  }

  Future<void> _save() async {

    if (_nameController.text != widget.initialName) {
      final exists = await _checkIfTagExists(_nameController.text);
      if (exists) {
        // Tag with this name already exists
        if (mounted) {
          showInfoDialog(context, _lm.edit_tag_name_validation_already_exists);
        }
        return;
      }
    }

    if (!_formKey.currentState!.validate()) return;

    final editData = TagEditData(
      name: _nameController.text,
      description: _descriptionController.text,
      importance: _importance
    );
    try {
      final tag = widget.tagId == null
        ? await _apiManager.service.createTag(editData)
        : await _apiManager.service.updateTag(widget.tagId!, editData);
      widget.onSave(tag);
      if (mounted) Navigator.pop(context);
    }
    catch (e, st) {
      log("An error occurred while saving the tag: $e", error: e, level: Level.error.value);
      if (mounted) ErrorHandler.showErrorDialog(context, _lm.edit_tag_save_error, error: e, stackTrace: st);
    }
  }

  Future<void> _delete() async {
    if (!await showConfirmDialog(context, _lm.edit_tag_delete_confirmation, _lm.edit_tag_delete_confirmation_warning)) {
      return;
    }
    if (widget.tagId != null) {
      late bool success;
      try {
        final response = await _apiManager.service.deleteTag(widget.tagId!);
        if (response.success && widget.onDelete != null) {
          widget.onDelete!();
        }
        success = response.success;
      }
      catch (e) {
        log("An error occurred while deleting the tag: $e", error: e, level: Level.error.value);
        success = false;
      }

      if (success) {
        if (mounted && context.mounted) Navigator.pop(context);
      } else {
        if (mounted && context.mounted) ErrorHandler.showErrorDialog(context, _lm.edit_tag_delete_error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.tagId == null ? _lm.create_tag_title : _lm.edit_tag_title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: _lm.edit_tag_name),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return _lm.edit_tag_name_validation_empty;
                }
                if (value.length > 255) {
                  return _lm.edit_tag_name_validation_length;
                }
                return null;
              },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: _lm.edit_tag_description),
            ),

            Row(
              spacing: 8,
              children: [
                Text(_lm.edit_tag_importance),
                Expanded(
                  child: Slider(
                    value: _importance.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: _importance.toString(),
                    onChanged: (value) {
                      setState(() {
                        _importance = value.toInt();
                      });
                    },
                  ),
                ),
                Text(_importance.toString()),
              ],
            )
          ],
        ),
      ),
      actions: [
        if (widget.tagId != null && _authState.hasPermission(PermissionType.deleteTags))
          TextButton(
            onPressed: _delete,
            child: Text(_lm.dialog_delete),
          ),
        ElevatedButton(
          onPressed: _save,
          child: Text(_lm.dialog_save),
        ),
      ],
    );
  }
}