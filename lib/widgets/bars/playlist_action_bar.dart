import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:vibin_app/audio/audio_manager.dart';
import 'package:vibin_app/auth/auth_state.dart';
import 'package:vibin_app/dialogs/playlist_collaborator_dialog.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/dtos/playlist/playlist_data.dart';
import 'package:vibin_app/dtos/playlist/playlist_edit_data.dart';
import 'package:vibin_app/dtos/shuffle_state.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/utils/error_handler.dart';
import 'package:vibin_app/widgets/play_button.dart';

import '../../api/api_manager.dart';
import '../../audio/audio_type.dart';
import '../../main.dart';

class PlaylistActionBar extends StatefulWidget {
  final PlaylistData playlistData;
  final ShuffleState? shuffleState;
  final void Function(PlaylistData) onUpdate;

  const PlaylistActionBar({
    super.key,
    required this.playlistData,
    this.shuffleState,
    required this.onUpdate,
  });

  @override
  State<PlaylistActionBar> createState() => _PlaylistActionBarState();
}

class _PlaylistActionBarState extends State<PlaylistActionBar> {

  final _audioManager = getIt<AudioManager>();
  final _authState = getIt<AuthState>();
  final _apiManager = getIt<ApiManager>();

  bool _isCurrent = false;
  late bool _isPlaying = _audioManager.isPlaying;
  late bool _isShuffleEnabled = _audioManager.isShuffling;
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _subscriptions.add(_audioManager.currentMediaItemStream.listen((mediaItem) {
      if (!mounted) return;
      setState(() {
        if (mediaItem == null) {
          _isCurrent = false;
          return;
        }
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

  void _toggleShuffle() {
    if (_isCurrent) {
      _audioManager.toggleShuffle();
    }
    setState(() {
      _isShuffleEnabled = !_isShuffleEnabled;
    });
    widget.shuffleState?.isShuffling = _isShuffleEnabled;
  }

  void _playPause() {
    if (!_isCurrent) {
      _audioManager.playPlaylistData(widget.playlistData, shuffle: _isShuffleEnabled);
    } else {
      _audioManager.playPause();
    }
  }

  bool _allowEdit() {
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
            onTap: _playPause
          ),
          IconButton(
            onPressed: _toggleShuffle,
            tooltip: _isShuffleEnabled ? lm.playlist_actions_disable_shuffling : lm.playlist_actions_enable_shuffling,
            icon: Icon(
              Icons.shuffle,
              color: _isShuffleEnabled ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              size: 32,
            )
          )
        ],

        if (
          _authState.hasPermissions([PermissionType.managePlaylists, PermissionType.viewUsers])
          && widget.playlistData.playlist.owner.id == _authState.user?.id
        )
          IconButton(
            tooltip: lm.playlist_actions_add_collaborators,
            onPressed: () {
              PlaylistCollaboratorDialog.show(
                context,
                initialCollaborators: widget.playlistData.playlist.collaborators,
                onCollaboratorsUpdated: (collaborators) async {
                  try {
                    final updated = await _apiManager.service.updatePlaylist(
                      widget.playlistData.playlist.id,
                      PlaylistEditData(
                        name: widget.playlistData.playlist.name,
                        collaboratorIds: collaborators.map((e) => e.id).toList(),
                      )
                    );
                    widget.onUpdate(widget.playlistData.copyWith(playlist: updated));
                  }
                  catch (e, st) {
                    log("Failed to update playlist collaborators", error: e, stackTrace: st, level: Level.error.value);
                    if (!mounted || !context.mounted) return;
                    ErrorHandler.showErrorDialog(context, lm.playlist_actions_update_collaborators_failed, error: e, stackTrace: st);
                  }
                },
              );
            },
            icon: const Icon(Icons.group_add, size: 32),
          ),

        if (_allowEdit())
          IconButton(
            tooltip: lm.playlist_actions_edit,
            onPressed: () {
              GoRouter.of(context).push("/playlists/${widget.playlistData.playlist.id}/edit");
            },
            icon: const Icon(Icons.edit, size: 32),
          )
      ],
    );
  }
}