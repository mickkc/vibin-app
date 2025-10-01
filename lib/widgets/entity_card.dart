import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/dtos/album/album.dart';
import 'package:vibin_app/dtos/playlist/playlist.dart';
import 'package:vibin_app/dtos/track/minimal_track.dart';
import 'package:vibin_app/dtos/track/track.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/widgets/network_image.dart';

import '../api/api_manager.dart';
import '../main.dart';

class EntityCard extends StatelessWidget {
  final String type;
  final dynamic entity;
  final double coverSize;

  const EntityCard({
    super.key,
    this.type = "TRACK",
    required this.entity,
    this.coverSize = 128,
  });

  String getTitle() {
    switch (type) {
      case "TRACK":
      case "FTRACK":
      case "ALBUM":
        return entity.title;
      case "ARTIST":
      case "PLAYLIST":
        return entity.name;
      default:
        return "INVALID TYPE";
    }
  }

  String getDescription(BuildContext context) {
    switch (type) {
      case "TRACK":
        return (entity as MinimalTrack).artists.map((a) => a.name).join(", ");
      case "FTRACK":
        return (entity as Track).artists.map((a) => a.name).join(", ");
      case "ALBUM":
        return (entity as Album).artists.map((a) => a.name).join(", ");
      case "ARTIST":
        return AppLocalizations.of(context)!.artist;
      case "PLAYLIST":
        return (entity as Playlist).description ?? AppLocalizations.of(context)!.playlist;
      default:
        return "INVALID TYPE";
    }
  }

  String getCoverUrl(ApiManager apiManager) {
    switch (type) {
      case "TRACK":
      case "FTRACK":
        return "/api/tracks/${entity.id}/cover?quality=large";
      case "ALBUM":
        return "/api/albums/${entity.id}/cover?quality=large";
      case "ARTIST":
        return "/api/artists/${entity.id}/image?quality=large";
      case "PLAYLIST":
        return "/api/playlists/${entity.id}/image?quality=large";
      default:
        throw Exception("INVALID TYPE");
    }
  }

  void onTap(BuildContext context) {
    final route = switch (type) {
      "TRACK" || "FTRACK" => "/tracks/${entity.id}",
      "ALBUM" => "/albums/${entity.id}",
      "ARTIST" => "/artists/${entity.id}",
      "PLAYLIST" => "/playlists/${entity.id}",
      _ => null
    };
    if (route != null) {
      GoRouter.of(context).push(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiManager = getIt<ApiManager>();

    return InkWell(
      onTap: () => onTap(context),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.surfaceContainerLow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: coverSize,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: type == "ARTIST"
                      ? BorderRadius.circular(coverSize / 2)
                      : BorderRadius.circular(8),
                  child: NetworkImageWidget(
                    url: getCoverUrl(apiManager),
                    width: coverSize,
                    height: coverSize,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  getTitle(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1
                ),
                const SizedBox(height: 2),
                Text(
                  getDescription(context),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
