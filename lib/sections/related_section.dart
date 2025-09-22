import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vibin_app/sections/section_header.dart';
import 'package:vibin_app/widgets/entity_card.dart';
import 'package:vibin_app/widgets/future_content.dart';

import '../api/api_manager.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';

class RelatedSection extends StatelessWidget {

  final int trackId;

  const RelatedSection({
    super.key,
    required this.trackId
  });

  @override
  Widget build(BuildContext context) {

    final apiManager = getIt<ApiManager>();
    final tracks = apiManager.service.getRelatedTracks(trackId, 20);

    return Column(
      spacing: 8,
      children: [
        SectionHeader(
            title: AppLocalizations.of(context)!.section_related_tracks
        ),
        FutureContent(
          future: tracks,
          height: 215,
          hasData: (tracks) => tracks.isNotEmpty,
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
      ],
    );
  }
}