import 'package:flutter/material.dart';
import 'package:vibin_app/audio/audio_manager.dart';
import 'package:vibin_app/dtos/track/base_track.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/widgets/tracklist/track_list_artist_view.dart';

class TrackListMainWidget extends StatelessWidget {
  final BaseTrack track;
  final Function(BaseTrack track)? onTrackTapped;

  const TrackListMainWidget({
    super.key,
    required this.track,
    this.onTrackTapped,
  });

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final audioManager = getIt<AudioManager>();

    return StreamBuilder(
      stream: audioManager.currentMediaItemStream,
      builder: (context, currentMediaItem) {

        final isCurrentlyPlaying = currentMediaItem.data?.id == track.id.toString();

        return InkWell(
          onTap: onTrackTapped == null ? null : () { onTrackTapped!(track); },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.getTitle(),
                  style: theme.textTheme.bodyLarge?.copyWith(color: isCurrentlyPlaying ? theme.colorScheme.primary : theme.colorScheme.onSurface),
                  overflow: TextOverflow.ellipsis,
                ),
                TrackListArtistView(artists: track.getArtists())
              ],
            ),
          ),
        );
      }
    );
  }
}