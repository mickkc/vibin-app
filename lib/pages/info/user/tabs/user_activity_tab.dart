import 'package:flutter/material.dart';
import 'package:vibin_app/sections/section_header.dart';
import 'package:vibin_app/widgets/entity_card.dart';
import 'package:vibin_app/widgets/entity_card_row.dart';
import 'package:vibin_app/widgets/future_content.dart';

import '../../../../api/api_manager.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../main.dart';

class UserActivityTab extends StatelessWidget {
  final int userId;

  UserActivityTab({super.key, required this.userId});

  final _apiManager = getIt<ApiManager>();
  late final _activityFuture = _apiManager.service.getUserActivity(userId, null, null);

  @override
  Widget build(BuildContext context) {

    final lm = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: FutureContent(
        future: _activityFuture,
        hasData: (a) => a.recentTracks.isNotEmpty || a.topTracks.isNotEmpty || a.topArtists.isNotEmpty,
        errorWidget: Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.visibility_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            Text(
              lm.user_activity_private,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        builder: (context, activity) {
          return Column(
            spacing: 16,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: lm.user_activity_last_tracks),
              SizedBox(
                height: 205,
                child: EntityCardRow(
                  entities: activity.recentTracks,
                  type: EntityCardType.track,
                ),
              ),

              SectionHeader(title: lm.user_activity_top_tracks),
              SizedBox(
                height: 205,
                child: EntityCardRow(
                  entities: activity.topTracks,
                  type: EntityCardType.track,
                ),
              ),

              SectionHeader(title: lm.user_activity_top_artists),
              SizedBox(
                height: 205,
                child: EntityCardRow(
                  entities: activity.topArtists,
                  type: EntityCardType.artist,
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}