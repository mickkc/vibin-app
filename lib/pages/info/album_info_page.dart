import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/dtos/album/album_data.dart';
import 'package:vibin_app/dtos/shuffle_state.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/widgets/bars/album_action_bar.dart';
import 'package:vibin_app/widgets/future_content.dart';
import 'package:vibin_app/widgets/icon_text.dart';
import 'package:vibin_app/widgets/network_image.dart';
import 'package:vibin_app/widgets/row_small_column.dart';
import 'package:vibin_app/widgets/track_list.dart';

import '../../audio/audio_manager.dart';
import '../../l10n/app_localizations.dart';

class AlbumInfoPage extends StatelessWidget {
  final int albumId;

  const AlbumInfoPage({
    super.key,
    required this.albumId
  });

  Widget albumInfo(BuildContext context, AlbumData data) {
    final theme = Theme.of(context);
    final lm = AppLocalizations.of(context)!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          data.album.title,
          style: theme.textTheme.headlineMedium,
          overflow: TextOverflow.ellipsis,
          maxLines: 1
        ),
        if (data.album.description.isNotEmpty)
          Text(
            data.album.description,
            style: theme.textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
            maxLines: 3
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Icon(Icons.person),
            for (var artist in data.album.artists) ...[
              InkWell(
                onTap: () {
                  GoRouter.of(context).push("/artists/${artist.id}");
                },
                child: Text(artist.name, style: TextStyle(color: theme.colorScheme.primary)),
              ),
              if (artist != data.album.artists.last)
                const Text("•")
            ]
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            IconText(icon: Icons.library_music, text: "${data.album.trackCount} ${data.album.trackCount == 1 ? lm.track : lm.tracks}"),
            IconText(icon: Icons.access_time, text: getTotalDurationString(data.tracks)),
            if (data.album.year != null)
              IconText(icon: Icons.date_range, text: data.album.year.toString()),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final apiManager = getIt<ApiManager>();
    final audioManager = getIt<AudioManager>();
    final albumFuture = apiManager.service.getAlbum(albumId);
    final shuffleState = ShuffleState(isShuffling: false);

    return Column(
      spacing: 16,
      children: [
        FutureContent(
          future: albumFuture,
          builder: (context, data) {
            return RowSmallColumn(
              spacing: 32,
              rowChildren: [
                NetworkImageWidget(
                  url: "/api/albums/$albumId/cover?quality=original",
                  width: 200,
                  height: 200
                ),
                Expanded(child: albumInfo(context, data))
              ],
              columnChildren: [
                NetworkImageWidget(
                  url: "/api/albums/$albumId/cover?quality=original",
                  width: width * 0.75,
                  height: width * 0.75
                ),
                SizedBox(
                  width: width,
                  child: albumInfo(context, data)
                )
              ]
            );
          },
        ),
        AlbumActionBar(
          albumId: albumId,
          shuffleState: shuffleState
        ),
        FutureContent(
          future: albumFuture,
          builder: (context, data) {
            return TrackList(
              tracks: data.tracks,
              albumId: data.album.id,
              onTrackTapped: (track) {
                audioManager.playAlbumData(data, track.id, shuffleState.isShuffling);
              }
            );
          }
        )
      ],
    );
  }
}