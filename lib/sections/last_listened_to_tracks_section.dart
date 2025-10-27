import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/sections/section_header.dart';
import 'package:vibin_app/widgets/entity_card_row.dart';
import 'package:vibin_app/widgets/future_content.dart';

class LastListenedToSection extends StatelessWidget {
  const LastListenedToSection({super.key});

  @override
  Widget build(BuildContext context) {
    final apiManager = getIt<ApiManager>();
    final future = apiManager.service.getRecentListenedNonTrackItems(10);

    return Column(
      spacing: 8,
      children: [
        SectionHeader(
          title: AppLocalizations.of(context)!.section_recently_listened,
        ),
        FutureContent(
          height: 205,
          future: future,
          hasData: (d) => d.isNotEmpty,
          builder: (context, items) {
            return NonTrackEntityCardRow(entities: items);
          }
        )
      ]
    );
  }
}
