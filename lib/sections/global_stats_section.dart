import 'package:flutter/material.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/sections/section_header.dart';

import '../api/api_manager.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../widgets/future_content.dart';

class GlobalStatsSection extends StatelessWidget {
  const GlobalStatsSection({super.key});

  Widget _statsCard(BuildContext context, String title, String value) {

    final theme = Theme.of(context);

    return Card(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          spacing: 4,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.primary),
            ),
            Text(
              title,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final apiManager = getIt<ApiManager>();
    final statsFuture = apiManager.service.getGlobalStats();
    final lm = AppLocalizations.of(context)!;

    return Column(
      spacing: 8,
      children: [
        SectionHeader(
          title: lm.section_global_stats
        ),
        FutureContent(
          future: statsFuture,
          builder: (context, stats) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  _statsCard(context, lm.tracks, stats.totalTracks.toString()),
                  _statsCard(context, lm.stats_total_tracks_duration, getDurationString(stats.totalTrackDuration)),
                  _statsCard(context, lm.artists, stats.totalArtists.toString()),
                  _statsCard(context, lm.albums, stats.totalAlbums.toString()),
                  _statsCard(context, lm.playlists, stats.totalPlaylists.toString()),
                  _statsCard(context, lm.users, stats.totalUsers.toString()),
                  _statsCard(context, lm.stats_total_plays, stats.totalPlays.toString()),
                ],
              ),
            );
          }
        )
      ],
    );
  }
}