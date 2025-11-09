import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/dtos/id_name.dart';

import '../icon_text.dart';

class TrackListAlbumView extends StatelessWidget {

  final IdName? album;
  final int? trackNumber;

  const TrackListAlbumView({
    super.key,
    this.album,
    this.trackNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: album != null ? InkWell(
        onTap: () {
          GoRouter.of(context).push('/albums/${album!.id}');
        },
        child: Text(
          album!.name,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ) : trackNumber != null ? IconText(icon: Icons.numbers, text: trackNumber.toString()) : SizedBox.shrink(),
    );
  }
}