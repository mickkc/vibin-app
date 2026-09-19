import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/audio/audio_manager.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/dtos/shuffle_state.dart';
import 'package:vibin_app/widgets/bars/action_bar_play_button.dart';
import 'package:vibin_app/widgets/entity_card.dart';
import 'package:vibin_app/widgets/favorite_icon_button.dart';

import '../../audio/audio_type.dart';
import '../../auth/auth_state.dart';
import '../../main.dart';

class AlbumActionBar extends StatefulWidget {
  final int albumId;
  final ShuffleState? shuffleState;

  const AlbumActionBar({
    super.key,
    required this.albumId,
    this.shuffleState,
  });

  @override
  State<AlbumActionBar> createState() => _AlbumActionBarState();
}

class _AlbumActionBarState extends State<AlbumActionBar> {

  late final _audioManager = getIt<AudioManager>();
  late final _apiManager = getIt<ApiManager>();
  late final _authState = getIt<AuthState>();

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (_authState.hasPermission(PermissionType.streamTracks))
          ActionBarPlayButton(
            audioType: AudioType.album,
            audioId: widget.albumId,
            shuffleState: widget.shuffleState,
            onPlay: (shuffle) async {
              final album = await _apiManager.service.getAlbum(widget.albumId);
              _audioManager.playAlbumData(album, shuffle: shuffle);
            }
          ),
        if (_authState.hasPermission(PermissionType.manageAlbums))
          IconButton(
            onPressed: () {
              GoRouter.of(context).push("/albums/${widget.albumId}/edit");
            },
            icon: const Icon(Icons.edit, size: 32),
          ),
        if (_authState.hasPermission(PermissionType.manageOwnUser))
          FavoriteIconButton(
            type: EntityCardType.album,
            entityId: widget.albumId,
          )
      ],
    );
  }
}