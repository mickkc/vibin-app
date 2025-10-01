import 'package:flutter/material.dart';
import 'package:vibin_app/dtos/playlist/playlist_data.dart';
import 'package:vibin_app/dtos/playlist/playlist_track.dart';
import 'package:vibin_app/widgets/future_content.dart';
import 'package:vibin_app/widgets/icon_text.dart';
import 'package:vibin_app/widgets/network_image.dart';
import 'package:vibin_app/widgets/playlist_action_bar.dart';
import 'package:vibin_app/widgets/track_list.dart';
import 'package:vibin_app/widgets/row_small_column.dart';

import '../../api/api_manager.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';

class PlaylistInfoPage extends StatelessWidget {

  final int playlistId;

  const PlaylistInfoPage({
    super.key,
    required this.playlistId
  });

  String getTotalDurationString(List<PlaylistTrack> pts) {
    int totalSeconds = 0;
    for (var pt in pts) {
      if (pt.track.duration != null) {
        totalSeconds += (pt.track.duration! / 1000).round();
      }
    }
    final hours = (totalSeconds / 3600).floor();
    final minutes = ((totalSeconds % 3600) / 60).floor();
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return "${hours}h ${minutes}m ${seconds}s";
    } else if (minutes > 0) {
      return "${minutes}m ${seconds}s";
    } else {
      return "${seconds}s";
    }
  }

  Widget playlistInfo(BuildContext context, Future<PlaylistData> playlistDataFuture) {
    final lm = AppLocalizations.of(context)!;
    return FutureContent(
      future: playlistDataFuture,
      builder: (context, data) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Text(
                data.playlist.name,
                style: Theme.of(context).textTheme.headlineMedium,
                overflow: TextOverflow.ellipsis,
                maxLines: 1
            ),
            if (data.playlist.description.isNotEmpty) ... [
              Text(
                data.playlist.description,
                style: Theme.of(context).textTheme.bodyMedium,
              )
            ],
            IconText(icon: Icons.person, text: data.playlist.owner.displayName),
            if (data.playlist.collaborators.isNotEmpty) ... [
              IconText(icon: Icons.group, text: data.playlist.collaborators.map((e) => e.displayName).join(", ")),
            ],
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                IconText(icon: Icons.library_music, text: "${data.tracks.length} ${lm.tracks}"),
                IconText(icon: Icons.access_time, text: getTotalDurationString(data.tracks)),
                IconText(
                    icon: data.playlist.public ? Icons.public : Icons.lock,
                    text: data.playlist.public ? lm.playlists_public : lm.playlists_private
                )
              ],
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final ApiManager apiManager = getIt<ApiManager>();
    final playlistDataFuture = apiManager.service.getPlaylist(playlistId);
    final width = MediaQuery.sizeOf(context).width;

    return Column(
      spacing: 16,
      children: [
        RowSmallColumn(
          spacing: 32,
          mainAxisAlignment: MainAxisAlignment.start,
          columnChildren: [
            NetworkImageWidget(
              url: "/api/playlists/$playlistId/image?quality=original",
              width: width * 0.75,
              height: width * 0.75
            ),
            SizedBox(
                width: width,
                child: playlistInfo(context, playlistDataFuture)
            )
          ],
          rowChildren: [
            NetworkImageWidget(
              url: "/api/playlists/$playlistId/image?quality=original",
              width: 200,
              height: 200
            ),
            Expanded(
              child: playlistInfo(context, playlistDataFuture)
            )
          ],
        ),
        FutureContent(
          future: playlistDataFuture,
          builder: (context, data) {
            return PlaylistActionBar(playlistData: data);
          }
        ),
        FutureContent(
          future: playlistDataFuture,
          builder: (context, data) {
            return TrackList(tracks: data.tracks.map((e) => e.track).toList(), playlistId: playlistId);
          }
        )
      ],
    );
  }
}