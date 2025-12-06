import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:vibin_app/dtos/playlist/playlist_edit_data.dart';
import 'package:vibin_app/widgets/network_image.dart';

import '../dtos/playlist/playlist.dart';
import '../utils/error_handler.dart';
import 'base_search_dialog.dart';

class AddTrackToPlaylistDialog extends BaseSearchDialog<Playlist> {

  final int trackId;
  final void Function(List<int>)? onPlaylistsModified;

  const AddTrackToPlaylistDialog({
    super.key,
    required this.trackId,
    this.onPlaylistsModified,
  });

  static Future<void> show(BuildContext context, int trackId, { void Function(List<int>)? onPlaylistsModified }) {
    return showDialog(
      context: context,
      builder: (context) => AddTrackToPlaylistDialog(
        trackId: trackId,
        onPlaylistsModified: onPlaylistsModified,
      ),
    );
  }

  @override
  State<AddTrackToPlaylistDialog> createState() => _AddTrackToPlaylistDialog();
}

class _AddTrackToPlaylistDialog extends BaseSearchDialogState<Playlist, AddTrackToPlaylistDialog> {

  List<Playlist> _playlistsContainingTrack = [];
  final List<int> _modifiedPlaylists = [];

  @override
  void initState() {
    super.initState();

    apiManager.service.getPlaylistsContainingTrack(widget.trackId).then((value) {
      setState(() {
        _playlistsContainingTrack = value;
      });
    });
  }

  late final _theme = Theme.of(context);

  @override
  String get dialogTitle => lm.add_track_to_playlist_title;

  @override
  Future<void> search({int page = 1}) async {
    final results = await apiManager.service.getPlaylists(page, 20, searchController.text, true);
    setState(() {
      searchResultPagination = results;
    });
  }

  @override
  Widget? buildCreateNewItem(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.add),
      title: Text(lm.pick_playlist_create_new(searchController.text)),
      onTap: () async {
        try {
          final newPlaylist = await apiManager.service.createPlaylist(PlaylistEditData(name: searchController.text));
          await apiManager.service.addTrackToPlaylist(newPlaylist.id, widget.trackId);
          setState(() {
            _playlistsContainingTrack.add(newPlaylist);
            searchController.clear();
          });
          search();
        }
        catch (e, st) {
          log("An error occurred while creating playlist: $e", error: e, level: Level.error.value);
          if (context.mounted) ErrorHandler.showErrorDialog(context, lm.pick_playlist_create_error, error: e, stackTrace: st);
        }
      },
    );
  }

  @override
  Widget buildListItem(BuildContext context, Playlist item, int index) {
    final containsTrack = _playlistsContainingTrack.any((p) => p.id == item.id);
    return ListTile(
      leading: NetworkImageWidget(
        url: "/api/playlists/${item.id}/image?quality=64",
        width: 48,
        height: 48,
        fit: BoxFit.contain
      ),
      title: Text(item.name),
      subtitle: item.description.isEmpty
        ? null
        : Text(item.description),
      trailing: containsTrack
        ? Icon(Icons.check, color: _theme.colorScheme.primary)
        : null,
      onTap: () async {
        try {
          if (!containsTrack) {
            await apiManager.service.addTrackToPlaylist(item.id, widget.trackId);
            setState(() {
              _playlistsContainingTrack.add(item);
            });
          } else {
            await apiManager.service.removeTrackFromPlaylist(item.id, widget.trackId);
            setState(() {
              _playlistsContainingTrack.removeWhere((p) => p.id == item.id);
            });
          }

          if (!_modifiedPlaylists.contains(item.id)) {
            _modifiedPlaylists.add(item.id);
          }
          else {
            _modifiedPlaylists.remove(item.id);
          }
        }
        catch (e, st) {
          log("An error occurred while modifying playlist: $e", error: e, level: Level.error.value);
          if (context.mounted) ErrorHandler.showErrorDialog(context, containsTrack ? lm.pick_playlist_track_remove_error : lm.pick_playlist_track_add_error, error: e, stackTrace: st);
        }
      }
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      TextButton(
        onPressed: () {
          if (widget.onPlaylistsModified != null) {
            widget.onPlaylistsModified!(_modifiedPlaylists);
          }
          Navigator.of(context).pop();
        },
        child: Text(lm.dialog_finish)
      )
    ];
  }

}