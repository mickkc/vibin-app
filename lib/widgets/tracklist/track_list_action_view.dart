import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/auth/auth_state.dart';
import 'package:vibin_app/dtos/track/base_track.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/utils/track_downloader.dart';
import 'package:vibin_app/widgets/tracklist/track_list_artist_view.dart';

import '../../audio/audio_manager.dart';
import '../../dialogs/add_track_to_playlist_dialog.dart';
import '../../dtos/permission_type.dart';
import '../icon_text.dart';

class TrackListActionView extends StatelessWidget {

  final BaseTrack track;
  final int? playlistId;
  final int? albumId;
  final Function(int)? onTrackRemoved;

  const TrackListActionView({
    super.key,
    required this.track,
    this.playlistId,
    this.albumId,
    this.onTrackRemoved,
  });

  void _openAlbum(BuildContext context, BaseTrack track) {
    Navigator.pop(context);
    GoRouter.of(context).push('/albums/${track.getAlbum().id}');
  }

  void _openTrack(BuildContext context, BaseTrack track) {
    Navigator.pop(context);
    GoRouter.of(context).push('/tracks/${track.id}');
  }

  Future<void> _addToQueue(BuildContext context, BaseTrack track) async {
    final audioManager = getIt<AudioManager>();
    await audioManager.addTrackIdToQueue(track.id, false);
    if (!context.mounted) return;
    showSnackBar(context, AppLocalizations.of(context)!.track_actions_added_to_queue);
  }

  Future<void> _addTrackToPlaylist(int trackId, BuildContext context) async {
    await AddTrackToPlaylistDialog.show(
      context, trackId,
      onPlaylistsModified: (modifiedPlaylistIds) {
        if (modifiedPlaylistIds.contains(playlistId)) {
          // If the current playlist was modified, the track must have been removed. Update the UI.
          onTrackRemoved?.call(trackId);
        }
      }
    );
  }

  void _openArtist(BuildContext context) {
    final artists = track.getArtists();
    if (artists.length == 1) {
      Navigator.pop(context);
      GoRouter.of(context).push('/artists/${artists.first.id}');
    } else {
      Navigator.pop(context);
      TrackListArtistView.showArtistPicker(context, artists);
    }
  }

  @override
  Widget build(BuildContext context) {

    final as = getIt<AuthState>();
    final lm = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: PopupMenuButton(
        useRootNavigator: true,
        icon: Icon(Icons.more_vert),
        itemBuilder: (context) => <PopupMenuEntry>[
          if (as.hasPermission(PermissionType.managePlaylists)) ... [
            PopupMenuItem(
              child: IconText(icon: Icons.add_outlined, text: lm.track_actions_add_to_playlist),
              onTap: () => _addTrackToPlaylist(track.id, context),
            )
          ],
          if (as.hasPermission(PermissionType.streamTracks)) ... [
            PopupMenuItem(
              child: IconText(icon: Icons.queue_music_outlined, text: lm.track_actions_add_to_queue),
              onTap: () => _addToQueue(context, track),
            )
          ],
          PopupMenuDivider(),
          if (as.hasPermission(PermissionType.viewTracks)) ... [
            PopupMenuItem(
              child: IconText(icon: Icons.library_music_outlined, text: lm.track_actions_goto_track),
              onTap: () => _openTrack(context, track),
            )
          ],
          if (as.hasPermission(PermissionType.viewArtists)) ... [
            PopupMenuItem(
              child: IconText(icon: Icons.person_outlined, text: lm.track_actions_goto_artist),
              onTap: () => _openArtist(context),
            )
          ],
          if(as.hasPermission(PermissionType.viewAlbums) && (albumId == null || albumId != track.getAlbum().id)) ... [
            PopupMenuItem(
              child: IconText(icon: Icons.album_outlined, text: lm.track_actions_goto_album),
              onTap: () => _openAlbum(context, track),
            ),
          ],
          if (as.hasPermission(PermissionType.downloadTracks)) ... [
            PopupMenuDivider(),
            PopupMenuItem(
              child: IconText(icon: Icons.download_outlined, text: lm.track_actions_download),
              onTap: () => TrackDownloader.downloadTrack(context, track.id),
            ),
          ],
        ]
      )
    );
  }
}