import 'package:flutter/material.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/widgets/future_content.dart';
import 'package:vibin_app/widgets/network_image.dart';

import '../api/api_manager.dart';
import '../main.dart';

class AddTrackToPlaylistDialog {

  static Future<void> show(int trackId, BuildContext context) async {

    final apiManager = getIt<ApiManager>();

    // TODO: Create a better endpoint that returns all playlists
    final playlistsFuture = apiManager.service.getPlaylists(1, 100);
    final playlistsContainingTrack = await apiManager.service.getPlaylistsContainingTrack(trackId);

    final lm = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    await showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  lm.add_track_to_playlist_title,
                  style: theme.textTheme.titleLarge
                ),
                Divider(),
                Expanded(
                  child: FutureContent(
                    future: playlistsFuture,
                    hasData: (data) => data.items.isNotEmpty,
                    builder: (context, playlists) {
                      return ListView.builder(
                        itemCount: playlists.items.length,
                        itemBuilder: (context, index) {
                          final playlist = playlists.items[index];
                          final containsTrack = playlistsContainingTrack.any((p) => p.id == playlist.id);
                          return ListTile(
                            leading: NetworkImageWidget(
                              url: "/api/playlists/${playlist.id}/image",
                              width: 48,
                              height: 48,
                              fit: BoxFit.contain
                            ),
                            title: Text(playlist.name),
                            subtitle: playlist.description.isEmpty
                              ? null
                              : Text(playlist.description),
                            trailing: containsTrack
                              ? Icon(Icons.check, color: theme.colorScheme.primary)
                              : null,
                            onTap: () async {
                              if (!containsTrack) {
                                await apiManager.service.addTrackToPlaylist(playlist.id, trackId);
                                playlistsContainingTrack.add(playlist);
                              } else {
                                await apiManager.service.removeTrackFromPlaylist(playlist.id, trackId);
                                playlistsContainingTrack.removeWhere((p) =>
                                p.id == playlist.id);
                              }

                              // TODO: Check if there's a better way to refresh the dialog
                              (context as Element).markNeedsBuild();
                            },
                          );
                        },
                      );
                    }
                  ),
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () { Navigator.of(context).pop(); },
                      child: Text(lm.dialog_finish)
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

}