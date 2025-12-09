import 'package:flutter/material.dart';
import 'package:vibin_app/widgets/tracklist/track_list_action_view.dart';
import 'package:vibin_app/widgets/tracklist/track_list_album_view.dart';
import 'package:vibin_app/widgets/tracklist/track_list_duration_view.dart';
import 'package:vibin_app/widgets/tracklist/track_list_main_widget.dart';
import 'package:vibin_app/widgets/tracklist/track_list_user_widget.dart';

import '../../dtos/playlist/playlist_track.dart';
import '../../dtos/track/minimal_track.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/datetime_utils.dart';
import '../network_image.dart';

class PlaylistTrackRow extends StatefulWidget {
  final PlaylistTrack playlistTrack;
  final int playlistId;
  final bool isMobile;
  final int index;
  final Function(MinimalTrack) onTrackTapped;
  final Function(int) onTrackRemoved;

  const PlaylistTrackRow({
    super.key,
    required this.playlistTrack,
    required this.playlistId,
    required this.isMobile,
    required this.index,
    required this.onTrackTapped,
    required this.onTrackRemoved,
  });

  @override
  State<PlaylistTrackRow> createState() => _PlaylistTrackRowState();
}

class _PlaylistTrackRowState extends State<PlaylistTrackRow> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final lm = AppLocalizations.of(context)!;

    return RepaintBoundary(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          NetworkImageWidget(
            url: "/api/tracks/${widget.playlistTrack.track.id}/cover?quality=64",
            width: 48,
            height: 48
          ),

          Expanded(
            flex: 2,
            child: TrackListMainWidget(
              track: widget.playlistTrack.track,
              onTrackTapped: (t) => widget.onTrackTapped(t as MinimalTrack),
            ),
          ),

          if (!widget.isMobile)
            Expanded(
              flex: 1,
              child: TrackListAlbumView(
                album: widget.playlistTrack.track.album
              ),
            ),

          SizedBox(
            width: widget.isMobile ? null : 120,
            child: Align(
              alignment: Alignment.centerRight,
              child: TrackListUserWidget(
                isMobile: widget.isMobile,
                user: widget.playlistTrack.addedBy,
                tooltip: widget.playlistTrack.addedBy != null && widget.playlistTrack.addedAt != null
                  ? lm.playlist_added_by_at(DateTimeUtils.convertUtcUnixToLocalTimeString(widget.playlistTrack.addedAt!, lm.datetime_format_date), widget.playlistTrack.addedBy!.name)
                  : lm.playlist_added_via_vibedef
              ),
            ),
          ),

          if (!widget.isMobile)
            TrackListDurationView(
              duration: widget.playlistTrack.track.duration,
            ),

          TrackListActionView(
            track: widget.playlistTrack.track,
            playlistId: widget.playlistId,
            onTrackRemoved: widget.onTrackRemoved,
          ),

          if (!widget.isMobile)
            widget.playlistTrack.addedBy != null
              ? ReorderableDragStartListener(
                  index: widget.index,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(Icons.drag_handle),
                  ),
              )
              : const SizedBox(width: 40)
        ],
      ),
    );
  }
}