import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/dialogs/add_track_to_playlist_dialog.dart';
import 'package:vibin_app/dtos/track/track.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/widgets/icon_text.dart';
import 'package:vibin_app/widgets/network_image.dart';

import '../audio/audio_manager.dart';
import '../main.dart';

class EntityCard extends StatefulWidget {
  final EntityCardType type;
  final dynamic entity;
  final double coverSize;
  final bool showActions;
  final Widget? badge;
  final Function? onTap;
  final String? overrideTitle;
  final String? overrideDescription;
  final VoidCallback? onNavigate;

  const EntityCard({
    super.key,
    required this.type,
    required this.entity,
    this.coverSize = 128,
    this.showActions = true,
    this.badge,
    this.onTap,
    this.overrideTitle,
    this.overrideDescription,
    this.onNavigate,
  });

  @override
  State<EntityCard> createState() => _EntityCardState();
}

class _EntityCardState extends State<EntityCard> {
  late String _coverUrl;

  @override
  void initState() {
    super.initState();
    _coverUrl = _getCoverUrl();
  }

  String _getTitle() {
    if (widget.overrideTitle != null) {
      return widget.overrideTitle!;
    }

    switch (widget.type) {
      case EntityCardType.track:
      case EntityCardType.album:
        return widget.entity.title;
      case EntityCardType.artist:
      case EntityCardType.playlist:
        return widget.entity.name;
      case EntityCardType.user:
        return widget.entity.displayName ?? widget.entity.username;
    }
  }

  String _getDescription(BuildContext context) {
    if (widget.overrideDescription != null) {
      return widget.overrideDescription!;
    }

    switch (widget.type) {
      case EntityCardType.track:
      case EntityCardType.album:
        return widget.entity.artists.map((a) => a.name).join(", ");
      case EntityCardType.artist:
        return AppLocalizations.of(context)!.artist;
      case EntityCardType.playlist:
        return widget.entity.description.isEmpty ? AppLocalizations.of(context)!.playlist : widget.entity.description;
      case EntityCardType.user:
        return widget.entity.username;
    }
  }

  int _getImageQuality() {
    final ratio = WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    return (widget.coverSize * ratio).ceil();
  }

  String _getCoverUrl() {
    final quality = _getImageQuality();
    switch (widget.type) {
      case EntityCardType.track:
        return "/api/tracks/${widget.entity.id}/cover?quality=$quality";
      case EntityCardType.album:
        return "/api/albums/${widget.entity.id}/cover?quality=$quality";
      case EntityCardType.artist:
        return "/api/artists/${widget.entity.id}/image?quality=$quality";
      case EntityCardType.playlist:
        return "/api/playlists/${widget.entity.id}/image?quality=$quality";
      case EntityCardType.user:
        return "/api/users/${widget.entity.id}/pfp?quality=$quality";
    }
  }

  void _onTap(BuildContext context) {
    final route = switch (widget.type) {
      EntityCardType.track => "/tracks/${widget.entity.id}",
      EntityCardType.album => "/albums/${widget.entity.id}",
      EntityCardType.artist => "/artists/${widget.entity.id}",
      EntityCardType.playlist => "/playlists/${widget.entity.id}",
      EntityCardType.user => "/users/${widget.entity.id}"
    };
    GoRouter.of(context).push(route);
    widget.onNavigate?.call();
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
        if (widget.type != EntityCardType.user && widget.type != EntityCardType.artist) ... [
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
        if (widget.type == EntityCardType.track)
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
        AddTrackToPlaylistDialog.show(context, widget.entity.id);
        break;
      case EntityCardAction.viewInfo:
        _onTap(context);
        break;
    }
  }

  Future<void> _play() async {

    final audioManager = getIt<AudioManager>();

    await switch (widget.type) {
      EntityCardType.track => widget.entity is Track ? audioManager.playTrack(widget.entity) : audioManager.playMinimalTrack(widget.entity),
      EntityCardType.album => audioManager.playAlbum(widget.entity),
      EntityCardType.artist => throw UnimplementedError("Playing artist not implemented"), // TODO: implement playing artist
      EntityCardType.playlist => audioManager.playPlaylist(widget.entity),
      EntityCardType.user => throw UnimplementedError("Playing user not implemented"),
    };
  }

  Future<void> _addToQueue(bool first) async {

    final audioManager = getIt<AudioManager>();

    await switch (widget.type) {
      EntityCardType.track => widget.entity is Track ? audioManager.addTrackToQueue(widget.entity, first) : audioManager.addMinimalTrackToQueue(widget.entity, first),
      EntityCardType.album => audioManager.addAlbumToQueue(widget.entity, first),
      EntityCardType.artist => throw UnimplementedError("Adding artist not implemented"), // TODO: implement adding artist
      EntityCardType.playlist => audioManager.addPlaylistToQueue(widget.entity, first),
      EntityCardType.user => throw UnimplementedError("Adding user not implemented"),
    };
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap != null ? () => widget.onTap!() : () => _onTap(context),
      onSecondaryTapDown: widget.onTap != null ? null : (details) => _showContextMenu(context, details.globalPosition),
      onLongPress: widget.onTap != null ? null : () {
        final box = context.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset(box.size.width / 2, box.size.height / 2));
        _showContextMenu(context, position);
      },
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.surfaceContainerLow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: widget.coverSize,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: widget.type == EntityCardType.artist || widget.type == EntityCardType.user
                            ? BorderRadius.circular(widget.coverSize / 2)
                            : BorderRadius.circular(8),
                        child: NetworkImageWidget(
                          url: _coverUrl,
                          width: widget.coverSize,
                          height: widget.coverSize,
                          fit: BoxFit.contain,
                        ),
                      ),
                      if (widget.badge != null)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: widget.badge!,
                        ),
                    ],
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