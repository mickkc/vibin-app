import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:vibin_app/audio/audio_manager.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/widgets/colored_icon_button.dart';

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

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
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
        Row(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
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
                        audioManager.audioPlayer.setVolume(value);
                      },
                      activeColor: th.colorScheme.secondary
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  Icon(Icons.lyrics, color: th.colorScheme.onSurface),
                  Text("Lyrics", style: TextStyle(color: th.colorScheme.onSurface)),
                ],
              ),
            ),
            Expanded(
              child: Row(
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
                        audioManager.audioPlayer.setSpeed(value);
                      },
                      activeColor: th.colorScheme.secondary
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}