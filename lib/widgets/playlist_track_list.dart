import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/dtos/track/track.dart';
import 'package:vibin_app/widgets/icon_text.dart';
import 'package:vibin_app/widgets/network_image.dart';

import '../extensions.dart';
import '../l10n/app_localizations.dart';

class TrackList extends StatefulWidget {
  final List<Track> tracks;

  const TrackList({
    super.key,
    required this.tracks
  });

  @override
  State<TrackList> createState() => _TrackListState();
}

class _TrackListState extends State<TrackList> {

  void showArtistPicker(BuildContext context, Track track) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          constraints: BoxConstraints(
            maxWidth: 400,
          ),
          child: Padding(
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

  @override
  Widget build(BuildContext context) {

    final lm = AppLocalizations.of(context)!;
    final isMobile = MediaQuery.sizeOf(context).width < 600;

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
                    style: Theme.of(context).textTheme.bodyLarge,
                    overflow: TextOverflow.ellipsis),
                  InkWell(
                    onTap: () {
                      showArtistPicker(context, track);
                    },
                    child: Text(
                      track.artists.map((e) => e.name).join(", "),
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
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
                    : Text(formatDurationMs(track.duration!), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: PopupMenuButton(
                icon: Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: IconText(icon: Icons.add_outlined, text: lm.track_actions_add_to_playlist),
                  ),
                  PopupMenuItem(
                    child: IconText(icon: Icons.queue_music_outlined, text: lm.track_actions_add_to_queue),
                  ),
                  PopupMenuItem(
                    child: IconText(icon: Icons.library_music_outlined, text: lm.track_actions_view_track),
                    onTap: () { openTrack(context, track); },
                  ),
                  PopupMenuItem(
                    child: IconText(icon: Icons.person_outlined, text: lm.track_actions_view_artist),
                    onTap: () { showArtistPicker(context, track); },
                  ),
                  PopupMenuItem(
                    child: IconText(icon: Icons.album_outlined, text: lm.track_actions_view_album),
                    onTap: () { openAlbum(context, track); },
                  ),
                  PopupMenuItem(
                    child: IconText(icon: Icons.download_outlined, text: lm.track_actions_download),
                  ),
                ]
              )
            )
          ]
        );
      }).toList()
    );
  }
}