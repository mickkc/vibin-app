import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:vibin_app/audio/audio_manager.dart';
import 'package:vibin_app/auth/AuthState.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/dtos/playlist/playlist_data.dart';
import 'package:vibin_app/dtos/shuffle_state.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/widgets/play_button.dart';

import '../../audio/audio_type.dart';
import '../../main.dart';

class PlaylistActionBar extends StatefulWidget {
  final PlaylistData playlistData;
  final ShuffleState? shuffleState;

  const PlaylistActionBar({
    super.key,
    required this.playlistData,
    this.shuffleState,
  });

  @override
  State<PlaylistActionBar> createState() => _PlaylistActionBarState();
}

class _PlaylistActionBarState extends State<PlaylistActionBar> {

  bool isCurrent = false;
  bool isPlaying = false;
  bool isShuffleEnabled = false;
  late final AudioManager audioManager = getIt<AudioManager>();
  late final AuthState authState = getIt<AuthState>();
  final List<StreamSubscription> subscriptions = [];

  _PlaylistActionBarState() {
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

  @override
  void dispose() {
    for (var sub in subscriptions) {
      sub.cancel();
    }
    log("Disposed");
    super.dispose();
  }

  void updatePlayingState() {
    setState(() {
      isPlaying = audioManager.audioPlayer.playing;
      final currentType = audioManager.currentAudioType;
      isCurrent = currentType != null && currentType.audioType == AudioType.playlist && currentType.id == widget.playlistData.playlist.id;
    });
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

  void playPause() {
    if (!isCurrent) {
      audioManager.playPlaylistData(widget.playlistData, null, isShuffleEnabled);
    } else {
      if (isPlaying) {
        audioManager.audioPlayer.pause();
      } else {
        audioManager.audioPlayer.play();
      }
    }
  }

  bool allowEdit() {
    if (!authState.hasPermission(PermissionType.managePlaylists)) {
      return false;
    }

    final isOwner = widget.playlistData.playlist.owner.id == authState.user?.id;
    final isCollaborator = widget.playlistData.playlist.collaborators.any((u) => u.id == authState.user?.id);
    final canEditCollaborative = authState.hasPermission(PermissionType.editCollaborativePlaylists);

    return isOwner || (isCollaborator && canEditCollaborative);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lm = AppLocalizations.of(context)!;
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
            tooltip: isShuffleEnabled ? lm.playlist_actions_disable_shuffling : lm!.playlist_actions_enable_shuffling,
            icon: Icon(
              Icons.shuffle,
              color: isShuffleEnabled ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              size: 32,
            )
          )
        ],
        if (authState.hasPermission(PermissionType.managePlaylists) && widget.playlistData.playlist.owner.id == authState.user?.id) ... [
          IconButton(
            tooltip: lm.playlist_actions_add_collaborators,
            onPressed: () {},
            icon: const Icon(Icons.group_add, size: 32),
          )
        ],
        if (allowEdit()) ... [
          IconButton(
            tooltip: lm.playlist_actions_edit,
            onPressed: () {},
            icon: const Icon(Icons.edit, size: 32),
          )
        ]
      ],
    );
  }
}