import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../api/api_manager.dart';
import '../audio/audio_manager.dart';
import '../dtos/permission_type.dart';
import '../dtos/track/track.dart';
import '../main.dart';
import '../widgets/permission_widget.dart';

class TrackActionBar extends StatefulWidget {
  final int trackId;

  const TrackActionBar({
    super.key,
    required this.trackId
  });

  @override
  State<TrackActionBar> createState() => _TrackActionBarState();
}

class _TrackActionBarState extends State<TrackActionBar> {

  final ApiManager apiManager = getIt<ApiManager>();
  final AudioManager audioManager = getIt<AudioManager>();

  bool isCurrentTrack = false;
  bool isPlaying = false;

  StreamSubscription? playingSubscription;
  StreamSubscription? sequenceSubscription;

  _TrackActionBarState() {
    playingSubscription = audioManager.audioPlayer.playingStream.listen((event) {
      updatePlayState();
    });
    sequenceSubscription = audioManager.audioPlayer.sequenceStateStream.listen((event) {
      updatePlayState();
    });
  }

  @override
  void dispose() {
    playingSubscription?.cancel();
    sequenceSubscription?.cancel();
    super.dispose();
  }

  void updatePlayState() {
    final currentMediaItem = audioManager.getCurrentMediaItem();
    if (!mounted) return;
    setState(() {
      isCurrentTrack = currentMediaItem?.id == widget.trackId.toString();
      isPlaying = audioManager.audioPlayer.playing && isCurrentTrack;
    });
  }

  void playTrack(Track track) {
    final audioManager = getIt<AudioManager>();
    audioManager.playTrack(track);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16,
      children: [
        GestureDetector(
          onTap: () async {
            if (isCurrentTrack) {
              if (isPlaying) {
                await audioManager.audioPlayer.pause();
              } else {
                await audioManager.audioPlayer.play();
              }
            } else {
              final track = await apiManager.service.getTrack(widget.trackId);
              playTrack(track);
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Container(
                color: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.all(8),
                child: Icon(
                  isCurrentTrack && isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 48,
                  color: Theme.of(context).colorScheme.surface,
                )
            ),
          ),
        ),
        IconButton(
            onPressed: () {},
            icon: const Icon(Icons.playlist_add, size: 32)
        ),
        IconButton(
            onPressed: () {},
            icon: const Icon(CupertinoIcons.heart, size: 32)
        ),
        IconButton(
            onPressed: () {},
            icon: const Icon(Icons.download, size: 32)
        ),
        PermissionWidget(
            requiredPermissions: [PermissionType.manageTracks],
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.edit, size: 32),
            )
        )
      ],
    );
  }
}