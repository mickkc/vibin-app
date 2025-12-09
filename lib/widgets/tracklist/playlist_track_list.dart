import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:vibin_app/dtos/playlist/playlist_track.dart';
import 'package:vibin_app/dtos/track/minimal_track.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/widgets/tracklist/playlist_track_row.dart';

import '../../api/api_manager.dart';
import '../../main.dart';
import '../../utils/error_handler.dart';

class PlaylistTrackList extends StatefulWidget {

  final List<PlaylistTrack> tracks;
  final int playlistId;
  final Function(MinimalTrack) onTrackTapped;

  const PlaylistTrackList({
    super.key,
    required this.tracks,
    required this.playlistId,
    required this.onTrackTapped,
  });

  @override
  State<PlaylistTrackList> createState() => _PlaylistTrackListState();
}

class _PlaylistTrackListState extends State<PlaylistTrackList> {

  late List<PlaylistTrack> _tracks;

  @override
  void initState() {
    super.initState();
    _tracks = widget.tracks;
  }

  void _handleTrackRemoved(int trackId) {
    setState(() {
      _tracks.removeWhere((t) => t.track.id == trackId);
    });
  }

  @override
  Widget build(BuildContext context) {

    final apiManager = getIt<ApiManager>();
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final lm = AppLocalizations.of(context)!;

    return SliverReorderableList(
      itemCount: _tracks.length,
      itemBuilder: (context, index) {
        final playlistTrack = _tracks[index];
        return PlaylistTrackRow(
          key: ValueKey(playlistTrack.track.id),
          playlistTrack: playlistTrack,
          playlistId: widget.playlistId,
          isMobile: isMobile,
          index: index,
          onTrackTapped: widget.onTrackTapped,
          onTrackRemoved: _handleTrackRemoved,
        );
      },
      proxyDecorator: (child, index, animation) {

        // Display a different style for vibedef tracks to indicate they cannot be reordered

        final playlistTrack = _tracks[index];
        final isVibedefTrack = playlistTrack.addedBy == null;

        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Material(
              elevation: 6,
              color: Colors.transparent,
              child: Opacity(
                opacity: isVibedefTrack ? 0.5 : 1.0,
                child: ColorFiltered(
                  colorFilter: isVibedefTrack
                    ? ColorFilter.mode(
                        Colors.red.withAlpha(100),
                        BlendMode.srcATop,
                      )
                    : const ColorFilter.mode(
                        Colors.transparent,
                        BlendMode.dst,
                      ),
                  child: child,
                ),
              ),
            );
          },
          child: child,
        );
      },
      onReorder: (int oldIndex, int newIndex) async {

        final before = _tracks.toList();

        PlaylistTrack item = _tracks[oldIndex];

        // Null = first position
        PlaylistTrack? afterItem;
        if (newIndex > 0) {
          if (newIndex > oldIndex) {
            afterItem = _tracks[newIndex - 1];
          }
          else {
            afterItem = _tracks[newIndex - 1];
          }
        }

        // Prevent moving vibedef tracks (addedBy == null)
        if (item.addedBy == null) {
          return;
        }

        // Find the first vibedef track index
        final firstVibedefIndex = _tracks.indexWhere((t) => t.addedBy == null);

        // Prevent moving user tracks to or below vibedef tracks
        if (firstVibedefIndex != -1 && newIndex >= firstVibedefIndex) {
          return;
        }

        setState(() {
          _tracks.removeAt(oldIndex);
          _tracks.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);
        });

        try {
          final newTracks = await apiManager.service.reorderPlaylistTracks(
            widget.playlistId,
            item.track.id,
            afterItem?.track.id
          );
          setState(() {
            _tracks = newTracks;
          });
        }
        catch (e, st) {
          log("An error occurred while reordering playlist tracks: $e", error: e, level: Level.error.value);
          if (context.mounted) {
            ErrorHandler.showErrorDialog(context, lm.playlist_reorder_tracks_error, error: e, stackTrace: st);
            setState(() {
              _tracks = before;
            }); // Reset to previous state
          }
        }
      },
    );
  }
}