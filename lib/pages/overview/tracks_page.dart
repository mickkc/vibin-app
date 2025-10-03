import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/settings/setting_definitions.dart';
import 'package:vibin_app/settings/settings_manager.dart';
import 'package:vibin_app/widgets/paginated_overview.dart';

import '../../l10n/app_localizations.dart';

class TrackPage extends StatelessWidget {

  TrackPage({super.key});

  final SettingsManager settingsManager = getIt<SettingsManager>();

  @override
  Widget build(BuildContext context) {
    final ApiManager apiManager = getIt<ApiManager>();
    return PaginatedOverview(
      fetchFunction: (page, pageSize, query) {
        return apiManager.service.searchTracks(query, settingsManager.get(Settings.advancedTrackSearch), page, pageSize);
      },
      type: "TRACK",
      title: AppLocalizations.of(context)!.tracks,
      icon: Icons.library_music
    );
  }
}