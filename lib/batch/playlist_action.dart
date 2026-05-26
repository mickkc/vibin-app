import 'package:flutter/material.dart';
import 'package:vibin_app/dialogs/playlist_picker.dart';
import 'package:vibin_app/l10n/app_localizations.dart';

import '../dtos/playlist/playlist.dart';
import 'batch_action_interface.dart';

class PlaylistAction implements BatchAction {
  final bool remove;
  Playlist? playlist;

  PlaylistAction(this.remove);

  @override
  Widget build(BuildContext context) => _PlaylistActionWidget(this);

  @override
  Map<String, dynamic> dataToJson() => {
    "actionType": remove ? "REMOVE_FROM_PLAYLIST" : "ADD_TO_PLAYLIST",
    "data": {
      "id": playlist?.id
    }
  };

  @override
  String getName(AppLocalizations lm) => remove ? lm.batch_edit_actions_remove_from_playlist : lm.batch_edit_actions_add_to_playlist;
}

class _PlaylistActionWidget extends StatefulWidget {
  final PlaylistAction action;
  const _PlaylistActionWidget(this.action);

  @override
  State<_PlaylistActionWidget> createState() => _PlaylistActionWidgetState();
}

class _PlaylistActionWidgetState extends State<_PlaylistActionWidget> {

  late final _lm = AppLocalizations.of(context)!;

  late final TextEditingController _playlistController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    _playlistController = TextEditingController(text: _formatPlaylist(widget.action.playlist));
    _focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _playlistController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _formatPlaylist(Playlist? playlist) {
    if (playlist == null) return "";
    return "${playlist.name} - id: ${playlist.id} - ${playlist.owner.displayName ?? playlist.owner.username}";
  }

  void _openDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return PlaylistPicker(
          selectedPlaylist: widget.action.playlist,
          onPlaylistSelected: (playlist) {
            setState(() {
              widget.action.playlist = playlist;
              _playlistController.text = _formatPlaylist(playlist);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _focusNode.unfocus();
              });
            });
          },
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        Text("${_lm.playlist}:"),
        Expanded(
          child: TextField(
            controller: _playlistController,
            readOnly: true,
            onTap: _openDialog,
            focusNode: _focusNode,
            decoration: InputDecoration(
              border: OutlineInputBorder()
            ),
          ),
        )
      ],
    );
  }
}