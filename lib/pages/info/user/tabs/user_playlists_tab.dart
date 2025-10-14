import 'package:flutter/cupertino.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/widgets/entity_card.dart';
import 'package:vibin_app/widgets/entity_card_grid.dart';
import 'package:vibin_app/widgets/future_content.dart';

class UserPlaylistsTab extends StatelessWidget {
  final int userId;

  const UserPlaylistsTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {

    final apiManager = getIt<ApiManager>();
    final playlistsFuture = apiManager.service.getPlaylistsForUser(userId);

    return FutureContent(
      future: playlistsFuture,
      hasData: (d) => d.isNotEmpty,
      builder: (context, playlists) {
        return EntityCardGrid(
          items: playlists,
          type: EntityCardType.playlist
        );
      }
    );
  }
}