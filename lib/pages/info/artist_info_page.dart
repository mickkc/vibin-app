import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/audio/audio_manager.dart';
import 'package:vibin_app/dtos/album/album.dart';
import 'package:vibin_app/dtos/artist/artist.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/dtos/track/minimal_track.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/pages/column_page.dart';
import 'package:vibin_app/sections/section_header.dart';
import 'package:vibin_app/widgets/future_content.dart';
import 'package:vibin_app/widgets/network_image.dart';
import 'package:vibin_app/widgets/tracklist/track_list.dart';

import '../../auth/auth_state.dart';

class ArtistInfoPage extends StatelessWidget {
  final int artistId;

  ArtistInfoPage({
    super.key,
    required this.artistId
  });

  final _apiManager = getIt<ApiManager>();
  final _audioManager = getIt<AudioManager>();
  final _authState = getIt<AuthState>();

  late final _artistFuture = _apiManager.service.getArtist(artistId);
  late final _discographyFuture = _authState.hasPermission(PermissionType.viewAlbums)
      ? _apiManager.service.getArtistDiscography(artistId).then(
          (discography) {
            discography.sort((a, b) => (b.key.year ?? 9999).compareTo(a.key.year ?? 9999));
            return discography;
          })
      : null;
  late final _tracksFuture = !_authState.hasPermission(PermissionType.viewAlbums) && _authState.hasPermission(PermissionType.viewTracks)
      ? _apiManager.service.getTracksByArtist(artistId)
      : null;

  Widget _albumTitle(BuildContext context, Album album) {
    return Row(
      spacing: 16,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        NetworkImageWidget(
          url: "/api/albums/${album.id}/cover?quality=small",
          width: 64,
          height: 64,
          borderRadius: BorderRadius.circular(4),
        ),
        Expanded(
          child: Column(
            spacing: 4,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                album.title,
                style: Theme.of(context).textTheme.headlineMedium,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              if (album.year != null)
                Text(
                  album.year.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                )
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            GoRouter.of(context).push("/albums/${album.id}");
          },
          icon: Icon(Icons.open_in_new)
        )
      ],
    );
  }

  Widget _albumTrackList(BuildContext context, List<MinimalTrack> tracks) {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        for (var track in tracks)
          ListTile(
            leading: NetworkImageWidget(
              url: "/api/tracks/${track.id}/cover?quality=small",
              width: 48,
              height: 48,
              borderRadius: BorderRadius.circular(4),
            ),
            title: Text(
              track.title,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            subtitle: Text(
              track.artists.map((a) => a.name).join(", "),
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            trailing: IconButton(
              onPressed: () {
                GoRouter.of(context).push("/tracks/${track.id}");
              },
              icon: Icon(Icons.open_in_new)
            ),
            onTap: () {
              _audioManager.playMinimalTrackWithQueue(track, tracks);
              _apiManager.service.reportArtistListen(artistId);
            },
          )
      ],
    );
  }

  Widget _artistInfo(BuildContext context, Artist artist) {
    return Column(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          artist.name,
          style: Theme.of(context).textTheme.headlineMedium,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        if (artist.description.isNotEmpty)
          Text(
            artist.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (_authState.hasPermission(PermissionType.manageArtists))
              ElevatedButton.icon(
                onPressed: () => GoRouter.of(context).push("/artists/${artist.id}/edit"),
                label: Text(AppLocalizations.of(context)!.artists_edit),
                icon: Icon(Icons.edit),
              )
          ]
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final lm = AppLocalizations.of(context)!;

    return ColumnPage(
      children: [
        FutureContent(
          future: _artistFuture,
          builder: (context, artist) {
            return Row(
              spacing: 32,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                NetworkImageWidget(
                  url: "/api/artists/$artistId/image?quality=medium",
                  width: width > 600 ? 200 : width / 4,
                  height: width > 600 ? 200 : width / 4,
                  borderRadius: BorderRadius.circular(width * 0.375),
                ),
                Expanded(
                  child: _artistInfo(context, artist)
                )
              ],
            );
          }
        ),

        if (_discographyFuture != null) ... [
          Divider(),
          SectionHeader(title: lm.artists_discography),
          FutureContent(
            future: _discographyFuture,
            hasData: (d) => d.isNotEmpty,
            builder: (context, discography) {
              return Column(
                spacing: 16,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var entry in discography) ... [
                    Column(
                      spacing: 8,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _albumTitle(context, entry.key),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: _albumTrackList(context, entry.value),
                        )
                      ],
                    )
                  ]
                ],
              );
            }
          )
        ]
        else if (_tracksFuture != null) ... [
          Divider(),
          SectionHeader(title: lm.tracks),
          FutureContent(
            future: _tracksFuture,
            hasData: (d) => d.isNotEmpty,
            builder: (context, tracks) {
              return TrackList(tracks: tracks);
            }
          )
        ]
      ],
    );
  }
}