import 'package:flutter/cupertino.dart';
import 'package:vibin_app/dtos/user_activity.dart';
import 'package:vibin_app/sections/section_header.dart';
import 'package:vibin_app/widgets/entity_card.dart';
import 'package:vibin_app/widgets/future_content.dart';

import '../../../../api/api_manager.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../main.dart';

class UserActivityTab extends StatelessWidget {
  final int userId;

  UserActivityTab({super.key, required this.userId});

  final ApiManager apiManager = getIt<ApiManager>();
  late final Future<UserActivity> activityFuture = apiManager.service.getUserActivity(userId, null, null);

  @override
  Widget build(BuildContext context) {

    final lm = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Column(
        spacing: 16,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: lm.user_activity_last_tracks),
          FutureContent(
            future: activityFuture,
            hasData: (a) => a.recentTracks.isNotEmpty,
            height: 210,
            builder: (context, activity) {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: activity.recentTracks.length,
                itemBuilder: (context, index) {
                  final track = activity.recentTracks[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: EntityCard(
                      entity: track,
                      type: EntityCardType.track,
                    ),
                  );
                },
              );
            }
          ),

          SectionHeader(title: lm.user_activity_top_tracks),
          FutureContent(
            future: activityFuture,
            hasData: (a) => a.topTracks.isNotEmpty,
            height: 210,
            builder: (context, activity) {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: activity.topTracks.length,
                itemBuilder: (context, index) {
                  final track = activity.topTracks[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: EntityCard(
                      entity: track,
                      type: EntityCardType.track,
                    ),
                  );
                },
              );
            }
          ),

          SectionHeader(title: lm.user_activity_top_artists),
          FutureContent(
            future: activityFuture,
            hasData: (a) => a.topArtists.isNotEmpty,
            height: 210,
            builder: (context, activity) {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: activity.topArtists.length,
                itemBuilder: (context, index) {
                  final artist = activity.topArtists[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: EntityCard(
                      entity: artist,
                      type: EntityCardType.artist,
                    ),
                  );
                },
              );
            }
          ),
        ],
      ),
    );
  }
}