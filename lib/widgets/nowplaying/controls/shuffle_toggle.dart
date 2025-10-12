import 'package:flutter/material.dart';
import 'package:vibin_app/l10n/app_localizations.dart';

import '../../../audio/audio_manager.dart';
import '../../../main.dart';

class ShuffleToggle extends StatelessWidget {

  final bool showTooltip;

  ShuffleToggle({
    super.key,
    this.showTooltip = true,
  });

  final audioManager = getIt<AudioManager>();

  void toggleShuffle() {
    final enable = !(audioManager.audioPlayer.shuffleModeEnabled);
    audioManager.audioPlayer.setShuffleModeEnabled(enable);
  }

  @override
  Widget build(BuildContext context) {

    final th = Theme.of(context);

    return StreamBuilder(
      stream: audioManager.audioPlayer.shuffleModeEnabledStream,
      builder: (context, snapshot) {
        final enabled = snapshot.data ?? false;
        return IconButton(
          onPressed: toggleShuffle,
          icon: Icon(
            Icons.shuffle,
            color: enabled ? th.colorScheme.primary : th.colorScheme.onSurface
          ),
          tooltip: showTooltip ? AppLocalizations.of(context)!.now_playing_shuffle : null,
        );
      }
    );
  }
}