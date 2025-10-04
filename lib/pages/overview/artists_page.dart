import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/widgets/overview/paginated_overview.dart';

import '../../main.dart';

class ArtistsPage extends StatelessWidget {
  const ArtistsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ApiManager apiManager = getIt<ApiManager>();
    return PaginatedOverview(
      fetchFunction: (page, pageSize, query) {
        return apiManager.service.getArtists(page, pageSize, query);
      },
      type: "ARTIST",
      title: AppLocalizations.of(context)!.artists,
      icon: Icons.person,
    );
  }
}