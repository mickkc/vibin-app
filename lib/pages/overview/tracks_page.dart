import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/settings/setting_definitions.dart';
import 'package:vibin_app/settings/settings_manager.dart';
import 'package:vibin_app/widgets/overview/paginated_overview.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/entity_card.dart';

class TrackPage extends StatelessWidget {

  TrackPage({super.key});

  final _settingsManager = getIt<SettingsManager>();
  final _apiManager = getIt<ApiManager>();

  @override
  Widget build(BuildContext context) {
    return PaginatedOverview(
      fetchFunction: (page, pageSize, query) {
        return _apiManager.service.searchTracks(query, _settingsManager.get(Settings.advancedTrackSearch), page, pageSize);
      },
      type: EntityCardType.track,
      title: AppLocalizations.of(context)!.tracks,
      icon: Icons.library_music
    );
  }
}