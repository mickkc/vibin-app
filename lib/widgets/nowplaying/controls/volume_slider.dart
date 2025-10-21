import 'package:flutter/material.dart';

import '../../../audio/audio_manager.dart';
import '../../../main.dart';

class VolumeSlider extends StatelessWidget {

  const VolumeSlider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    final audioManager = getIt<AudioManager>();
    final th = Theme.of(context);

    return StreamBuilder(
      stream: audioManager.audioPlayer.volumeStream,
      initialData: audioManager.volume,
      builder: (context, snapshot) {
        final volume = snapshot.data ?? 0.5;
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
                  audioManager.volume = value;
                },
                activeColor: th.colorScheme.secondary
              ),
            ),
          ],
        );
      }
    );
  }
}