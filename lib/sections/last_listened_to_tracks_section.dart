import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/sections/section_header.dart';
import 'package:vibin_app/widgets/entity_card.dart';
import 'package:vibin_app/widgets/future_content.dart';

import '../dtos/album/album.dart';
import '../dtos/artist/artist.dart';
import '../dtos/playlist/playlist.dart';
import '../dtos/track/minimal_track.dart';
import '../dtos/track/track.dart';

class LastListenedToSection extends StatelessWidget {
  const LastListenedToSection({super.key});

  @override
  Widget build(BuildContext context) {
    final apiManager = getIt<ApiManager>();
    final future = apiManager.service.getRecentListenedNonTrackItems(10);

    return Column(
      spacing: 8,
      children: [
        SectionHeader(
          title: AppLocalizations.of(context)!.section_recently_listened,
        ),
        FutureContent(
          height: 210,
          future: future,
          hasData: (d) => d.isNotEmpty,
          builder: (context, items) {
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final entity = items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: EntityCard(
                    entity: switch (entity.key) {
                      "ARTIST" => Artist.fromJson(entity.value),
                      "TRACK" => MinimalTrack.fromJson(entity.value),
                      "FTRACK" => Track.fromJson(entity.value),
                      "PLAYLIST" => Playlist.fromJson(entity.value),
                      "ALBUM" => Album.fromJson(entity.value),
                      _ => throw Exception("Unknown entity type: ${entity.key}")
                    },
                    type: entity.key,
                    coverSize: 128,
                  ),
                );
              },
              primary: false,
            );
          }
        )
      ]
    );
  }
}
