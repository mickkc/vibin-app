import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vibin_app/sections/section_header.dart';
import 'package:vibin_app/widgets/entity_card.dart';
import 'package:vibin_app/widgets/entity_card_row.dart';
import 'package:vibin_app/widgets/future_content.dart';

import '../api/api_manager.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';

class SimilarTracksSection extends StatelessWidget {

  final int trackId;

  SimilarTracksSection({
    super.key,
    required this.trackId
  });

  final _apiManager = getIt<ApiManager>();
  late final _tracks = _apiManager.service.getSimilarTracks(trackId, 20);

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      children: [
        SectionHeader(
          title: AppLocalizations.of(context)!.section_similar_tracks
        ),
        FutureContent(
          future: _tracks,
          height: 205,
          hasData: (tracks) => tracks.isNotEmpty,
          builder: (context, tracks) {
            return EntityCardRow(
              entities: tracks,
              type: EntityCardType.track,
            );
          }
        )
      ],
    );
  }
}