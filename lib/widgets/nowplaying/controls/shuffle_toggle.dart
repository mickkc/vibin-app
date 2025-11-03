import 'package:flutter/material.dart';
import 'package:vibin_app/l10n/app_localizations.dart';

import '../../../audio/audio_manager.dart';
import '../../../main.dart';

class ShuffleToggle extends StatelessWidget {

  final bool showTooltip;

  const ShuffleToggle({
    super.key,
    this.showTooltip = true,
  });

  @override
  Widget build(BuildContext context) {

    final th = Theme.of(context);
    final audioManager = getIt<AudioManager>();

    return StreamBuilder(
      stream: audioManager.shuffleModeStream,
      builder: (context, snapshot) {
        final enabled = snapshot.data ?? audioManager.isShuffling;
        return IconButton(
          onPressed: audioManager.toggleShuffle,
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