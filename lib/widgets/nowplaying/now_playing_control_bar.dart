import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/audio/audio_manager.dart';
import 'package:vibin_app/dialogs/lyrics_dialog.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/widgets/colored_icon_button.dart';
import 'package:vibin_app/widgets/nowplaying/now_playing_queue.dart';

import '../../l10n/app_localizations.dart';

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
  late bool isPlaying = audioManager.audioPlayer.playing;
  late Duration position = audioManager.audioPlayer.position;
  late LoopMode repeatMode = audioManager.audioPlayer.loopMode;
  late bool shuffleEnabled = audioManager.audioPlayer.shuffleModeEnabled;
  late double volume = audioManager.audioPlayer.volume;
  late double speed = audioManager.audioPlayer.speed;

  List<StreamSubscription> subscriptions = [];

  _NowPlayingControlBarState() {
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
    subscriptions.add(audioManager.audioPlayer.volumeStream.listen((event) {
      setState(() {
        volume = event;
      });
    }));
    subscriptions.add(audioManager.audioPlayer.speedStream.listen((event) {
      setState(() {
        speed = event;
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

  void toggleRepeat() {
    if (repeatMode == LoopMode.off) {
      audioManager.audioPlayer.setLoopMode(LoopMode.all);
    } else if (repeatMode == LoopMode.all) {
      audioManager.audioPlayer.setLoopMode(LoopMode.one);
    } else {
      audioManager.audioPlayer.setLoopMode(LoopMode.off);
    }
  }

  void toggleShuffle() {
    audioManager.audioPlayer.setShuffleModeEnabled(!shuffleEnabled);
  }

  void playPause() {
    if (isPlaying) {
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
              VolumeSlider(
                volume: volume,
                onChanged: (audioVolume) {
                  audioManager.audioPlayer.setVolume(audioVolume);
                }
              ),
              SpeedSlider(
                speed: speed,
                onChanged: (audioSpeed) {
                  audioManager.audioPlayer.setSpeed(audioSpeed);
                }
              )
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
            Expanded(child: IconButton(
              onPressed: toggleRepeat,
              icon: switch (repeatMode) {
                LoopMode.off => Icon(Icons.repeat, color: th.colorScheme.onSurface),
                LoopMode.all => Icon(Icons.repeat, color: th.colorScheme.primary),
                LoopMode.one => Icon(Icons.repeat_one, color: th.colorScheme.primary)
              }
            )),
            ColoredIconButton(
                icon: Icons.skip_previous,
                backgroundColor: th.colorScheme.secondary,
                iconColor: th.colorScheme.onSecondary,
                onPressed: audioManager.audioPlayer.seekToPrevious
            ),
            ColoredIconButton(
              icon: isPlaying ? Icons.pause : Icons.play_arrow,
              backgroundColor: th.colorScheme.primary,
              iconColor: th.colorScheme.onPrimary,
              onPressed: playPause,
              size: 32,
            ),
            ColoredIconButton(
                icon: Icons.skip_next,
                backgroundColor: th.colorScheme.secondary,
                iconColor: th.colorScheme.onSecondary,
                onPressed: audioManager.audioPlayer.seekToNext
            ),
            Expanded(
              child: IconButton(
                onPressed: toggleShuffle,
                icon: Icon(
                  Icons.shuffle,
                  color: shuffleEnabled ? th.colorScheme.primary : th.colorScheme.onSurface
                )
              )
            )
          ],
        ),
        Row(
          spacing: 8,
          children: [
            Text(
              "${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}"
            ),
            Expanded(
              child: Slider(
                value: position.inMilliseconds.toDouble().clamp(0, widget.mediaItem.duration?.inMilliseconds.toDouble() ?? 0),
                max: widget.mediaItem.duration?.inMilliseconds.toDouble() ?? 0,
                onChanged: (value) {
                  audioManager.audioPlayer.seek(Duration(milliseconds: value.toInt()));
                }
              ),
            ),
            Text(
              widget.mediaItem.duration != null ?
                "${widget.mediaItem.duration!.inMinutes}:${(widget.mediaItem.duration!.inSeconds % 60).toString().padLeft(2, '0')}"
                : "0:00"
            ),
          ],
        ),

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
                child: VolumeSlider(
                  volume: volume,
                  onChanged: (audioVolume) {
                    audioManager.audioPlayer.setVolume(audioVolume);
                  }
                )
              ),
              lyricsButton(),
              ElevatedButton.icon(
                onPressed: showQueue,
                label: Text(lm.now_playing_queue),
                icon: Icon(Icons.queue_music)
              ),
              Expanded(
                child: SpeedSlider(
                  speed: speed,
                  onChanged: (audioSpeed) {
                    audioManager.audioPlayer.setSpeed(audioSpeed);
                  }
                )
              )
            ],
          )
        ]
      ],
    );
  }
}

class VolumeSlider extends StatefulWidget {
  final double volume;
  final ValueChanged<double> onChanged;
  const VolumeSlider({
    super.key,
    required this.volume,
    required this.onChanged
  });

  @override
  State<VolumeSlider> createState() => _VolumeSliderState();
}

class _VolumeSliderState extends State<VolumeSlider> {
  late double volume = widget.volume;

  @override
  void didUpdateWidget(covariant VolumeSlider oldWidget) {
    if (oldWidget.volume != widget.volume) {
      setState(() {
        volume = widget.volume;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(Icons.volume_up, color: th.colorScheme.onSurface),
        Expanded(
          child: Slider(
            value: volume,
            min: 0,
            max: 1,
            label: "${(volume * 100).toStringAsFixed(0)}%",
            onChanged: (value) {
              setState(() {
                volume = value;
              });
              widget.onChanged(value);
            },
            activeColor: th.colorScheme.secondary
          ),
        ),
      ],
    );
  }
}

class SpeedSlider extends StatefulWidget {
  final double speed;
  final ValueChanged<double> onChanged;
  const SpeedSlider({
    super.key,
    required this.speed,
    required this.onChanged
  });

  @override
  State<SpeedSlider> createState() => _SpeedSliderState();
}

class _SpeedSliderState extends State<SpeedSlider> {
  late double speed = widget.speed;

  @override
  void didUpdateWidget(covariant SpeedSlider oldWidget) {
    if (oldWidget.speed != widget.speed) {
      setState(() {
        speed = widget.speed;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(Icons.speed, color: th.colorScheme.onSurface),
        Expanded(
          child: Slider(
            value: speed,
            min: 0.25,
            max: 2,
            divisions: 7,
            label: "${speed.toStringAsFixed(2)}x",
            onChanged: (value) {
              setState(() {
                speed = value;
              });
              widget.onChanged(value);
            },
            activeColor: th.colorScheme.secondary
          ),
        ),
      ],
    );
  }
}