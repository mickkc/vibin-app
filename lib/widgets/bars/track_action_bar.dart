import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/auth/auth_state.dart';
import 'package:vibin_app/dialogs/add_track_to_playlist_dialog.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/utils/track_downloader.dart';
import 'package:vibin_app/widgets/entity_card.dart';
import 'package:vibin_app/widgets/play_button.dart';

import '../../api/api_manager.dart';
import '../../audio/audio_manager.dart';
import '../../dtos/permission_type.dart';
import '../../dtos/track/track.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../favorite_icon_button.dart';

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

  final _authState = getIt<AuthState>();
  final _apiManager = getIt<ApiManager>();
  final _audioManager = getIt<AudioManager>();

  bool _isCurrentTrack = false;
  bool _isPlaying = false;

  late final StreamSubscription? _playingSubscription;
  late final StreamSubscription? _sequenceSubscription;

  _TrackActionBarState() {
    _playingSubscription = _audioManager.audioPlayer.playingStream.listen((event) {
      setState(() {
        _isPlaying = event;
      });
    });
    _sequenceSubscription = _audioManager.currentMediaItemStream.listen((mediaItem) {
      setState(() {
        _isCurrentTrack = mediaItem?.id == widget.trackId.toString();
      });
    });
  }

  @override
  void dispose() {
    _playingSubscription?.cancel();
    _sequenceSubscription?.cancel();
    super.dispose();
  }

  void _playTrack(Track track) {
    _audioManager.playTrack(track);
  }

  Future<void> _addToQueue(BuildContext context, int trackId) async {
    await _audioManager.addTrackIdToQueue(trackId, false);
    if (!mounted || !context.mounted) return;
    showSnackBar(context, AppLocalizations.of(context)!.track_actions_added_to_queue);
  }

  @override
  Widget build(BuildContext context) {
    final lm = AppLocalizations.of(context)!;
    return Row(
      spacing: 16,
      children: [
        if (_authState.hasPermission(PermissionType.streamTracks)) ... [
          PlayButton(
            isPlaying: _isCurrentTrack && _isPlaying,
            onTap: () async {
              if (_isCurrentTrack) {
                _audioManager.playPause();
              } else {
                final track = await _apiManager.service.getTrack(widget.trackId);
                _playTrack(track);
              }
            }
          ),
          IconButton(
            onPressed: () => _addToQueue(context, widget.trackId),
            icon: const Icon(Icons.queue_music, size: 32),
            tooltip: lm.track_actions_add_to_queue,
          )
        ],
        if (_authState.hasPermission(PermissionType.managePlaylistTracks)) ... [
          IconButton(
            onPressed: () => AddTrackToPlaylistDialog.show(context, widget.trackId),
            icon: const Icon(Icons.playlist_add, size: 32),
            tooltip: lm.track_actions_add_to_playlist,
          )
        ],
        if (_authState.hasPermission(PermissionType.downloadTracks)) ... [
          IconButton(
            onPressed: () => TrackDownloader.downloadTrack(context, widget.trackId),
            icon: const Icon(Icons.download, size: 32),
            tooltip: lm.track_actions_download,
          )
        ],
        if (_authState.hasPermission(PermissionType.manageTracks)) ... [
          IconButton(
            onPressed: () => GoRouter.of(context).push("/tracks/${widget.trackId}/edit"),
            icon: const Icon(Icons.edit, size: 32),
            tooltip: lm.track_actions_edit,
          )
        ],
        if (_authState.hasPermission(PermissionType.manageOwnUser))
          FavoriteIconButton(
            type: EntityCardType.track,
            entityId: widget.trackId,
          )
      ],
    );
  }
}