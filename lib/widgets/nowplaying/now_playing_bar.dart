import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vibin_app/audio/audio_manager.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/main_layout.dart';
import 'package:vibin_app/pages/now_playing_page.dart';
import 'package:vibin_app/widgets/nowplaying/audio_progress_slider.dart';
import 'package:vibin_app/widgets/nowplaying/controls/play_pause_toggle.dart';
import 'package:vibin_app/widgets/nowplaying/controls/repeat_toggle.dart';
import 'package:vibin_app/widgets/nowplaying/controls/shuffle_toggle.dart';

import '../../l10n/app_localizations.dart';

class NowPlayingBar extends StatefulWidget {
  const NowPlayingBar({super.key});

  @override
  State<NowPlayingBar> createState() => _NowPlayingBarState();
}

class _NowPlayingBarState extends State<NowPlayingBar> {

  final AudioManager audioManager = getIt<AudioManager>();
  late final theme = Theme.of(context);
  late final lm = AppLocalizations.of(context)!;

  late var currentMediaItem = audioManager.getCurrentMediaItem();

  late StreamSubscription currentMediaItemSubscription;

  @override
  void initState() {
    currentMediaItemSubscription = audioManager.audioPlayer.sequenceStateStream.listen((mediaItem) {
      final mediaItem = audioManager.getCurrentMediaItem();
      if (mediaItem?.id == currentMediaItem?.id) {
        return;
      }
      setState(() {
        currentMediaItem = mediaItem;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    currentMediaItemSubscription.cancel();
    super.dispose();
  }

  void skipNext() {
    audioManager.audioPlayer.seekToNext();
  }

  void skipPrevious() {
    audioManager.audioPlayer.seekToPrevious();
  }

  void seek(double milliseconds) {
    audioManager.audioPlayer.seek(Duration(milliseconds: milliseconds.toInt()));
  }

  double get width => MediaQuery.sizeOf(context).width;

  @override
  Widget build(BuildContext context) {
    final showExtendedControls = MediaQuery.sizeOf(context).width > 600;
    return currentMediaItem == null ? const SizedBox.shrink() : GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! < 0) {
          skipNext();
        } else if (details.primaryVelocity! > 0) {
          skipPrevious();
        }
      },
      onTap: () {
        NowPlayingPage.show(context);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AudioProgressSlider(
            sliderThemeData: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: theme.colorScheme.primary,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 4),
              padding: EdgeInsets.all(8.0)
            ),
            showTimes: false,
          ),
          Container(
            height: 60,
            color: theme.colorScheme.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                if (currentMediaItem?.artUri != null) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                    child: Image.network(
                      currentMediaItem!.artUri.toString(),
                      headers: currentMediaItem?.artHeaders ?? {},
                      width: 44,
                      height: 44
                    ),
                  )
                ],
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          currentMediaItem!.title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: theme.textTheme.bodyLarge
                      ),
                      Text(
                          currentMediaItem!.artist ?? "",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: theme.textTheme.bodyMedium,
                      ),
                  ]),
                ),
                Row(
                  children: [
                    if (width > 900) ... [
                      ValueListenableBuilder(
                        valueListenable: sidebarNotifier,
                        builder: (context, value, child) {
                          return Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  sidebarNotifier.value = value == SidebarType.queue ? SidebarType.none : SidebarType.queue;
                                },
                                icon: Icon(
                                  Icons.queue_music_outlined,
                                  color: value == SidebarType.queue
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface
                                ),
                                tooltip: lm.now_playing_queue,
                              ),
                              IconButton(
                                onPressed: () {
                                  sidebarNotifier.value = value == SidebarType.lyrics ? SidebarType.none : SidebarType.lyrics;
                                },
                                icon: Icon(
                                  Icons.lyrics_outlined,
                                  color: value == SidebarType.lyrics
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface
                                ),
                                tooltip: lm.now_playing_lyrics,
                              ),
                            ],
                          );
                        }
                      ),
                      const SizedBox(width: 16)
                    ],
                    if (showExtendedControls) ... [
                      const RepeatToggle(),
                      const ShuffleToggle(),
                      const SizedBox(width: 16)
                    ],
                    IconButton(
                      onPressed: skipPrevious,
                      icon: const Icon(Icons.skip_previous),
                      tooltip: lm.now_playing_previous
                    ),
                    const PlayPauseToggle(),
                    IconButton(
                      onPressed: skipNext,
                      icon: const Icon(Icons.skip_next),
                      tooltip: lm.now_playing_next
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}