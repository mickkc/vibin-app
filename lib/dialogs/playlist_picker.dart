import 'package:flutter/material.dart';
import 'package:vibin_app/dialogs/base_search_dialog.dart';
import 'package:vibin_app/dtos/playlist/playlist.dart';
import 'package:vibin_app/dtos/playlist/playlist_edit_data.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/widgets/network_image.dart';

class PlaylistPicker extends BaseSearchDialog<Playlist> {

  final Playlist? selectedPlaylist;
  final Function(Playlist) onPlaylistSelected;

  const PlaylistPicker({
    super.key,
    this.selectedPlaylist,
    required this.onPlaylistSelected,
  });

  @override
  State<PlaylistPicker> createState() => _PlaylistPickerState();
}

class _PlaylistPickerState extends BaseSearchDialogState<Playlist, PlaylistPicker> {

  @override
  String get dialogTitle => lm.pick_playlist_title;

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
          widget.onPlaylistSelected(newPlaylist);
          if (context.mounted) Navigator.pop(context);
        }
        catch (e, st) {
          logger.handle(e, st, lm.pick_playlist_create_error);
        }
      },
    );
  }

  @override
  Widget buildListItem(BuildContext context, Playlist playlist, int index) {
    final isSelected = widget.selectedPlaylist?.id == playlist.id;
    return ListTile(
      leading: NetworkImageWidget(
        url: "/api/playlists/${playlist.id}/image?quality=64",
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(4),
      ),
      title: Text(playlist.name),
      subtitle: playlist.description.isNotEmpty ? Text(playlist.description) : null,
      trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
      onTap: () {
        widget.onPlaylistSelected(playlist);
        Navigator.pop(context);
      },
    );
  }
}