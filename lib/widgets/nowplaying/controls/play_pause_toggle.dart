import 'package:flutter/material.dart';
import 'package:vibin_app/l10n/app_localizations.dart';

import '../../../audio/audio_manager.dart';
import '../../../main.dart';
import '../../colored_icon_button.dart';

class PlayPauseToggle extends StatelessWidget {
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final bool showTooltip;

  PlayPauseToggle({
    super.key,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.showTooltip = true,
  });

  final audioManager = getIt<AudioManager>();

  void playPause() {
    if (audioManager.audioPlayer.playing) {
      audioManager.audioPlayer.pause();
    } else {
      audioManager.audioPlayer.play();
    }
  }

  @override
  Widget build(BuildContext context) {

    final lm = AppLocalizations.of(context)!;

    return StreamBuilder(
      stream: audioManager.audioPlayer.playingStream,
      builder: (context, snapshot) {
        final playing = snapshot.data ?? false;

        if (backgroundColor == null) {
          return IconButton(
            iconSize: size,
            icon: Icon(playing ? Icons.pause : Icons.play_arrow),
            color: iconColor,
            onPressed: playPause,
            tooltip: showTooltip ? (playing ? lm.now_playing_pause : lm.now_playing_play) : null,
          );
        }

        return ColoredIconButton(
          icon: playing ? Icons.pause : Icons.play_arrow,
          backgroundColor: backgroundColor!,
          iconColor: iconColor,
          onPressed: playPause,
          size: size,
          tooltip: showTooltip ? (playing ? lm.now_playing_pause : lm.now_playing_play) : null,
        );
      }
    );
  }
}