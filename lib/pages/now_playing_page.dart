import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:vibin_app/audio/audio_manager.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/widgets/now_playing_control_bar.dart';
import 'package:vibin_app/widgets/row_small_column.dart';
import 'package:vibin_app/widgets/track_info.dart';

import '../widgets/network_image.dart';

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const NowPlayingPage(),
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      constraints: BoxConstraints(
        maxWidth: max(MediaQuery.of(context).size.width * 0.9, 600.0)
      ),
    );
  }

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {

  void close() {
    GoRouter.of(context).pop();
  }

  AudioManager audioManager = getIt<AudioManager>();
  late MediaItem? currentMediaItem = audioManager.getCurrentMediaItem();
  late bool isPlaying = audioManager.audioPlayer.playing;
  late LoopMode repeatMode = audioManager.audioPlayer.loopMode;
  late bool shuffleEnabled = audioManager.audioPlayer.shuffleModeEnabled;

  List<StreamSubscription> subscriptions = [];

  _NowPlayingPageState() {
    subscriptions.add(audioManager.audioPlayer.sequenceStateStream.listen((event) {
      final tag = event.currentSource?.tag;
      if (tag is MediaItem) {
        if (tag.id != currentMediaItem?.id) {
          setState(() {
            currentMediaItem = audioManager.getCurrentMediaItem();
          });
        }
      }
    }));
  }

  @override
  void dispose() {
    for (var sub in subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Wrap(
          runSpacing: 8,
          children: currentMediaItem == null ? [
            const Text("No track is currently playing")
          ] : [
            RowSmallColumn(
              spacing: 32,
              rowChildren: [
                NetworkImageWidget(
                  url: "/api/tracks/${currentMediaItem!.id}/cover?quality=original",
                  width: 200,
                  height: 200,
                ),
                Expanded(
                  child: TrackInfoView(
                    trackId: int.parse(currentMediaItem!.id),
                    showMetadata: true
                  ),
                ),
              ],
              columnChildren: [
                NetworkImageWidget(
                  url: "/api/tracks/${currentMediaItem!.id}/cover?quality=original",
                  width: width * 0.75,
                  height: width * 0.75,
                ),
                TrackInfoView(
                  trackId: int.parse(currentMediaItem!.id),
                  showMetadata: false,
                ),
              ]
            ),
            SizedBox(height: 32),
            NowPlayingControlBar(mediaItem: currentMediaItem!)
          ]
        ),
      )
    );
  }
}