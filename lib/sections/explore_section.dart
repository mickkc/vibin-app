import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vibin_app/sections/section_header.dart';
import 'package:vibin_app/widgets/entity_card.dart';
import 'package:vibin_app/widgets/future_content.dart';

import '../api/api_manager.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';

class ExploreSection extends StatelessWidget {
  const ExploreSection({super.key});

  @override
  Widget build(BuildContext context) {

    final apiManager = getIt<ApiManager>();
    final tracks = apiManager.service.getRandomTracks(20);

    return SizedBox(
      height: 255,
      child: Column(
        spacing: 8,
        children: [
          SectionHeader(
              title: AppLocalizations.of(context)!.section_random_tracks,
              viewAllRoute: "/tracks",
          ),
          Expanded(
            child: FutureContent(
              future: tracks,
              builder: (context, tracks) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: tracks.length,
                  itemBuilder: (context, index) {
                    final track = tracks[index];
                    return EntityCard(entity: track);
                  },
                  primary: false,
                );
              }
            )
          )
        ],
      ),
    );
  }
}