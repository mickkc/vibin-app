import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/audio/audio_manager.dart';
import 'package:vibin_app/auth/AuthState.dart';
import 'package:vibin_app/dialogs/add_track_to_playlist_dialog.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/dtos/track/track.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/widgets/icon_text.dart';
import 'package:vibin_app/widgets/network_image.dart';

import '../extensions.dart';
import '../l10n/app_localizations.dart';

class TrackList extends StatefulWidget {
  final List<Track> tracks;
  final int? playlistId;
  final int? albumId;

  const TrackList({
    super.key,
    required this.tracks,
    this.playlistId,
    this.albumId
  });

  @override
  State<TrackList> createState() => _TrackListState();
}

class _TrackListState extends State<TrackList> {

  late final AudioManager audioManager = getIt<AudioManager>();

  late String? currentlyPlayingTrackId = audioManager.getCurrentMediaItem()?.id;

  late final StreamSubscription sequenceSubscription;

  _TrackListState() {
    sequenceSubscription = audioManager.audioPlayer.sequenceStateStream.listen((event) {
      if (!mounted) return;
      setState(() {
        currentlyPlayingTrackId = audioManager.getCurrentMediaItem()?.id;
      });
    });
  }

  @override
  void dispose() {
    sequenceSubscription.cancel();
    super.dispose();
  }

  void showArtistPicker(BuildContext context, Track track) {
    showModalBottomSheet(
      showDragHandle: true,
      isScrollControlled: false,
      enableDrag: true,
      useRootNavigator: true,
      context: context,
      constraints: BoxConstraints(
        maxWidth: 400,
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: track.artists.length,
            physics: const AlwaysScrollableScrollPhysics(),
            primary: false,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final artist = track.artists[index];
              return ListTile(
                leading: NetworkImageWidget(
                  url: "/api/artists/${artist.id}/image?quality=small",
                  width: 40,
                  height: 40,
                  borderRadius: BorderRadius.circular(20),
                  fit: BoxFit.cover,
                ),
                title: Text(artist.name),
                onTap: () {
                  Navigator.pop(context);
                  GoRouter.of(context).push('/artists/${artist.id}');
                },
              );
            },
          ),
        );
      }
    );
  }

  void openAlbum(BuildContext context, Track track) {
    Navigator.pop(context);
    GoRouter.of(context).push('/albums/${track.album.id}');
  }

  void openTrack(BuildContext context, Track track) {
    Navigator.pop(context);
    GoRouter.of(context).push('/tracks/${track.id}');
  }

  void openArtist(BuildContext context, Track track) {
    if (track.artists.length == 1) {
      Navigator.pop(context);
      GoRouter.of(context).push('/artists/${track.artists.first.id}');
    } else {
      showArtistPicker(context, track);
    }
  }

  Future<void> addToQueue(Track track) async {
    final audioManager = getIt<AudioManager>();
    await audioManager.addTrackToQueue(track.id);
    if (!mounted || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.track_actions_added_to_queue))
    );
  }

  Future<void> addTrackToPlaylist(int trackId, BuildContext context) async {
    final modifiedPlaylistIds = await AddTrackToPlaylistDialog.show(trackId, context);
    if (widget.playlistId != null && modifiedPlaylistIds.contains(widget.playlistId)) {
      // If the current playlist was modified, the track must have been removed. Update the UI.
      setState(() {
        widget.tracks.removeWhere((t) => t.id == trackId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    final lm = AppLocalizations.of(context)!;
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final as = getIt<AuthState>();
    final theme = Theme.of(context);

    return Table(
      border: TableBorder(horizontalInside: BorderSide(color: Theme.of(context).colorScheme.surfaceContainerHighest)),
      columnWidths: <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(2),
        if (!isMobile) ... {
          2: FlexColumnWidth(1),
          3: IntrinsicColumnWidth(),
          4: IntrinsicColumnWidth()
        }
        else ... {
          2: IntrinsicColumnWidth()
        }
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: widget.tracks.map((track) {
        final isCurrentTrack = currentlyPlayingTrackId == track.id.toString();
        return TableRow(
          children: [
            NetworkImageWidget(
              url: "/api/tracks/${track.id}/cover?quality=small",
              width: 48,
              height: 48
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: theme.textTheme.bodyLarge?.copyWith(color: isCurrentTrack ? theme.colorScheme.primary : theme.colorScheme.onSurface),
                    overflow: TextOverflow.ellipsis,
                  ),
                  InkWell(
                    onTap: () {
                      openArtist(context, track);
                    },
                    child: Text(
                      track.artists.map((e) => e.name).join(", "),
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            ),
            if (!isMobile) ... [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    GoRouter.of(context).push('/albums/${track.album.id}');
                  },
                  child: Text(track.album.title),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: track.duration == null
                    ? SizedBox.shrink()
                    : Text(formatDurationMs(track.duration!), style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: PopupMenuButton(
                useRootNavigator: true,
                icon: Icon(Icons.more_vert),
                itemBuilder: (context) => <PopupMenuEntry>[
                  if (as.hasPermission(PermissionType.managePlaylists)) ... [
                    PopupMenuItem(
                      child: IconText(icon: Icons.add_outlined, text: lm.track_actions_add_to_playlist),
                      onTap: () { addTrackToPlaylist(track.id, context); },
                    )
                  ],
                  if (as.hasPermission(PermissionType.streamTracks)) ... [
                    PopupMenuItem(
                      child: IconText(icon: Icons.queue_music_outlined, text: lm.track_actions_add_to_queue),
                      onTap: () { addToQueue(track); },
                    )
                  ],
                  PopupMenuDivider(),
                  if (as.hasPermission(PermissionType.viewTracks)) ... [
                    PopupMenuItem(
                      child: IconText(icon: Icons.library_music_outlined, text: lm.track_actions_goto_track),
                      onTap: () { openTrack(context, track); },
                    )
                  ],
                  if (as.hasPermission(PermissionType.viewArtists)) ... [
                    PopupMenuItem(
                      child: IconText(icon: Icons.person_outlined, text: lm.track_actions_goto_artist),
                      onTap: () { openArtist(context, track); },
                    )
                  ],
                  if(as.hasPermission(PermissionType.viewAlbums) && (widget.albumId == null || widget.albumId != track.album.id)) ... [
                    PopupMenuItem(
                      child: IconText(icon: Icons.album_outlined, text: lm.track_actions_goto_album),
                      onTap: () { openAlbum(context, track); },
                    ),
                  ],
                  if (as.hasPermission(PermissionType.downloadTracks)) ... [
                    PopupMenuDivider(),
                    PopupMenuItem(
                      child: IconText(icon: Icons.download_outlined, text: lm.track_actions_download),
                    ),
                  ],
                ]
              )
            )
          ]
        );
      }).toList()
    );
  }
}