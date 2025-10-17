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

class TagEditDialog extends StatefulWidget {
  final int? tagId;
  final String? initialName;
  final String? initialDescription;
  final String? initialColor;
  final Function(Tag) onSave;
  final Function()? onDelete;

  const TagEditDialog({
    super.key,
    this.tagId,
    this.initialName,
    this.initialDescription,
    this.initialColor,
    required this.onSave,
    this.onDelete
  });

  @override
  State<TagEditDialog> createState() => _TagEditDialogState();
}

class _TagEditDialogState extends State<TagEditDialog> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController colorController;

  final ApiManager apiManager = getIt<ApiManager>();
  final AuthState authState = getIt<AuthState>();

  late AppLocalizations lm = AppLocalizations.of(context)!;

  final RegExp hexColorRegExp = RegExp(r'^#?[0-9a-fA-F]{6}$');

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialName ?? '');
    descriptionController = TextEditingController(text: widget.initialDescription ?? '');
    colorController = TextEditingController(text: widget.initialColor ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    colorController.dispose();
    super.dispose();
  }

  Future<bool> checkIfTagExists(String name) async {
    try {
      await apiManager.service.getTagByName(name);
      return true;
    }
    catch (e) {
      return false;
    }
  }

  Future<void> save() async {

    if (nameController.text != widget.initialName) {
      final exists = await checkIfTagExists(nameController.text);
      if (exists) {
        // Tag with this name already exists
        if (mounted) {
          showInfoDialog(context, lm.edit_tag_name_validation_already_exists);
        }
        return;
      }
    }

    if (!formKey.currentState!.validate()) return;

    final editData = TagEditData(
      name: nameController.text,
      description: descriptionController.text,
      color: colorController.text.isNotEmpty ? colorController.text : null
    );
    try {
      final tag = widget.tagId == null
        ? await apiManager.service.createTag(editData)
        : await apiManager.service.updateTag(widget.tagId!, editData);
      widget.onSave(tag);
      if (mounted) Navigator.pop(context);
    }
    catch (e) {
      log("An error occurred while saving the tag: $e", error: e, level: Level.error.value);
      if (mounted) showErrorDialog(context, lm.edit_tag_save_error);
    }
  }

  Future<void> delete() async {
    if (!await showConfirmDialog(context, lm.edit_tag_delete_confirmation, lm.edit_tag_delete_confirmation_warning)) {
      return;
    }
    if (widget.tagId != null) {
      late bool success;
      try {
        final response = await apiManager.service.deleteTag(widget.tagId!);
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
        if (mounted && context.mounted) showErrorDialog(context, lm.edit_tag_delete_error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.tagId == null ? lm.create_tag_title : lm.edit_tag_title),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: lm.edit_tag_name),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return lm.edit_tag_name_validation_empty;
                }
                if (value.length > 255) {
                  return lm.edit_tag_name_validation_length;
                }
                return null;
              },
            ),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: lm.edit_tag_description),
            ),
            TextFormField(
              controller: colorController,
              decoration: InputDecoration(labelText: lm.edit_tag_color),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return null;
                }
                if (!hexColorRegExp.hasMatch(value)) {
                  return lm.edit_tag_color_not_hex;
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        if (widget.tagId != null && authState.hasPermission(PermissionType.deleteTags))
          TextButton(
            onPressed: delete,
            child: Text(lm.dialog_delete),
          ),
        ElevatedButton(
          onPressed: save,
          child: Text(lm.dialog_save),
        ),
      ],
    );
  }
}