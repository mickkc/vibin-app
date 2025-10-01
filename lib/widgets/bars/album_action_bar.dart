import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/audio/audio_manager.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/dtos/shuffle_state.dart';
import 'package:vibin_app/widgets/play_button.dart';

import '../../audio/audio_type.dart';
import '../../auth/AuthState.dart';
import '../../main.dart';

class AlbumActionBar extends StatefulWidget {
  final int albumId;
  final ShuffleState? shuffleState;

  const AlbumActionBar({
    super.key,
    required this.albumId,
    this.shuffleState,
  });

  @override
  State<AlbumActionBar> createState() => _AlbumActionBarState();
}

class _AlbumActionBarState extends State<AlbumActionBar> {

  late final audioManager = getIt<AudioManager>();
  late final apiManager = getIt<ApiManager>();
  late final authState = getIt<AuthState>();
  late bool isPlaying = audioManager.audioPlayer.playing;
  late bool isCurrent = false;
  late bool isShuffleEnabled = false;

  final List<StreamSubscription> subscriptions = [];

  _AlbumActionBarState() {
    subscriptions.add(audioManager.audioPlayer.sequenceStateStream.listen((event) {
      if (!mounted) return;
      setState(() {
        updatePlayingState();
      });
    }));
    subscriptions.add(audioManager.audioPlayer.playingStream.listen((event) {
      if (!mounted) return;
      setState(() {
        updatePlayingState();
      });
    }));
  }

  void updatePlayingState() {
    final currentAudioType = audioManager.currentAudioType;
    setState(() {
      isPlaying = audioManager.audioPlayer.playing;
      isCurrent = currentAudioType != null && currentAudioType.audioType == AudioType.album && currentAudioType.id == widget.albumId;
    });
  }

  void playPause() async {
    if (!isCurrent) {
      final album = await apiManager.service.getAlbum(widget.albumId);
      audioManager.playAlbumData(album, null, isShuffleEnabled);
    } else {
      if (isPlaying) {
        audioManager.audioPlayer.pause();
      } else {
        audioManager.audioPlayer.play();
      }
    }
  }

  void toggleShuffle() {
    if (isCurrent) {
      audioManager.audioPlayer.setShuffleModeEnabled(!isShuffleEnabled);
    }
    setState(() {
      isShuffleEnabled = !isShuffleEnabled;
    });
    widget.shuffleState?.isShuffling = isShuffleEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (authState.hasPermission(PermissionType.streamTracks)) ... [
          PlayButton(
            isPlaying: isCurrent && isPlaying,
            onTap: playPause
          ),
          IconButton(
            onPressed: toggleShuffle,
            icon: Icon(
              Icons.shuffle,
              color: isShuffleEnabled ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
              size: 32
            ),
          )
        ],
        if (authState.hasPermission(PermissionType.manageAlbums))
          IconButton(
            onPressed: () {
              GoRouter.of(context).push("/albums/${widget.albumId}/edit");
            },
            icon: const Icon(Icons.edit, size: 32),
          )
      ],
    );
  }
}