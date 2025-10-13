import 'package:flutter/material.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/sections/section_header.dart';
import 'package:vibin_app/widgets/entity_card.dart';
import 'package:vibin_app/widgets/future_content.dart';

import '../api/api_manager.dart';
import '../main.dart';

class MostListenedToArtistsSection extends StatelessWidget {
  const MostListenedToArtistsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final apiManager = getIt<ApiManager>();
    final artists = apiManager.service.getTopListenedArtists(10, 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        SectionHeader(
          title: AppLocalizations.of(context)!.section_top_artists,
          viewAllRoute: "/artists",
        ),
        FutureContent(
          height: 205,
          future: artists,
          hasData: (d) => d.isNotEmpty,
          builder: (context, artists) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: artists.length,
                    itemBuilder: (context, index) {
                      final artist = artists[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: EntityCard(
                          type: EntityCardType.artist,
                          entity: artist,
                          coverSize: 128,
                        ),
                      );
                    },
                    primary: false,
                  )
                )
              ]
            );
          }
        )
      ]
    );
  }
}