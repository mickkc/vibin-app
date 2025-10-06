import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibin_app/audio/audio_manager.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/main_layout.dart';
import 'package:vibin_app/pages/now_playing_page.dart';

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

  late var isPlaying = audioManager.audioPlayer.playing;
  late var position = audioManager.audioPlayer.position;
  late var shuffleEnabled = audioManager.audioPlayer.shuffleModeEnabled;
  late var repeatMode = audioManager.audioPlayer.loopMode;
  late var currentMediaItem = audioManager.getCurrentMediaItem();

  List<StreamSubscription> subscriptions = [];

  _NowPlayingBarState() {
    subscriptions.add(audioManager.audioPlayer.playingStream.listen((event) {
      setState(() {
        isPlaying = event;
      });
    }));
    subscriptions.add(audioManager.audioPlayer.positionStream.listen((event) {
      setState(() {
        position = event;
      });
    }));
    subscriptions.add(audioManager.audioPlayer.sequenceStateStream.listen((event) {
      setState(() {
        currentMediaItem = audioManager.getCurrentMediaItem();
      });
    }));
    subscriptions.add(audioManager.audioPlayer.shuffleModeEnabledStream.listen((event) {
      setState(() {
        shuffleEnabled = event;
      });
    }));
    subscriptions.add(audioManager.audioPlayer.loopModeStream.listen((event) {
      setState(() {
        repeatMode = event;
      });
    }));
  }

  @override
  void dispose() {
    for (var sub in subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }

  void playPause() {
    if (isPlaying) {
      audioManager.audioPlayer.pause();
    } else {
      audioManager.audioPlayer.play();
    }
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

  void toggleShuffle() {
    audioManager.audioPlayer.setShuffleModeEnabled(!shuffleEnabled);
  }

  void toggleRepeat() {
    if (audioManager.audioPlayer.loopMode == LoopMode.off) {
      audioManager.audioPlayer.setLoopMode(LoopMode.all);
    } else if (audioManager.audioPlayer.loopMode == LoopMode.all) {
      audioManager.audioPlayer.setLoopMode(LoopMode.one);
    } else {
      audioManager.audioPlayer.setLoopMode(LoopMode.off);
    }
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
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: theme.colorScheme.primary,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 4),
              padding: EdgeInsets.all(8.0)
            ),
            child: Slider(
              onChanged: seek,
              value: position.inMilliseconds.clamp(0, (currentMediaItem?.duration?.inMilliseconds.toDouble() ?? audioManager.audioPlayer.duration?.inMilliseconds ?? 1).toDouble()).toDouble(),
              min: 0,
              max: (currentMediaItem?.duration?.inMilliseconds.toDouble() ?? audioManager.audioPlayer.duration?.inMilliseconds ?? 1).toDouble()
            ),
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
                      IconButton(
                        onPressed: toggleRepeat,
                        icon: switch(repeatMode) {
                          LoopMode.off => Icon(Icons.repeat, color: theme.colorScheme.onSurface),
                          LoopMode.all => Icon(Icons.repeat, color: theme.colorScheme.primary),
                          LoopMode.one => Icon(Icons.repeat_one, color: theme.colorScheme.primary)
                        },
                        tooltip: lm.now_playing_repeat,
                      ),
                      IconButton(
                        onPressed: toggleShuffle,
                        icon: Icon(Icons.shuffle),
                        color: shuffleEnabled ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                        tooltip: lm.now_playing_shuffle
                      ),
                      SizedBox(width: 16)
                    ],
                    IconButton(
                      onPressed: skipPrevious,
                      icon: const Icon(Icons.skip_previous),
                      tooltip: lm.now_playing_previous
                    ),
                    IconButton(
                      onPressed: playPause,
                      icon: isPlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow),
                      tooltip: isPlaying ? lm.now_playing_pause : lm.now_playing_play
                    ),
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