import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/settings/setting_definitions.dart';
import 'package:vibin_app/settings/settings_manager.dart';
import 'package:vibin_app/widgets/overview/paginated_overview.dart';

import '../../l10n/app_localizations.dart';
import '../../main.dart';

class AlbumPage extends StatefulWidget {
  const AlbumPage({super.key});

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {

  final ApiManager apiManager = getIt<ApiManager>();
  final SettingsManager settingsManager = getIt<SettingsManager>();
  late final lm = AppLocalizations.of(context)!;

  late bool showSingles = settingsManager.get(Settings.showSinglesInAlbumsByDefault);

  @override
  Widget build(BuildContext context) {
    final ApiManager apiManager = getIt<ApiManager>();
    return PaginatedOverview(
      key: Key("albums_overview_$showSingles"), // Forces rebuild when toggling showSingles
      fetchFunction: (page, pageSize, query) {
        return apiManager.service.getAlbums(page, pageSize, query, showSingles);
      },
      type: "ALBUM",
      title: AppLocalizations.of(context)!.albums,
      icon: Icons.album,
      actions: [
        ElevatedButton.icon(
          icon: Icon(showSingles ? Icons.album : Icons.library_music),
          label: Text(showSingles ? AppLocalizations.of(context)!.albums_hide_singles : AppLocalizations.of(context)!.albums_show_singles),
          onPressed: () {
            setState(() {
              showSingles = !showSingles;
            });
          },
        ),
      ],
    );
  }
}