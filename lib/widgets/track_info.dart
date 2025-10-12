import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/widgets/tag_widget.dart';

import '../api/api_manager.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import 'future_content.dart';
import 'icon_text.dart';

class TrackInfoView extends StatelessWidget {
  final int trackId;
  final bool showMetadata;

  const TrackInfoView({
    super.key,
    required this.trackId,
    this.showMetadata = true
  });

  void openArtistPage(BuildContext context, int artistId) {
    GoRouter.of(context).push("/artists/$artistId");
  }

  void openAlbumPage(BuildContext context, int albumId) {
    GoRouter.of(context).push('/albums/$albumId');
  }

  @override
  Widget build(BuildContext context) {
    final apiManager = getIt<ApiManager>();
    final trackFuture = apiManager.service.getTrack(trackId);

    final lm = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return FutureContent(
      future: trackFuture,
      builder: (context, track) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Text(
              track.title,
              style: Theme.of(context).textTheme.headlineMedium,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            Wrap(
              runAlignment: WrapAlignment.center,
              alignment: WrapAlignment.start,
              runSpacing: 8,
              spacing: 8,
              children: [
                Icon(Icons.person),
                for (var artist in track.artists) ...[
                  InkWell(
                    onTap: () => openArtistPage(context, artist.id),
                    child: Text(artist.name, style: TextStyle(color: theme.colorScheme.primary)),
                  ),
                  if (artist != track.artists.last)
                    const Text("•")
                ]
              ]
            ),
            Row(
              spacing: 8,
              children: [
                Icon(Icons.album),
                InkWell(
                  onTap: () => openAlbumPage(context, track.album.id),
                  child: Text(track.album.title, style: TextStyle(color: theme.colorScheme.primary))
                ),
              ],
            ),
            if (track.comment != null && track.comment!.isNotEmpty && showMetadata) ... [
              IconText(icon: Icons.comment, text: track.comment!)
            ],
            if (showMetadata) ... [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                runAlignment: WrapAlignment.center,
                alignment: WrapAlignment.start,
                children: [
                  if (track.duration != null)
                    IconText(icon: Icons.schedule, text: "${(track.duration! / 1000 / 60).floor()}:${((track.duration! / 1000) % 60).round().toString().padLeft(2, '0')}"),

                  if (track.year != null)
                    IconText(icon: Icons.date_range, text: track.year!.toString()),

                  if (track.trackCount != null || track.trackNumber != null)
                    IconText(icon: Icons.music_note, text: "${track.trackNumber ?? "?"}/${track.trackCount ?? "?"}"),

                  if (track.discCount != null || track.discNumber != null)
                    IconText(icon: Icons.album, text: "${track.discNumber ?? "?"}/${track.discCount ?? "?"}"),

                  if (track.bitrate != null)
                    IconText(icon: Icons.multitrack_audio, text: "${track.bitrate!} kbps"),

                  if (track.explicit)
                    IconText(icon: Icons.explicit, text: lm.edit_track_explicit),

                  if (track.hasLyrics)
                    IconText(icon: Icons.lyrics, text: lm.edit_track_lyrics),

                  for (var tag in track.tags) ...[
                    TagWidget(tag: tag)
                  ]
                ],
              )
            ]
          ],
        );
      }
    );
  }
}