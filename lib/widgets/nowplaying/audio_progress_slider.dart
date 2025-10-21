import 'package:flutter/material.dart';
import 'package:vibin_app/audio/audio_manager.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/main.dart';

class AudioProgressSlider extends StatelessWidget {
  final SliderThemeData sliderThemeData;
  final bool showTimes;

  const AudioProgressSlider({
    super.key,
    this.sliderThemeData = const SliderThemeData(),
    this.showTimes = true
  });


  @override
  Widget build(BuildContext context) {
    final audioManager = getIt<AudioManager>();
    return StreamBuilder(
      stream: audioManager.audioPlayer.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = audioManager.audioPlayer.duration ?? Duration.zero;
        return Row(
          children: [
            if (showTimes) Text(formatDuration(position.inSeconds)),
            Expanded(
              child: SliderTheme(
                data: sliderThemeData,
                child: Slider(
                  min: 0,
                  max: duration.inMilliseconds.toDouble(),
                  value: position.inMilliseconds.clamp(0, duration.inMilliseconds).toDouble(),
                  onChanged: (value) {
                    audioManager.seek(Duration(milliseconds: value.toInt()));
                  },
                ),
              ),
            ),
            if (showTimes) Text(formatDuration(duration.inSeconds)),
          ],
        );
      }
    );
  }
}