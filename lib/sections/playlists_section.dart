import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vibin_app/sections/section_header.dart';
import 'package:vibin_app/widgets/entity_card.dart';
import 'package:vibin_app/widgets/future_content.dart';

import '../api/api_manager.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';

class PlaylistsSection extends StatelessWidget {
  const PlaylistsSection({super.key});

  @override
  Widget build(BuildContext context) {

    final apiManager = getIt<ApiManager>();
    final playlistFuture = apiManager.service.getRandomPlaylists(20);

    return Column(
      spacing: 8,
      children: [
        SectionHeader(
            title: AppLocalizations.of(context)!.section_playlists,
            viewAllRoute: "/playlists",
        ),
        FutureContent(
          future: playlistFuture,
          height: 205,
          builder: (context, playlists) {
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final track = playlists[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: EntityCard(
                    entity: track,
                    type: EntityCardType.playlist,
                  ),
                );
              },
              primary: false,
            );
          }
        )
      ],
    );
  }
}