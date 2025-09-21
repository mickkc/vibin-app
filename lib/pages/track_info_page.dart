import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/sections/explore_section.dart';
import 'package:vibin_app/sections/section_header.dart';
import 'package:vibin_app/widgets/future_content.dart';
import 'package:vibin_app/widgets/icon_text.dart';
import 'package:vibin_app/widgets/network_image.dart';
import 'package:vibin_app/widgets/permission_widget.dart';
import 'package:vibin_app/widgets/tag_widget.dart';

class TrackInfoPage extends StatelessWidget {

  final int trackId;

  const TrackInfoPage({
    super.key,
    required this.trackId
  });

  void openArtistPage(BuildContext context, int artistId) {
    // TODO: Implement navigation to artist page
  }

  void openAlbumPage(BuildContext context, int albumId) {
    // TODO: Implement navigation to album page
  }

  @override
  Widget build(BuildContext context) {
    final apiManager = getIt<ApiManager>();
    final trackFuture = apiManager.service.getTrack(trackId);
    final imageFuture = apiManager.service.getTrackCover(trackId, "original");

    return Column(
      spacing: 16,
      children: [
        Row(
          spacing: 32,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            NetworkImageWidget(
              imageFuture: imageFuture,
              width: 200,
              height: 200,
            ),
            FutureContent(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 8,
                        children: [
                          Icon(Icons.person),
                          for (var artist in track.artists) ...[
                            InkWell(
                                onTap: () => openArtistPage(context, artist.id),
                                child: Text(artist.name, style: TextStyle(color: Theme.of(context).colorScheme.primary)),

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
                              child: Text(track.album.title, style: TextStyle(color: Theme.of(context).colorScheme.primary))
                          ),
                        ],
                      ),
                      if (track.comment != null) ... [
                        IconText(icon: Icons.comment, text: track.comment!)
                      ],
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        runAlignment: WrapAlignment.center,
                        alignment: WrapAlignment.start,
                        children: [
                          if (track.duration != null) ... [
                            IconText(icon: Icons.schedule, text: "${(track.duration! / 1000 / 60).floor()}:${((track.duration! / 1000) % 60).round().toString().padLeft(2, '0')}")
                          ],
                          if (track.year != null) ... [
                            IconText(icon: Icons.date_range, text: track.year!.toString())
                          ],
                          if (track.trackCount != null || track.trackNumber != null) ... [
                            IconText(icon: Icons.music_note, text: "${track.trackNumber ?? "?"}/${track.trackCount ?? "?"}"),
                          ],
                          if (track.discCount != null || track.discNumber != null) ... [
                            IconText(icon: Icons.album, text: "${track.discNumber ?? "?"}/${track.discCount ?? "?"}"),
                          ],
                          if (track.bitrate != null) ... [
                            IconText(icon: Icons.multitrack_audio, text: "${track.bitrate!} kbps")
                          ],
                          for (var tag in track.tags) ...[
                            TagWidget(tag: tag)
                          ]
                        ],
                      )
                    ],
                  );
                }
            )
          ],
        ),
        Row(
          spacing: 16,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Container(
                color: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.play_arrow,
                  size: 48,
                  color: Theme.of(context).colorScheme.surface,
                )
              ),
            ),
            IconButton(
                onPressed: () {},
                icon: const Icon(Icons.playlist_add, size: 32)
            ),
            IconButton(
                onPressed: () {},
                icon: const Icon(CupertinoIcons.heart, size: 32)
            ),
            IconButton(
                onPressed: () {},
                icon: const Icon(Icons.download, size: 32)
            ),
            PermissionWidget(
                requiredPermissions: [PermissionType.manageTracks],
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, size: 32),
                )
            )
          ],
        ),
        Column(
          children: [
            ExploreSection()
          ],
        )
      ],
    );
  }
}