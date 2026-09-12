import 'package:flutter/material.dart';
import 'package:vibin_app/audio/audio_manager.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/main.dart';

class AudioProgressSlider extends StatefulWidget {
  final SliderThemeData sliderThemeData;
  final bool showTimes;

  const AudioProgressSlider({
    super.key,
    this.sliderThemeData = const SliderThemeData(),
    this.showTimes = true
  });

  @override
  State<AudioProgressSlider> createState() => _AudioProgressSliderState();
}

class _AudioProgressSliderState extends State<AudioProgressSlider> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final audioManager = getIt<AudioManager>();
    return StreamBuilder(
      stream: audioManager.audioPlayer.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = audioManager.getCurrentMediaItem()?.duration ?? audioManager.audioPlayer.duration ?? Duration.zero;
        final displayPosition = _dragValue != null
            ? Duration(milliseconds: _dragValue!.toInt())
            : position;
        final sliderValue = (_dragValue ?? position.inMilliseconds.toDouble())
            .clamp(0.0, duration.inMilliseconds.toDouble());
        return Row(
          children: [
            if (widget.showTimes) Text(formatDuration(displayPosition.inSeconds)),
            Expanded(
              child: SliderTheme(
                data: widget.sliderThemeData,
                child: Slider(
                  min: 0,
                  max: duration.inMilliseconds.toDouble(),
                  value: sliderValue,
                  onChanged: (value) {
                    setState(() => _dragValue = value);
                  },
                  onChangeEnd: (value) {
                    audioManager.seek(Duration(milliseconds: value.toInt()));
                    setState(() => _dragValue = null);
                  },
                ),
              ),
            ),
            if (widget.showTimes) Text(formatDuration(duration.inSeconds)),
          ],
        );
      }
    );
  }
}
