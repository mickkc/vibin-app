import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/widgets/paginated_overview.dart';

import '../../main.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({super.key});

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {

  bool showOnlyOwn = true;

  @override
  Widget build(BuildContext context) {
    final lm = AppLocalizations.of(context)!;
    final ApiManager apiManager = getIt<ApiManager>();
    return Material(
      child: PaginatedOverview(
        key: Key("playlists_overview_$showOnlyOwn"), // Forces rebuild when toggling showOnlyOwn
        fetchFunction: (page, query) {
          return apiManager.service.getPlaylists(page, null, query, showOnlyOwn);
        },
        type: "PLAYLIST",
        title: AppLocalizations.of(context)!.playlists,
        icon: Icons.playlist_play,
        actions: [
          ElevatedButton.icon(
            icon: Icon(showOnlyOwn ? Icons.public : Icons.person),
            label: Text(showOnlyOwn ? lm.playlists_show_all : lm.playlists_show_owned),
            onPressed: () {
              setState(() {
                showOnlyOwn = !showOnlyOwn;
              });
            },
          ),
          ElevatedButton.icon(
            onPressed: () {
              GoRouter.of(context).push('/playlists/create');
            },
            label: Text(lm.playlists_create_new),
            icon: const Icon(Icons.add),
          )
        ],
      ),
    );
  }
}