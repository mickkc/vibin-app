import 'package:flutter/material.dart';

import '../../../audio/audio_manager.dart';
import '../../../main.dart';

class SpeedSlider extends StatelessWidget {

  const SpeedSlider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    final audioManager = getIt<AudioManager>();
    final th = Theme.of(context);

    return StreamBuilder(
      stream: audioManager.audioPlayer.speedStream,
      initialData: audioManager.audioPlayer.speed,
      builder: (context, snapshot) {
        final speed = snapshot.data ?? 1.0;
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
                  audioManager.audioPlayer.setSpeed(value);
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
