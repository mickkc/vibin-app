import 'package:flutter/cupertino.dart';
import 'package:vibin_app/dtos/non_track_listen.dart';
import 'package:vibin_app/widgets/entity_card.dart';

import '../dtos/album/album.dart';
import '../dtos/artist/artist.dart';
import '../dtos/playlist/playlist.dart';
import '../dtos/track/minimal_track.dart';
import '../dtos/track/track.dart';

class EntityCardRow extends StatelessWidget {
  final List<dynamic> entities;
  final EntityCardType type;
  final VoidCallback? onNavigate;

  const EntityCardRow({
    super.key,
    required this.entities,
    required this.type,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: entities.length,
      itemBuilder: (context, index) {
        final entity = entities[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: EntityCard(
            entity: entity,
            type: type,
            onNavigate: onNavigate,
          ),
        );
      },
    );
  }
}

class NonTrackEntityCardRow extends StatelessWidget {
  final List<NonTrackListen> entities;

  const NonTrackEntityCardRow({
    super.key,
    required this.entities,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: entities.length,
      itemBuilder: (context, index) {
        final entity = entities[index];
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
            type: switch (entity.key) {
              "ARTIST" => EntityCardType.artist,
              "TRACK" => EntityCardType.track,
              "FTRACK" => EntityCardType.track,
              "PLAYLIST" => EntityCardType.playlist,
              "ALBUM" => EntityCardType.album,
              _ => throw Exception("Unknown entity type: ${entity.key}")
            },
            coverSize: 128,
          ),
        );
      }
    );
  }
}