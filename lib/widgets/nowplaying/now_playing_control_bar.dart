import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/audio/audio_manager.dart';
import 'package:vibin_app/dialogs/lyrics_dialog.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/widgets/colored_icon_button.dart';
import 'package:vibin_app/widgets/nowplaying/audio_progress_slider.dart';
import 'package:vibin_app/widgets/nowplaying/controls/play_pause_toggle.dart';
import 'package:vibin_app/widgets/nowplaying/controls/repeat_toggle.dart';
import 'package:vibin_app/widgets/nowplaying/controls/shuffle_toggle.dart';
import 'package:vibin_app/widgets/nowplaying/now_playing_queue.dart';

import '../../l10n/app_localizations.dart';
import 'controls/speed_slider.dart';
import 'controls/volume_slider.dart';

class NowPlayingControlBar extends StatefulWidget {
  final MediaItem mediaItem;
  const NowPlayingControlBar({
    super.key,
    required this.mediaItem,
  });

  @override
  State<NowPlayingControlBar> createState() => _NowPlayingControlBarState();
}

class _NowPlayingControlBarState extends State<NowPlayingControlBar> {

  final AudioManager audioManager = getIt<AudioManager>();
  final ApiManager apiManager = getIt<ApiManager>();

  void toggleShuffle() {
    audioManager.audioPlayer.setShuffleModeEnabled(!audioManager.audioPlayer.shuffleModeEnabled);
  }

  void playPause() {
    if (audioManager.audioPlayer.playing) {
      audioManager.audioPlayer.pause();
    } else {
      audioManager.audioPlayer.play();
    }
  }

  void showMobileDialog() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const VolumeSlider(),
              const SpeedSlider()
            ],
          ),
        );
      }
    );
  }

  void showQueue() {
    NowPlayingQueue.show(context);
  }

  Widget lyricsButton() {

    Widget buttonBase(VoidCallback? onPressed) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(Icons.lyrics),
        label: Text(AppLocalizations.of(context)!.now_playing_lyrics)
      );
    }

    final id = int.tryParse(widget.mediaItem.id);
    if (id == null) return SizedBox.shrink();
    final lyricsFuture = apiManager.service.checkTrackHasLyrics(id);
    return FutureBuilder(
      future: lyricsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.hasError || snapshot.data == null || !snapshot.data!.success) {
          return buttonBase(null);
        }
        return buttonBase(() {
          LyricsDialog.show(context);
        }
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;
    final lm = AppLocalizations.of(context)!;

    return Column(
      spacing: 8,
      children: [
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: const RepeatToggle(showTooltip: false)
            ),
            ColoredIconButton(
                icon: Icons.skip_previous,
                backgroundColor: th.colorScheme.secondary,
                iconColor: th.colorScheme.onSecondary,
                onPressed: audioManager.audioPlayer.seekToPrevious
            ),
            PlayPauseToggle(
              backgroundColor: th.colorScheme.primary,
              iconColor: th.colorScheme.onPrimary,
              size: 32,
              showTooltip: false,
            ),
            ColoredIconButton(
              icon: Icons.skip_next,
              backgroundColor: th.colorScheme.secondary,
              iconColor: th.colorScheme.onSecondary,
              onPressed: audioManager.audioPlayer.seekToNext
            ),
            Expanded(
              child: const ShuffleToggle(showTooltip: false)
            )
          ],
        ),
        const AudioProgressSlider(),

        if (isMobile) ... [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: showMobileDialog,
                  label: Text(lm.now_plying_advanced_controls),
                  icon: Icon(Icons.settings)
                ),
                lyricsButton(),
                ElevatedButton.icon(
                  onPressed: showQueue,
                  label: Text(lm.now_playing_queue),
                  icon: Icon(Icons.queue_music)
                ),
              ],
            )
          )
        ]
        else ... [
          Row(
            spacing: 16,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: const VolumeSlider()
              ),
              lyricsButton(),
              ElevatedButton.icon(
                onPressed: showQueue,
                label: Text(lm.now_playing_queue),
                icon: Icon(Icons.queue_music)
              ),
              Expanded(
                child: const SpeedSlider()
              )
            ],
          )
        ]
      ],
    );
  }
}
