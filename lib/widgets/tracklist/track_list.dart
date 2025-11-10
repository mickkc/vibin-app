import 'package:flutter/material.dart';
import 'package:vibin_app/dtos/track/base_track.dart';
import 'package:vibin_app/widgets/network_image.dart';
import 'package:vibin_app/widgets/tracklist/track_list_action_view.dart';
import 'package:vibin_app/widgets/tracklist/track_list_album_view.dart';
import 'package:vibin_app/widgets/tracklist/track_list_duration_view.dart';
import 'package:vibin_app/widgets/tracklist/track_list_main_widget.dart';

class TrackList extends StatefulWidget {
  final List<BaseTrack> tracks;
  final int? playlistId;
  final int? albumId;

  final Function(BaseTrack)? onTrackTapped;

  const TrackList({
    super.key,
    required this.tracks,
    this.playlistId,
    this.albumId,
    this.onTrackTapped,
  });

  @override
  State<TrackList> createState() => _TrackListState();
}

class _TrackListState extends State<TrackList> {

  List<BaseTrack> _tracks = [];

  @override
  void initState() {
    _tracks = widget.tracks;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Table(
      border: TableBorder(
        horizontalInside: BorderSide(
          color: Theme.of(context).colorScheme.surfaceContainerHighest
        )
      ),
      columnWidths: <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(2),
        if (!isMobile) ... {
          2: FlexColumnWidth(1),
          3: IntrinsicColumnWidth(),
          4: IntrinsicColumnWidth()
        }
        else ... {
          2: IntrinsicColumnWidth()
        }
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: _tracks.map((track) {
        return TableRow(
          children: [
            NetworkImageWidget(
              url: "/api/tracks/${track.id}/cover?quality=64",
              width: 48,
              height: 48
            ),
            TrackListMainWidget(
              track: track,
              onTrackTapped: (BaseTrack track) {
                if (widget.onTrackTapped != null) {
                  widget.onTrackTapped!(track);
                }
              },
            ),
            if (!isMobile) ... [
              TrackListAlbumView(
                album: widget.albumId == null ? track.getAlbum() : null,
                trackNumber: widget.albumId != null ? track.getTrackNumber() : null,

              ),
              TrackListDurationView(
                duration: track.getDuration(),
              )
            ],
            TrackListActionView(
              track: track,
              playlistId: widget.playlistId,
              onTrackRemoved: (int trackId) {
                setState(() {
                  _tracks.removeWhere((t) => t.id == trackId);
                });
              }
            )
          ]
        );
      }).toList()
    );
  }
}