import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/settings/setting_definitions.dart';
import 'package:vibin_app/settings/settings_manager.dart';
import 'package:vibin_app/widgets/overview/paginated_overview.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/entity_card.dart';

class TrackPage extends StatelessWidget {

  const TrackPage({super.key});

  @override
  Widget build(BuildContext context) {

    final settingsManager = getIt<SettingsManager>();
    final apiManager = getIt<ApiManager>();

    final parameters = GoRouterState.of(context).uri.queryParameters;

    return PaginatedOverview(
      fetchFunction: (page, pageSize, query) {
        final overrideAdvancedSearch = parameters['advanced'];
        return apiManager.service.searchTracks(
          query,
          overrideAdvancedSearch != null
            ? bool.parse(overrideAdvancedSearch)
            : settingsManager.get(Settings.advancedTrackSearch),
          page,
          pageSize
        );
      },
      type: EntityCardType.track,
      title: AppLocalizations.of(context)!.tracks,
      icon: Icons.library_music,
      initialSearchQuery: parameters['search'],
    );
  }
}