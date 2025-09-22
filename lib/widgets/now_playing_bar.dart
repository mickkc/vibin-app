import 'package:flutter/material.dart';
import 'package:vibin_app/audio/audio_manager.dart';
import 'package:vibin_app/main.dart';

class NowPlayingBar extends StatefulWidget {
  const NowPlayingBar({super.key});

  @override
  State<NowPlayingBar> createState() => _NowPlayingBarContext();
}

class _NowPlayingBarContext extends State<NowPlayingBar> {

  final AudioManager audioManager = getIt<AudioManager>();
  late var isPlaying = audioManager.audioPlayer.playing;
  late var position = audioManager.audioPlayer.position;
  late var currentMediaItem = audioManager.getCurrentMediaItem();

  _NowPlayingBarContext() {
    audioManager.audioPlayer.playingStream.listen((event) {
      setState(() {
        isPlaying = event;
      });
    });
    audioManager.audioPlayer.positionStream.listen((event) {
      setState(() {
        position = event;
      });
    });
    audioManager.audioPlayer.sequenceStateStream.listen((event) {
      setState(() {
        currentMediaItem = audioManager.getCurrentMediaItem();
      });
    });
  }

  void playPause() {
    if (isPlaying) {
      audioManager.audioPlayer.pause();
    } else {
      audioManager.audioPlayer.play();
    }
  }

  void skipNext() {
    audioManager.audioPlayer.seekToNext();
  }

  void skipPrevious() {
    audioManager.audioPlayer.seekToPrevious();
  }

  void seek(double milliseconds) {
    audioManager.audioPlayer.seek(Duration(milliseconds: milliseconds.toInt()));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {

      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: Theme.of(context).colorScheme.primary,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 4),
              padding: EdgeInsets.all(8.0)
            ),
            child: Slider(
              onChanged: seek,
              value: position.inMilliseconds.toDouble(),
              min: 0,
              max: (currentMediaItem?.duration?.inMilliseconds.toDouble() ?? audioManager.audioPlayer.duration?.inMilliseconds ?? 1).toDouble()
            ),
          ),
          Container(
            height: 60,
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    if (currentMediaItem?.artUri != null) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                        child: Image.network(
                          currentMediaItem!.artUri.toString(),
                          headers: currentMediaItem?.artHeaders ?? {},
                          width: 44,
                          height: 44
                        ),
                      )
                    ],
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(currentMediaItem?.title ?? "", style: Theme.of(context).textTheme.bodyLarge),
                        Text(currentMediaItem?.artist ?? "", style: Theme.of(context).textTheme.bodyMedium),
                    ]),
                  ],
                ),
                Row(
                  children: [
                    IconButton(onPressed: skipPrevious, icon: const Icon(Icons.skip_previous)),
                    IconButton(onPressed: playPause, icon: isPlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow)),
                    IconButton(onPressed: skipNext, icon: const Icon(Icons.skip_next)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}