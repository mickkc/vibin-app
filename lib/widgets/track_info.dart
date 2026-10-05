import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/mock/mock_tracks.dart';
import 'package:vibin_app/settings/enums/track_info_field.dart';
import 'package:vibin_app/settings/setting_definitions.dart';
import 'package:vibin_app/settings/settings_manager.dart';
import 'package:vibin_app/widgets/tag_widget.dart';
import 'package:vibin_app/widgets/track_listen_duration.dart';

import '../api/api_manager.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import 'future_content.dart';
import 'icon_text.dart';

class TrackInfoView extends StatelessWidget {
  final int trackId;
  final bool showMetadata;
  final VoidCallback? onNavigate;

  TrackInfoView({
    super.key,
    required this.trackId,
    this.showMetadata = true,
    this.onNavigate,
  });

  void _openArtistPage(BuildContext context, int artistId) {
    GoRouter.of(context).push("/artists/$artistId");
    onNavigate?.call();
  }

  void _openAlbumPage(BuildContext context, int albumId) {
    GoRouter.of(context).push('/albums/$albumId');
    onNavigate?.call();
  }

  final _apiManager = getIt<ApiManager>();

  late final _trackFuture = _apiManager.service.getTrack(trackId);

  final _settingsManager = getIt<SettingsManager>();
  late final _infoFields = showMetadata ? _settingsManager.getFilledMap(Settings.trackInfoFields, true.toString()) : null;

  @override
  Widget build(BuildContext context) {
    final lm = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return FutureContent(
      future: _trackFuture,
      mockData: () { return getMockedTrack(); },
      builder: (context, track) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Text(
              track.title,
              style: Theme.of(context).textTheme.headlineMedium,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
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
                    onTap: () => _openArtistPage(context, artist.id),
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
                  onTap: () => _openAlbumPage(context, track.album.id),
                  child: Text(track.album.title, style: TextStyle(color: theme.colorScheme.primary))
                ),
              ],
            ),
            if (track.comment != null && track.comment!.isNotEmpty && showMetadata && _settingsManager.get(Settings.showTrackComment)) ... [
              IconText(icon: Icons.comment, text: track.comment!)
            ],
            if (showMetadata) ... [
              if (_infoFields != null && _infoFields.any((i) => i.value == true.toString()))
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  runAlignment: WrapAlignment.center,
                  alignment: WrapAlignment.start,
                  children: _infoFields.map<Widget?>((field) {
                    if (field.value != true.toString()) return null;
                    switch(field.key) {
                      case TrackInfoField.duration when track.duration != null:
                        return IconText(icon: Icons.schedule, text: formatDurationMs(track.duration!));
                      case TrackInfoField.listeningDuration:
                        return TrackListenDuration(trackId);
                      case TrackInfoField.year when track.year != null:
                        return IconText(icon: Icons.date_range, text: track.year!.toString());
                      case TrackInfoField.trackCountNumber when track.trackNumber != null || track.trackCount != null:
                        return IconText(icon: Icons.music_note, text: "${track.trackNumber ?? "?"}/${track.trackCount ?? "?"}");
                      case TrackInfoField.discCountNumber when track.discNumber != null || track.discCount != null:
                        return IconText(icon: Icons.album, text: "${track.discNumber ?? "?"}/${track.discCount ?? "?"}");
                      case TrackInfoField.bitrate when track.bitrate != null:
                        return IconText(icon: Icons.multitrack_audio, text: "${track.bitrate!} kbps");
                      case TrackInfoField.explicit when track.explicit:
                        IconText(icon: Icons.explicit, text: lm.edit_track_explicit);
                      case TrackInfoField.hasLyrics when track.hasLyrics:
                        IconText(icon: Icons.lyrics, text: lm.edit_track_lyrics);
                      default:
                        return null;
                    }
                    return null;
                  }).nonNulls.toList()
                ),

              if (track.tags.isNotEmpty && _settingsManager.get(Settings.showTrackTags))
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  runAlignment: WrapAlignment.center,
                  alignment: WrapAlignment.start,
                  children: [
                    for (var tag in track.tags)
                      TagWidget(tag: tag, onNavigate: onNavigate)
                  ],
                )
            ]
          ],
        );
      }
    );
  }
}