import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vibin_app/auth/AuthState.dart';
import 'package:vibin_app/dialogs/add_track_to_playlist_dialog.dart';
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

  final AuthState authState = getIt<AuthState>();
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

  Future<void> addToQueue(BuildContext context, int trackId) async {
    await audioManager.addTrackToQueue(trackId);
    if (!mounted || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.track_actions_added_to_queue))
    );
  }

  @override
  Widget build(BuildContext context) {
    final lm = AppLocalizations.of(context)!;
    return Row(
      spacing: 16,
      children: [
        if (authState.hasPermission(PermissionType.streamTracks)) ... [
          PlayButton(
            isPlaying: isCurrentTrack && isPlaying,
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
            }
          ),
          IconButton(
            onPressed: () {
              addToQueue(context, widget.trackId);
            },
            icon: const Icon(Icons.queue_music, size: 32),
            tooltip: lm.track_actions_add_to_queue,
          )
        ],
        if (authState.hasPermission(PermissionType.managePlaylists)) ... [
          IconButton(
            onPressed: () { AddTrackToPlaylistDialog.show(widget.trackId, context); },
            icon: const Icon(Icons.playlist_add, size: 32),
            tooltip: lm.track_actions_add_to_playlist,
          )
        ],
        if (authState.hasPermission(PermissionType.downloadTracks)) ... [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.download, size: 32),
            tooltip: lm.track_actions_download,
          )
        ],
        if (authState.hasPermission(PermissionType.manageTracks)) ... [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit, size: 32),
            tooltip: lm.track_actions_edit,
          )
        ]
      ],
    );
  }
}