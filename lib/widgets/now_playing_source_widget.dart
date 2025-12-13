import 'package:flutter/material.dart';
import 'package:vibin_app/dtos/album/album_data.dart';

import '../api/api_manager.dart';
import '../audio/audio_manager.dart';
import '../audio/audio_type.dart';
import '../dtos/artist/artist.dart';
import '../dtos/playlist/playlist_data.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import 'future_content.dart';
import 'network_image.dart';

class NowPlayingSourceWidget extends StatefulWidget {

  const NowPlayingSourceWidget({super.key});

  @override
  State<NowPlayingSourceWidget> createState() => _NowPlayingSourceWidgetState();
}

class _NowPlayingSourceWidgetState extends State<NowPlayingSourceWidget> {

  final audioManager = getIt<AudioManager>();
  final apiManager = getIt<ApiManager>();

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final lm = AppLocalizations.of(context)!;

    return StreamBuilder(
      stream: audioManager.currentAudioTypeStream,
      initialData: audioManager.currentAudioType,
      builder: (context, asyncSnapshot) {

        final audioType = asyncSnapshot.data?.audioType ?? AudioType.unspecified;

        final Future<dynamic>? sourceObj = switch(audioType) {
          AudioType.playlist => apiManager.service.getPlaylist(asyncSnapshot.data!.id!),
          AudioType.album => apiManager.service.getAlbum(asyncSnapshot.data!.id!),
          AudioType.artist => apiManager.service.getArtist(asyncSnapshot.data!.id!),
          _ => null
        };

        if (sourceObj == null) return SizedBox.shrink();

        return FutureContent(
          future: sourceObj,
          builder: (context, source) {
            return Row(
              spacing: 16.0,
              children: [
                NetworkImageWidget(
                  url: switch(audioType) {
                    AudioType.playlist => "/api/playlists/${(source as PlaylistData).playlist.id}/image?quality=64",
                    AudioType.album => "/api/albums/${(source as AlbumData).album.id}/cover?quality=64",
                    AudioType.artist => "/api/artists/${(source as Artist)}/image?quality=64",
                    _ => ""
                  },
                  borderRadius: BorderRadius.circular(4),
                  width: 44,
                  height: 44,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      switch(audioType) {
                        AudioType.playlist => (source as PlaylistData).playlist.name,
                        AudioType.album => (source as AlbumData).album.title,
                        AudioType.artist => (source as Artist).name,
                        _ => ""
                      },
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                    Text(
                      switch(audioType) {
                        AudioType.playlist => lm.playlist,
                        AudioType.album => lm.album,
                        AudioType.artist => lm.artist,
                        _ => ""
                      },
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                    )
                  ],
                )
              ],
            );
          }
        );
      }
    );
  }
}