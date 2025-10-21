import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/settings/setting_definitions.dart';
import 'package:vibin_app/settings/settings_manager.dart';
import 'package:vibin_app/widgets/overview/paginated_overview.dart';

import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../widgets/entity_card.dart';

class AlbumPage extends StatefulWidget {
  const AlbumPage({super.key});

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {

  final _apiManager = getIt<ApiManager>();
  final SettingsManager _settingsManager = getIt<SettingsManager>();
  late final _lm = AppLocalizations.of(context)!;

  late bool _showSingles = _settingsManager.get(Settings.showSinglesInAlbumsByDefault);

  @override
  Widget build(BuildContext context) {
    return PaginatedOverview(
      key: Key("albums_overview_$_showSingles"), // Forces rebuild when toggling showSingles
      fetchFunction: (page, pageSize, query) {
        return _apiManager.service.getAlbums(page, pageSize, query, _showSingles);
      },
      type: EntityCardType.album,
      title: AppLocalizations.of(context)!.albums,
      icon: Icons.album,
      actions: [
        ElevatedButton.icon(
          icon: Icon(_showSingles ? Icons.album : Icons.library_music),
          label: Text(_showSingles ? _lm.albums_hide_singles : _lm.albums_show_singles),
          onPressed: () {
            setState(() {
              _showSingles = !_showSingles;
            });
          },
        ),
      ],
    );
  }
}