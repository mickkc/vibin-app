import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:vibin_app/audio/audio_manager.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/widgets/animated_spectrogram_icon.dart';
import 'package:vibin_app/widgets/network_image.dart';

class NowPlayingQueue extends StatefulWidget {
  const NowPlayingQueue({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return const NowPlayingQueue();
      },
    );
  }

  @override
  State<NowPlayingQueue> createState() => _NowPlayingQueueState();
}

class _NowPlayingQueueState extends State<NowPlayingQueue> {

  late final AudioManager audioManager = getIt<AudioManager>();

  late int? currentIndex = audioManager.audioPlayer.currentIndex;
  late bool isPlaying = audioManager.audioPlayer.playing;

  late StreamSubscription sequenceSubscription;
  late StreamSubscription playingSubscription;

  _NowPlayingQueueState() {
    sequenceSubscription = audioManager.audioPlayer.sequenceStateStream.listen((event) {
      if (!mounted) return;
      if (event.currentIndex == currentIndex) return;
      setState(() {
        currentIndex = audioManager.audioPlayer.currentIndex;
      });
    });

    playingSubscription = audioManager.audioPlayer.playingStream.listen((event) {
      if (!mounted) return;
      if (event == isPlaying) return;
      setState(() {
        isPlaying = event;
      });
    });
  }

  @override
  void dispose() {
    sequenceSubscription.cancel();
    playingSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: audioManager.audioPlayer.sequence.isEmpty
            ? Text(AppLocalizations.of(context)!.now_playing_nothing)
            : ListView.builder(
                controller: scrollController,
                itemCount: audioManager.audioPlayer.sequence.length,
                itemBuilder: (context, index) {
                  final source = audioManager.audioPlayer.sequence[index];
                  final tag = source.tag;
                  if (tag is! MediaItem) {
                    return const SizedBox.shrink();
                  }
                  final isCurrent = currentIndex == index;
                  return ListTile(
                    leading: NetworkImageWidget(
                      url: tag.artUri.toString(),
                      width: 48,
                      height: 48
                    ),
                    title: Text(tag.title),
                    subtitle: Text(tag.artist ?? ''),
                    trailing: isCurrent ? AnimatedSpectogramIcon(
                      size: 24,
                      color: Theme.of(context).colorScheme.primary,
                      isPlaying: isPlaying,
                    ) : null,
                    onTap: () {
                      audioManager.audioPlayer.seek(Duration.zero, index: index);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
        );
      },
    );
  }
}