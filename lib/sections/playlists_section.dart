import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vibin_app/sections/section_header.dart';
import 'package:vibin_app/widgets/entity_card.dart';
import 'package:vibin_app/widgets/entity_card_row.dart';
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
          hasData: (data) => data.isNotEmpty,
          builder: (context, playlists) {
            return EntityCardRow(entities: playlists, type: EntityCardType.playlist);
          }
        )
      ],
    );
  }
}