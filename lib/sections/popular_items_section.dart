import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vibin_app/sections/section_header.dart';
import 'package:vibin_app/widgets/entity_card_row.dart';
import 'package:vibin_app/widgets/future_content.dart';

import '../api/api_manager.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';

class PopularItemsSection extends StatelessWidget {
  const PopularItemsSection({super.key});

  @override
  Widget build(BuildContext context) {

    final apiManager = getIt<ApiManager>();
    final future = apiManager.service.getTopListenedGlobalNonTrackItems(20, null);

    return Column(
      spacing: 8,
      children: [
        SectionHeader(
          title: AppLocalizations.of(context)!.section_popular_items,
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