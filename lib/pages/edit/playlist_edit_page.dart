import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/auth/AuthState.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/dtos/playlist/playlist.dart';
import 'package:vibin_app/dtos/playlist/playlist_edit_data.dart';
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

  late String name;
  late String? description;
  late String? coverUrl;
  late String? vibedef;
  late bool public;

  late ApiManager apiManager = getIt<ApiManager>();
  late AuthState authState = getIt<AuthState>();

  bool initialized = false;

  Future<Playlist> create() async {
    try {
      final editData = PlaylistEditData(
        name: name,
        description: description,
        vibedef: vibedef,
        isPublic: public,
        coverImageUrl: coverUrl
      );
      final playlist = await apiManager.service.createPlaylist(editData);
      return playlist;
    }
    catch (e) {
      return Future.error(e);
    }
  }

  Future<Playlist> update() async {
    try {
      final editData = PlaylistEditData(
        name: name,
        description: description,
        vibedef: vibedef,
        isPublic: public,
        coverImageUrl: coverUrl
      );
      final playlist = await apiManager.service.updatePlaylist(widget.playlistId!, editData);
      return playlist;
    }
    catch (e) {
      return Future.error(e);
    }
  }

  Future<void> delete() async {
    final lm = AppLocalizations.of(context)!;
    final router = GoRouter.of(context);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lm.delete_playlist_confirmation),
        content: Text(lm.delete_playlist_confirmation_warning),
        actions: [
          TextButton(
            onPressed: () {
              router.pop();
            },
            child: Text(AppLocalizations.of(context)!.dialog_no),
          ),
          TextButton(
            onPressed: () async {
              try {
                await apiManager.service.deletePlaylist(widget.playlistId!);
                if (context.mounted) {
                  router.pop();
                  router.go("/");
                }
              }
              catch (e) {
                if (context.mounted) {
                  router.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(lm.delete_playlist_error))
                  );
                }
              }
            },
            child: Text(AppLocalizations.of(context)!.dialog_yes),
          ),
        ],
      )
    );
  }

  bool allowVisibilityChange() {
    if (public && !authState.hasPermission(PermissionType.createPrivatePlaylists)) return false;
    if (!public && !authState.hasPermission(PermissionType.createPublicPlaylists)) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final lm = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (widget.playlistId != null) {
      apiManager.service.getPlaylist(widget.playlistId!).then((value) {
        if (initialized) return;
        setState(() {
          name = value.playlist.name;
          description = value.playlist.description;
          coverUrl = null;
          vibedef = value.playlist.vibedef ?? "";
          public = value.playlist.public;
        });
        initialized = true;
        return;
      });
    }
    else {
      if (!initialized) {
        name = "";
        description = "";
        coverUrl = null;
        vibedef = "";
        public = false;
        initialized = true;
      }
    }

    return !initialized ? CircularProgressIndicator() : ResponsiveEditView(
      title: lm.edit_playlist_title,
      actions: [
        if (widget.playlistId != null)
          ElevatedButton.icon(
            onPressed: () async {
              await delete();
            },
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
          onPressed: () async {
            try {
              final playlist = await (widget.playlistId == null ? create() : update());
              if (context.mounted) {
                final router = GoRouter.of(context);
                if (widget.playlistId == null) {
                  router.replace("/playlists/${playlist.id}");
                }
                else {
                  imageCache.clear();
                  router.pop();
                }
              }
            }
            catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(lm.edit_playlist_save_error))
                );
              }
            }
          },
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
        TextField(
          decoration: InputDecoration(
            labelText: lm.edit_playlist_name,
          ),
          controller: TextEditingController(text: name),
          onChanged: (value) => name = value,
        ),
        TextField(
          decoration: InputDecoration(
            labelText: lm.edit_playlist_description,
          ),
          controller: TextEditingController(text: description),
          onChanged: (value) => description = value,
          maxLines: null,
        ),
        TextField(
          decoration: InputDecoration(
            labelText: lm.edit_playlist_vibedef,
          ),
          controller: TextEditingController(text: vibedef),
          onChanged: (value) => vibedef = value,
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
    );
  }
}