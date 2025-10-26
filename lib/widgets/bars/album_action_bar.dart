import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/audio/audio_manager.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/dtos/shuffle_state.dart';
import 'package:vibin_app/widgets/play_button.dart';

import '../../audio/audio_type.dart';
import '../../auth/auth_state.dart';
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

  late final _audioManager = getIt<AudioManager>();
  late final _apiManager = getIt<ApiManager>();
  late final _authState = getIt<AuthState>();
  late bool _isPlaying = _audioManager.isPlaying;
  late bool _isCurrent = false;
  late bool _isShuffleEnabled = false;

  final List<StreamSubscription> _subscriptions = [];

  _AlbumActionBarState() {
    _subscriptions.add(_audioManager.currentMediaItemStream.listen((mediaItem) {
      if (!mounted) return;
      setState(() {
        _isCurrent = _audioManager.currentAudioType != null &&
            _audioManager.currentAudioType!.audioType == AudioType.album &&
            _audioManager.currentAudioType!.id == widget.albumId;
      });
    }));
    _subscriptions.add(_audioManager.audioPlayer.playingStream.listen((playing) {
      if (!mounted) return;
      setState(() {
        _isPlaying = playing;
      });
    }));
  }

  void _playPause() async {
    if (!_isCurrent) {
      final album = await _apiManager.service.getAlbum(widget.albumId);
      _audioManager.playAlbumData(album, null, _isShuffleEnabled);
    } else {
      await _audioManager.playPause();
    }
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

  @override
  Widget build(BuildContext context) {
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
            icon: Icon(
              Icons.shuffle,
              color: _isShuffleEnabled ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
              size: 32
            ),
          )
        ],
        if (_authState.hasPermission(PermissionType.manageAlbums))
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