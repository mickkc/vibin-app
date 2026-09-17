import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
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
      stream: audioManager.audioPlayer.playerStateStream,
      initialData: audioManager.audioPlayer.playerState,
      builder: (context, snapshot) {

        if (snapshot.data?.processingState == ProcessingState.loading || snapshot.data?.processingState == ProcessingState.buffering) {
          return Padding(
            padding: EdgeInsets.all(backgroundColor == null ? 8.0 : 12.0),
            child: SizedBox(
              width: size ?? 24,
              height: size ?? 24,
              child: CircularProgressIndicator(),
            ),
          );
        }

        final playing = snapshot.data?.playing ?? false;

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