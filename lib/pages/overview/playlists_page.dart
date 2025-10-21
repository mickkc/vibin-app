import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/settings/setting_definitions.dart';
import 'package:vibin_app/settings/settings_manager.dart';
import 'package:vibin_app/widgets/entity_card.dart';
import 'package:vibin_app/widgets/overview/paginated_overview.dart';

import '../../main.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({super.key});

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {

  final _settingsManager = getIt<SettingsManager>();
  final _apiManager = getIt<ApiManager>();
  late final _lm = AppLocalizations.of(context)!;
  late bool _showOnlyOwn = _settingsManager.get(Settings.showOwnPlaylistsByDefault);

  @override
  Widget build(BuildContext context) {
    return PaginatedOverview(
      key: Key("playlists_overview_$_showOnlyOwn"), // Forces rebuild when toggling showOnlyOwn
      fetchFunction: (page, pageSize, query) {
        return _apiManager.service.getPlaylists(page, pageSize, query, _showOnlyOwn);
      },
      type: EntityCardType.playlist,
      title: AppLocalizations.of(context)!.playlists,
      icon: Icons.playlist_play,
      actions: [
        ElevatedButton.icon(
          icon: Icon(_showOnlyOwn ? Icons.public : Icons.person),
          label: Text(_showOnlyOwn ? _lm.playlists_show_all : _lm.playlists_show_owned),
          onPressed: () {
            setState(() {
              _showOnlyOwn = !_showOnlyOwn;
            });
          },
        ),
        ElevatedButton.icon(
          onPressed: () {
            GoRouter.of(context).push('/playlists/create');
          },
          label: Text(_lm.playlists_create_new),
          icon: const Icon(Icons.add),
        )
      ],
    );
  }
}