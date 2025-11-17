import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/dialogs/add_track_to_playlist_dialog.dart';
import 'package:vibin_app/dtos/track/track.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/widgets/icon_text.dart';
import 'package:vibin_app/widgets/network_image.dart';

import '../api/api_manager.dart';
import '../audio/audio_manager.dart';
import '../main.dart';

class EntityCard extends StatelessWidget {
  final EntityCardType type;
  final dynamic entity;
  final double coverSize;
  final bool showActions;
  final Widget? badge;

  const EntityCard({
    super.key,
    required this.type,
    required this.entity,
    this.coverSize = 128,
    this.showActions = true,
    this.badge,
  });

  String _getTitle() {
    switch (type) {
      case EntityCardType.track:
      case EntityCardType.album:
        return entity.title;
      case EntityCardType.artist:
      case EntityCardType.playlist:
        return entity.name;
      case EntityCardType.user:
        return entity.displayName ?? entity.username;
    }
  }

  String _getDescription(BuildContext context) {
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

  int _getImageQuality(BuildContext context) {
    final ratio = MediaQuery.of(context).devicePixelRatio;
    return (coverSize * ratio).ceil();
  }

  String _getCoverUrl(BuildContext context, ApiManager apiManager) {
    switch (type) {
      case EntityCardType.track:
        return "/api/tracks/${entity.id}/cover?quality=${_getImageQuality(context)}";
      case EntityCardType.album:
        return "/api/albums/${entity.id}/cover?quality=${_getImageQuality(context)}";
      case EntityCardType.artist:
        return "/api/artists/${entity.id}/image?quality=${_getImageQuality(context)}";
      case EntityCardType.playlist:
        return "/api/playlists/${entity.id}/image?quality=${_getImageQuality(context)}";
      case EntityCardType.user:
        return "/api/users/${entity.id}/pfp?quality=${_getImageQuality(context)}";
    }
  }

  void _onTap(BuildContext context) {
    final route = switch (type) {
      EntityCardType.track => "/tracks/${entity.id}",
      EntityCardType.album => "/albums/${entity.id}",
      EntityCardType.artist => "/artists/${entity.id}",
      EntityCardType.playlist => "/playlists/${entity.id}",
      EntityCardType.user => "/users/${entity.id}"
    };
    GoRouter.of(context).push(route);
  }

  Future<void> _showContextMenu(BuildContext context, Offset position) async {

    final lm = AppLocalizations.of(context)!;

    final selected = await showMenu<EntityCardAction>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: [
        if (type != EntityCardType.user && type != EntityCardType.artist) ... [
          PopupMenuItem(
            value: EntityCardAction.play,
            child: IconText(icon: Icons.play_arrow, text: lm.card_actions_play_now)
          ),
          PopupMenuItem(
            value: EntityCardAction.playNext,
            child: IconText(icon: Icons.skip_next, text: lm.card_actions_play_next)
          ),
          PopupMenuItem(
            value: EntityCardAction.addToQueue,
            child: IconText(icon: Icons.queue_music, text: lm.card_actions_add_to_queue)
          ),
        ],
        if (type == EntityCardType.track)
          PopupMenuItem(
            value: EntityCardAction.addToPlaylist,
            child: IconText(icon: Icons.playlist_add, text: lm.card_actions_add_to_playlist)
          ),
        PopupMenuItem(
          value: EntityCardAction.viewInfo,
          child: IconText(icon: Icons.info, text: lm.card_actions_view_details)
        ),
      ]
    );
    
    if (selected == null || !context.mounted) return;
    
    switch (selected) {
      case EntityCardAction.play:
        await _play();
        break;
      case EntityCardAction.playNext:
        await _addToQueue(true);
        break;
      case EntityCardAction.addToQueue:
        await _addToQueue(false);
        break;
      case EntityCardAction.addToPlaylist:
        AddTrackToPlaylistDialog.show(entity.id, context);
        break;
      case EntityCardAction.viewInfo:
        _onTap(context);
        break;
    }
  }

  Future<void> _play() async {

    final audioManager = getIt<AudioManager>();

    await switch (type) {
      EntityCardType.track => entity is Track ? audioManager.playTrack(entity) : audioManager.playMinimalTrack(entity),
      EntityCardType.album => audioManager.playAlbum(entity),
      EntityCardType.artist => throw UnimplementedError("Playing artist not implemented"), // TODO: implement playing artist
      EntityCardType.playlist => audioManager.playPlaylist(entity),
      EntityCardType.user => throw UnimplementedError("Playing user not implemented"),
    };
  }
  
  Future<void> _addToQueue(bool first) async {

    final audioManager = getIt<AudioManager>();

    await switch (type) {
      EntityCardType.track => entity is Track ? audioManager.addTrackToQueue(entity, first) : audioManager.addMinimalTrackToQueue(entity, first),
      EntityCardType.album => audioManager.addAlbumToQueue(entity, first),
      EntityCardType.artist => throw UnimplementedError("Adding artist not implemented"), // TODO: implement adding artist
      EntityCardType.playlist => audioManager.addPlaylistToQueue(entity, first),
      EntityCardType.user => throw UnimplementedError("Adding user not implemented"),
    };
  }

  @override
  Widget build(BuildContext context) {
    final apiManager = getIt<ApiManager>();

    return InkWell(
      onTap: () => _onTap(context),
      onSecondaryTapDown: (details) => _showContextMenu(context, details.globalPosition),
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
                    child: Stack(
                      children: [
                        NetworkImageWidget(
                          url: _getCoverUrl(context, apiManager),
                          width: coverSize,
                          height: coverSize,
                          fit: BoxFit.contain,
                        ),
                        if (badge != null)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: badge!,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _getTitle(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1
                ),
                const SizedBox(height: 2),
                Text(
                  _getDescription(context),
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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

enum EntityCardAction {
  play,
  playNext,
  addToQueue,
  addToPlaylist,
  viewInfo,
}