import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/audio/audio_manager.dart';
import 'package:vibin_app/auth/auth_state.dart';
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

  bool _isCurrent = false;
  bool _isPlaying = false;
  bool _isShuffleEnabled = false;
  late final _audioManager = getIt<AudioManager>();
  late final _authState = getIt<AuthState>();
  final List<StreamSubscription> _subscriptions = [];

  _PlaylistActionBarState() {
    _subscriptions.add(_audioManager.currentMediaItemStream.listen((event) {
      if (!mounted) return;
      setState(() {
        _isCurrent = _audioManager.currentAudioType != null &&
            _audioManager.currentAudioType!.audioType == AudioType.playlist &&
            _audioManager.currentAudioType!.id == widget.playlistData.playlist.id;
      });
    }));
    _subscriptions.add(_audioManager.audioPlayer.playingStream.listen((playing) {
      if (!mounted) return;
      setState(() {
        _isPlaying = playing;
      });
    }));
  }

  @override
  void dispose() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }

  void toggleShuffle() {
    if (_isCurrent) {
      _audioManager.toggleShuffle();
    }
    setState(() {
      _isShuffleEnabled = !_isShuffleEnabled;
    });
    widget.shuffleState?.isShuffling = _isShuffleEnabled;
  }

  void playPause() {
    if (!_isCurrent) {
      _audioManager.playPlaylistData(widget.playlistData, null, _isShuffleEnabled);
    } else {
      _audioManager.playPause();
    }
  }

  bool allowEdit() {
    if (!_authState.hasPermission(PermissionType.managePlaylists)) {
      return false;
    }

    final isOwner = widget.playlistData.playlist.owner.id == _authState.user?.id;
    final isCollaborator = widget.playlistData.playlist.collaborators.any((u) => u.id == _authState.user?.id);
    final canEditCollaborative = _authState.hasPermission(PermissionType.editCollaborativePlaylists);

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
        if (_authState.hasPermission(PermissionType.streamTracks)) ... [
          PlayButton(
            isPlaying: _isCurrent && _isPlaying,
            onTap: playPause
          ),
          IconButton(
            onPressed: toggleShuffle,
            tooltip: _isShuffleEnabled ? lm.playlist_actions_disable_shuffling : lm.playlist_actions_enable_shuffling,
            icon: Icon(
              Icons.shuffle,
              color: _isShuffleEnabled ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              size: 32,
            )
          )
        ],
        if (_authState.hasPermission(PermissionType.managePlaylists) && widget.playlistData.playlist.owner.id == _authState.user?.id) ... [
          IconButton(
            tooltip: lm.playlist_actions_add_collaborators,
            onPressed: () {},
            icon: const Icon(Icons.group_add, size: 32),
          )
        ],
        if (allowEdit()) ... [
          IconButton(
            tooltip: lm.playlist_actions_edit,
            onPressed: () {
              GoRouter.of(context).push("/playlists/${widget.playlistData.playlist.id}/edit");
            },
            icon: const Icon(Icons.edit, size: 32),
          )
        ]
      ],
    );
  }
}