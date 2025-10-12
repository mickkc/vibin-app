import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibin_app/l10n/app_localizations.dart';

import '../../../audio/audio_manager.dart';
import '../../../main.dart';

class RepeatToggle extends StatelessWidget {

  final bool showTooltip;

  const RepeatToggle({
    super.key,
    this.showTooltip = true,
  });

  @override
  Widget build(BuildContext context) {

    final audioManager = getIt<AudioManager>();
    final th = Theme.of(context);

    return StreamBuilder(
      stream: audioManager.audioPlayer.loopModeStream,
      builder: (context, snapshot) {
        final mode = snapshot.data ?? LoopMode.off;
        return IconButton(
          onPressed: audioManager.toggleRepeat,
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