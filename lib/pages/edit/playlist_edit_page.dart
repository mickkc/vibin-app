import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/auth/AuthState.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/dtos/playlist/playlist_edit_data.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/main.dart';
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

  GoRouter get router => GoRouter.of(context);
  AppLocalizations get lm => AppLocalizations.of(context)!;
  ThemeData get theme => Theme.of(context);

  String? coverUrl;
  bool public = false;

  final formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController vibedefController;

  late ApiManager apiManager = getIt<ApiManager>();
  late AuthState authState = getIt<AuthState>();

  bool initialized = false;

  @override
  void initState() {
    nameController = TextEditingController();
    descriptionController = TextEditingController();
    vibedefController = TextEditingController();
    super.initState();

    if (widget.playlistId != null) {
      apiManager.service.getPlaylist(widget.playlistId!).then((value) {
        setState(() {
          nameController.text = value.playlist.name;
          descriptionController.text = value.playlist.description;
          coverUrl = null;
          vibedefController.text = value.playlist.vibedef ?? "";
          public = value.playlist.public;
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
    nameController.dispose();
    descriptionController.dispose();
    vibedefController.dispose();
    super.dispose();
  }

  Future<void> save() async {

    if (!formKey.currentState!.validate()) return;

    try {
      final editData = PlaylistEditData(
        name: nameController.text,
        description: descriptionController.text,
        vibedef: vibedefController.text.isEmpty ? null : vibedefController.text,
        isPublic: public,
        coverImageUrl: coverUrl
      );

      final playlist = widget.playlistId == null
          ? await apiManager.service.createPlaylist(editData)
          : await apiManager.service.updatePlaylist(widget.playlistId!, editData);

      if (widget.playlistId == null) {
        router.replace("/playlists/${playlist.id}");
      }
      else {
        imageCache.clear();
        router.pop();
      }
    }
    catch (e) {
      log("Error saving playlist", error: e, level: Level.error.value);
      if (mounted) showErrorDialog(context, lm.edit_playlist_save_error);
    }
  }

  Future<void> delete() async {

    if (!await showConfirmDialog(context, lm.delete_playlist_confirmation, lm.delete_playlist_confirmation_warning)) {
      return;
    }

    try {
      await apiManager.service.deletePlaylist(widget.playlistId!);
      if (mounted) router.go("/");
    }
    catch (e) {
      if (mounted) showErrorDialog(context, lm.delete_playlist_error);
    }
  }

  bool allowVisibilityChange() {
    if (public && !authState.hasPermission(PermissionType.createPrivatePlaylists)) return false;
    if (!public && !authState.hasPermission(PermissionType.createPublicPlaylists)) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return !initialized ? Center(child: CircularProgressIndicator()) : Form(
      key: formKey,
      child: ResponsiveEditView(
        title: lm.edit_playlist_title,
        actions: [
          if (widget.playlistId != null)
            ElevatedButton.icon(
              onPressed: delete,
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
            onPressed: save,
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
              coverUrl = url;
            });
          },
          fallbackImageUrl: widget.playlistId != null ? "/api/playlists/${widget.playlistId}/image" : null,
          label: lm.edit_playlist_cover,
          imageUrl: coverUrl,
          size: 256
        ),
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: lm.edit_playlist_name,
            ),
            controller: nameController,
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
            controller: descriptionController,
            maxLines: null,
          ),
          TextField(
            decoration: InputDecoration(
              labelText: lm.edit_playlist_vibedef,
            ),
            controller: vibedefController,
            maxLines: null,
          ),
          if (allowVisibilityChange())
            SwitchListTile(
              title: Text(lm.edit_playlist_public),
              value: public,
              onChanged: (value) {
                setState(() {
                  public = value;
                });
              },
              thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) => states.contains(WidgetState.selected) ? Icon(Icons.public) : Icon(Icons.lock))
            ),
        ],
      ),
    );
  }
}