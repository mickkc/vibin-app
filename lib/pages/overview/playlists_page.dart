import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/settings/setting_definitions.dart';
import 'package:vibin_app/settings/settings_manager.dart';
import 'package:vibin_app/widgets/overview/paginated_overview.dart';

import '../../main.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({super.key});

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {

  final SettingsManager settingsManager = getIt<SettingsManager>();
  final ApiManager apiManager = getIt<ApiManager>();
  late final AppLocalizations lm = AppLocalizations.of(context)!;
  late bool showOnlyOwn = settingsManager.get(Settings.showOwnPlaylistsByDefault);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: PaginatedOverview(
        key: Key("playlists_overview_$showOnlyOwn"), // Forces rebuild when toggling showOnlyOwn
        fetchFunction: (page, pageSize, query) {
          return apiManager.service.getPlaylists(page, pageSize, query, showOnlyOwn);
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