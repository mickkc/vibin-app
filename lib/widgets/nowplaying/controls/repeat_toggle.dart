import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibin_app/l10n/app_localizations.dart';

import '../../../audio/audio_manager.dart';
import '../../../main.dart';

class RepeatToggle extends StatelessWidget {

  final bool showTooltip;

  RepeatToggle({
    super.key,
    this.showTooltip = true,
  });

  final audioManager = getIt<AudioManager>();

  void toggleRepeat() {
    switch (audioManager.audioPlayer.loopMode) {
      case LoopMode.off:
        audioManager.audioPlayer.setLoopMode(LoopMode.all);
        break;
      case LoopMode.all:
        audioManager.audioPlayer.setLoopMode(LoopMode.one);
        break;
      case LoopMode.one:
        audioManager.audioPlayer.setLoopMode(LoopMode.off);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {

    final th = Theme.of(context);

    return StreamBuilder(
      stream: audioManager.audioPlayer.loopModeStream,
      builder: (context, snapshot) {
        final mode = snapshot.data ?? LoopMode.off;
        return IconButton(
          onPressed: toggleRepeat,
          icon: switch (mode) {
            LoopMode.off => Icon(Icons.repeat, color: th.colorScheme.onSurface),
            LoopMode.all => Icon(Icons.repeat, color: th.colorScheme.primary),
            LoopMode.one => Icon(Icons.repeat_one, color: th.colorScheme.primary)
          },
          tooltip: showTooltip ? AppLocalizations.of(context)!.now_playing_repeat : null,
        );
      }
    );
  }
}