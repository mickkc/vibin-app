import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/dtos/id_name.dart';

import '../network_image.dart';

class TrackListArtistView extends StatelessWidget {
  final List<IdName> artists;

  const TrackListArtistView({
    super.key,
    required this.artists,
  });

  static void showArtistPicker(BuildContext context, List<IdName> artists) {
    showModalBottomSheet(
      showDragHandle: true,
      isScrollControlled: false,
      enableDrag: true,
      useRootNavigator: true,
      context: context,
      constraints: BoxConstraints(
        maxWidth: 400,
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: artists.length,
            physics: const AlwaysScrollableScrollPhysics(),
            primary: false,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final artist = artists[index];
              return ListTile(
                leading: NetworkImageWidget(
                  url: "/api/artists/${artist.id}/image?quality=small",
                  width: 40,
                  height: 40,
                  borderRadius: BorderRadius.circular(20),
                  fit: BoxFit.cover,
                ),
                title: Text(artist.name),
                onTap: () {
                  Navigator.pop(context);
                  GoRouter.of(context).push('/artists/${artist.id}');
                },
              );
            },
          ),
        );
      }
    );
  }

  void _openArtist(BuildContext context) {
    if (artists.length == 1) {
      Navigator.pop(context);
      GoRouter.of(context).push('/artists/${artists.first.id}');
    } else {
      showArtistPicker(context, artists);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _openArtist(context);
      },
      child: Text(
        artists.map((e) => e.name).join(", "),
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}