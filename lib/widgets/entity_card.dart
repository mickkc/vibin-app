import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/widgets/network_image.dart';

import '../api/api_manager.dart';
import '../main.dart';

class EntityCard extends StatelessWidget {
  final EntityCardType type;
  final dynamic entity;
  final double coverSize;

  const EntityCard({
    super.key,
    required this.type,
    required this.entity,
    this.coverSize = 128,
  });

  String getTitle() {
    switch (type) {
      case EntityCardType.track:
      case EntityCardType.album:
        return entity.title;
      case EntityCardType.artist:
      case EntityCardType.playlist:
        return entity.name;
      case EntityCardType.user:
        return entity.displayName;
    }
  }

  String getDescription(BuildContext context) {
    switch (type) {
      case EntityCardType.track:
      case EntityCardType.album:
        return entity.artists.map((a) => a.name).join(", ");
      case EntityCardType.artist:
        return AppLocalizations.of(context)!.artist;
      case EntityCardType.playlist:
        return entity.description.isEmpty ? AppLocalizations.of(context)!.playlist : entity.description;
      case EntityCardType.user:
        return entity.username;
    }
  }

  String getCoverUrl(ApiManager apiManager) {
    switch (type) {
      case EntityCardType.track:
        return "/api/tracks/${entity.id}/cover?quality=large";
      case EntityCardType.album:
        return "/api/albums/${entity.id}/cover?quality=large";
      case EntityCardType.artist:
        return "/api/artists/${entity.id}/image?quality=large";
      case EntityCardType.playlist:
        return "/api/playlists/${entity.id}/image?quality=large";
      case EntityCardType.user:
        return "/api/users/${entity.id}/pfp?quality=large";
    }
  }

  void onTap(BuildContext context) {
    final route = switch (type) {
      EntityCardType.track => "/tracks/${entity.id}",
      EntityCardType.album => "/albums/${entity.id}",
      EntityCardType.artist => "/artists/${entity.id}",
      EntityCardType.playlist => "/playlists/${entity.id}",
      EntityCardType.user => "/users/${entity.id}"
    };
    GoRouter.of(context).push(route);
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
                AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: type == EntityCardType.artist || type == EntityCardType.user
                        ? BorderRadius.circular(coverSize / 2)
                        : BorderRadius.circular(8),
                    child: NetworkImageWidget(
                      url: getCoverUrl(apiManager),
                      width: coverSize,
                      height: coverSize,
                      fit: BoxFit.contain,
                    ),
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
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
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

enum EntityCardType {
  track,
  album,
  artist,
  playlist,
  user
}