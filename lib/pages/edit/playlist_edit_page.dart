import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/auth/auth_state.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/dtos/playlist/playlist_edit_data.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/utils/dialogs.dart';
import 'package:vibin_app/utils/error_handler.dart';
import 'package:vibin_app/widgets/edit/image_edit_field.dart';
import 'package:vibin_app/widgets/edit/responsive_edit_view.dart';

import '../../l10n/app_localizations.dart';

class PlaylistEditPage extends StatefulWidget {

  final int? playlistId;

  const PlaylistEditPage({
    super.key,
    required this.playlistId,
  });

  @override
  State<PlaylistEditPage> createState() => _PlaylistEditPageState();
}

class _PlaylistEditPageState extends State<PlaylistEditPage> {

  late final router = GoRouter.of(context);
  late final lm = AppLocalizations.of(context)!;
  late final theme = Theme.of(context);

  String? _coverUrl;
  bool _public = false;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _vibedefController;

  final _apiManager = getIt<ApiManager>();
  final _authState = getIt<AuthState>();

  bool initialized = false;

  @override
  void initState() {
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _vibedefController = TextEditingController();
    super.initState();

    if (widget.playlistId != null) {
      _apiManager.service.getPlaylist(widget.playlistId!).then((value) {
        setState(() {
          _nameController.text = value.playlist.name;
          _descriptionController.text = value.playlist.description;
          _coverUrl = null;
          _vibedefController.text = value.playlist.vibedef ?? "";
          _public = value.playlist.public;
          initialized = true;
        });
      });
    }
    else {
      initialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _vibedefController.dispose();
    super.dispose();
  }

  Future<void> _save() async {

    if (!_formKey.currentState!.validate()) return;

    try {
      final editData = PlaylistEditData(
        name: _nameController.text,
        description: _descriptionController.text,
        vibedef: _vibedefController.text.isEmpty ? null : _vibedefController.text,
        isPublic: _public,
        coverImageUrl: _coverUrl
      );

      final playlist = widget.playlistId == null
          ? await _apiManager.service.createPlaylist(editData)
          : await _apiManager.service.updatePlaylist(widget.playlistId!, editData);

      if (widget.playlistId == null) {
        router.replace("/playlists/${playlist.id}");
      }
      else {
        imageCache.clear();
        router.pop();
      }
    }
    catch (e, st) {
      log("Error saving playlist", error: e, level: Level.error.value);
      if (mounted) ErrorHandler.showErrorDialog(context, lm.edit_playlist_save_error, error: e, stackTrace: st);
    }
  }

  Future<void> _delete() async {

    if (!await Dialogs.showConfirmDialog(context, lm.delete_playlist_confirmation, lm.delete_playlist_confirmation_warning)) {
      return;
    }

    try {
      await _apiManager.service.deletePlaylist(widget.playlistId!);
      if (mounted) router.go("/");
    }
    catch (e, st) {
      if (mounted) ErrorHandler.showErrorDialog(context, lm.delete_playlist_error, error: e, stackTrace: st);
    }
  }

  bool _allowVisibilityChange() {
    if (_public && !_authState.hasPermission(PermissionType.createPrivatePlaylists)) return false;
    if (!_public && !_authState.hasPermission(PermissionType.createPublicPlaylists)) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return !initialized ? Center(child: CircularProgressIndicator()) : Form(
      key: _formKey,
      child: ResponsiveEditView(
        title: lm.edit_playlist_title,
        actions: [
          if (widget.playlistId != null)
            ElevatedButton.icon(
              onPressed: _delete,
              icon: Icon(Icons.delete),
              label: Text(lm.dialog_delete),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.errorContainer,
                foregroundColor: theme.colorScheme.onErrorContainer,
              ),
            ),
          ElevatedButton.icon(
            onPressed: () {
              if (context.mounted) {
                GoRouter.of(context).pop();
              }
            },
            icon: Icon(Icons.cancel),
            label: Text(lm.dialog_cancel),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondaryContainer,
              foregroundColor: theme.colorScheme.onSecondaryContainer,
            ),
          ),
          ElevatedButton.icon(
            onPressed: _save,
            icon: Icon(Icons.save),
            label: Text(lm.dialog_save),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
            ),
          )
        ],
        imageEditWidget: ImageEditField(
          onImageChanged: (url) {
            setState(() {
              _coverUrl = url;
            });
          },
          fallbackImageUrl: widget.playlistId != null ? "/api/playlists/${widget.playlistId}/image" : null,
          label: lm.edit_playlist_cover,
          imageUrl: _coverUrl,
          size: 256
        ),
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: lm.edit_playlist_name,
            ),
            controller: _nameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return lm.edit_playlist_name_validation_empty;
              }
              if (value.length > 255) {
                return lm.edit_playlist_name_validation_length;
              }
              return null;
            },
          ),
          TextField(
            decoration: InputDecoration(
              labelText: lm.edit_playlist_description,
            ),
            controller: _descriptionController,
            maxLines: null,
          ),
          TextField(
            decoration: InputDecoration(
              labelText: lm.edit_playlist_vibedef,
            ),
            controller: _vibedefController,
            maxLines: null,
          ),
          if (_allowVisibilityChange())
            SwitchListTile(
              title: Text(lm.edit_playlist_public),
              value: _public,
              onChanged: (value) {
                setState(() {
                  _public = value;
                });
              },
              thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) => states.contains(WidgetState.selected) ? Icon(Icons.public) : Icon(Icons.lock))
            ),
        ],
      ),
    );
  }
}