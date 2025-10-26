import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:vibin_app/dtos/album/album_edit_data.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/pages/edit/search_album_metadata_dialog.dart';
import 'package:vibin_app/widgets/edit/image_edit_field.dart';
import 'package:vibin_app/widgets/edit/responsive_edit_view.dart';

import '../../api/api_manager.dart';
import '../../auth/auth_state.dart';
import '../../main.dart';

class AlbumEditPage extends StatefulWidget {
  final int albumId;

  const AlbumEditPage({
    super.key,
    required this.albumId
  });

  @override
  State<AlbumEditPage> createState() => _AlbumEditPageState();
}

class _AlbumEditPageState extends State<AlbumEditPage> {

  final _apiManager = getIt<ApiManager>();
  final _authState = getIt<AuthState>();
  late String? _albumCoverUrl;

  late final _lm = AppLocalizations.of(context)!;
  late final _theme = Theme.of(context);

  bool _initialized = false;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _yearController = TextEditingController();

  final _yearRegexp = RegExp(r'^\d{4}$');

  @override
  void initState() {
    super.initState();
    _apiManager.service.getAlbum(widget.albumId).then((value) {
      setState(() {
        _titleController.text = value.album.title;
        _descriptionController.text = value.album.description;
        _yearController.text = value.album.year?.toString() ?? "";
        _albumCoverUrl = null;
        _initialized = true;
      });
      return;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _yearController.dispose();
    super.dispose();
  }
  
  void _showMetadataDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SearchAlbumMetadataDialog(onSelect: (metadata) {
          setState(() {
            _titleController.text = metadata.title;
            _descriptionController.text = metadata.description ?? "";
            _yearController.text = metadata.year?.toString() ?? "";
            _albumCoverUrl = metadata.coverImageUrl;
          });
        }, initialSearch: _titleController.text);
      }
    );
  }

  Future<void> _save() async {

    if (!_formKey.currentState!.validate()) return;

    try {
      final editData = AlbumEditData(
        title: _titleController.text,
        description: _descriptionController.text,
        year: _yearController.text.isEmpty ? null : int.tryParse(_yearController.text),
        coverUrl: _albumCoverUrl
      );
      await _apiManager.service.updateAlbum(widget.albumId, editData);
      imageCache.clear();
      imageCache.clearLiveImages();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context, true);
      });
    }
    catch (e) {
      log("Failed to save album: $e", error: e, level: Level.error.value);
      if (mounted) showErrorDialog(context, _lm.edit_album_save_error);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showConfirmDialog(context, _lm.delete_album_confirmation, _lm.delete_album_confirmation_warning);
    if (!confirmed) return;

    try {
      await _apiManager.service.deleteAlbum(widget.albumId);
      if (mounted) {
        GoRouter.of(context).go("/albums");
      }
    }
    catch (e) {
      log("Failed to delete album: $e", error: e, level: Level.error.value);
      if (mounted) showErrorDialog(context, _lm.delete_album_error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return !_initialized ? Center(child: CircularProgressIndicator()) : Material(
      child: Form(
        key: _formKey,
        child: ResponsiveEditView(
          title: _lm.edit_album_title,
          imageEditWidget: ImageEditField(
            onImageChanged: (albumCoverUrl) {
              setState(() {
                _albumCoverUrl = albumCoverUrl;
              });
            },
            fallbackImageUrl: "/api/albums/${widget.albumId}/cover",
            imageUrl: _albumCoverUrl,
            size: 256,
            label: _lm.edit_album_cover,
          ),
          actions: [
            if (_authState.hasPermission(PermissionType.deleteAlbums))
              ElevatedButton.icon(
                onPressed: _delete,
                icon: const Icon(Icons.delete_forever),
                label: Text(_lm.dialog_delete),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _theme.colorScheme.errorContainer,
                  foregroundColor: _theme.colorScheme.onErrorContainer,
                ),
              ),
            ElevatedButton.icon(
              onPressed: () { Navigator.pop(context); },
              icon: const Icon(Icons.cancel),
              label: Text(_lm.dialog_cancel),
              style: ElevatedButton.styleFrom(
                backgroundColor: _theme.colorScheme.secondaryContainer,
                foregroundColor: _theme.colorScheme.onSecondaryContainer,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _showMetadataDialog,
              icon: const Icon(Icons.search),
              label: Text(_lm.edit_album_search_metadata),
              style: ElevatedButton.styleFrom(
                backgroundColor: _theme.colorScheme.secondaryContainer,
                foregroundColor: _theme.colorScheme.onSecondaryContainer,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: Text(_lm.dialog_save),
              style: ElevatedButton.styleFrom(
                backgroundColor: _theme.colorScheme.primaryContainer,
                foregroundColor: _theme.colorScheme.onPrimaryContainer,
              ),
            )
          ],
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: _lm.edit_album_name,
              ),
              controller: _titleController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return _lm.edit_album_name_validation_empty;
                }
                if (value.length > 255) {
                  return _lm.edit_album_name_validation_length;
                }
                return null;
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: _lm.edit_album_description,
              ),
              controller: _descriptionController,
              maxLines: null,
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: _lm.edit_album_year,
              ),
              controller: _yearController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return null;
                }
                if (!_yearRegexp.hasMatch(value)) {
                  return _lm.edit_album_year_validation_not_number;
                }
                return null;
              }
            )
          ],
        ),
      ),
    );
  }
}