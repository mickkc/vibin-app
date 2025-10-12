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

  const PlayPauseToggle({
    super.key,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.showTooltip = true,
  });

  @override
  Widget build(BuildContext context) {

    final lm = AppLocalizations.of(context)!;
    final audioManager = getIt<AudioManager>();

    return StreamBuilder(
      stream: audioManager.audioPlayer.playingStream,
      builder: (context, snapshot) {
        final playing = snapshot.data ?? false;

        if (backgroundColor == null) {
          return IconButton(
            iconSize: size,
            icon: Icon(playing ? Icons.pause : Icons.play_arrow),
            color: iconColor,
            onPressed: audioManager.playPause,
            tooltip: showTooltip ? (playing ? lm.now_playing_pause : lm.now_playing_play) : null,
          );
        }

        return ColoredIconButton(
          icon: playing ? Icons.pause : Icons.play_arrow,
          backgroundColor: backgroundColor!,
          iconColor: iconColor,
          onPressed: audioManager.playPause,
          size: size,
          tooltip: showTooltip ? (playing ? lm.now_playing_pause : lm.now_playing_play) : null,
        );
      }
    );
  }
}