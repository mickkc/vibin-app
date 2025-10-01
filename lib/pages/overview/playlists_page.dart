import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/widgets/paginated_overview.dart';

import '../../main.dart';

class PlaylistsPage extends StatelessWidget {
  const PlaylistsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ApiManager apiManager = getIt<ApiManager>();
    return PaginatedOverview(
      fetchFunction: (page, query) {
        return apiManager.service.getPlaylists(page, null, query);
      },
      type: "PLAYLIST",
      title: AppLocalizations.of(context)!.playlists,
      icon: Icons.playlist_play,
    );
  }
}