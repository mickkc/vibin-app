import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:vibin_app/auth/auth_state.dart';
import 'package:vibin_app/dialogs/add_track_to_playlist_dialog.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/widgets/play_button.dart';

import '../../api/api_manager.dart';
import '../../audio/audio_manager.dart';
import '../../dtos/permission_type.dart';
import '../../dtos/track/track.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.track_actions_added_to_queue))
    );
  }

  Future<void> _downloadTrack() async {

    final lm = AppLocalizations.of(context)!;

    try {
      final track = await _apiManager.service.getTrack(widget.trackId);
      final bytes = await _apiManager.service.downloadTrack(widget.trackId);

      if (!mounted) return;

      final saveFile = await FilePicker.platform.saveFile(
        dialogTitle: lm.track_actions_download,
        fileName: track.path.split("/").last,
        bytes: Uint8List.fromList(bytes.data),
        type: FileType.audio
      );

      if (saveFile == null) return;

      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final file = File(saveFile);
        await file.writeAsBytes(bytes.data);
      }

      if (mounted) {
        showSnackBar(context, lm.track_actions_download_success);
      }
    }
    catch (e) {
      log("Error downloading track: $e", error: e, level: Level.error.value);
      if (mounted) {
        showSnackBar(context, lm.track_actions_download_error);
      }
    }
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
            onPressed: () {
              _addToQueue(context, widget.trackId);
            },
            icon: const Icon(Icons.queue_music, size: 32),
            tooltip: lm.track_actions_add_to_queue,
          )
        ],
        if (_authState.hasPermission(PermissionType.managePlaylists)) ... [
          IconButton(
            onPressed: () { AddTrackToPlaylistDialog.show(widget.trackId, context); },
            icon: const Icon(Icons.playlist_add, size: 32),
            tooltip: lm.track_actions_add_to_playlist,
          )
        ],
        if (_authState.hasPermission(PermissionType.downloadTracks)) ... [
          IconButton(
            onPressed: _downloadTrack,
            icon: const Icon(Icons.download, size: 32),
            tooltip: lm.track_actions_download,
          )
        ],
        if (_authState.hasPermission(PermissionType.manageTracks)) ... [
          IconButton(
            onPressed: () {
              GoRouter.of(context).push("/tracks/${widget.trackId}/edit");
            },
            icon: const Icon(Icons.edit, size: 32),
            tooltip: lm.track_actions_edit,
          )
        ]
      ],
    );
  }
}