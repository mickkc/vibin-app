import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/widgets/overview/paginated_overview.dart';

import '../../l10n/app_localizations.dart';
import '../../main.dart';

class AlbumPage extends StatelessWidget {
  const AlbumPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ApiManager apiManager = getIt<ApiManager>();
    return PaginatedOverview(
      fetchFunction: (page, pageSize, query) {
        return apiManager.service.getAlbums(page, pageSize, query);
      },
      type: "ALBUM",
      title: AppLocalizations.of(context)!.albums,
      icon: Icons.album
    );
  }
}