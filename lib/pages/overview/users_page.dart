import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/widgets/overview/paginated_overview.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/entity_card.dart';

class UsersPage extends StatelessWidget {

  UsersPage({super.key});

  final _apiManager = getIt<ApiManager>();

  @override
  Widget build(BuildContext context) {
    return PaginatedOverview(
      fetchFunction: (page, pageSize, query) {
        return _apiManager.service.getUsers(page, pageSize, query);
      },
      type: EntityCardType.user,
      title: AppLocalizations.of(context)!.users,
      icon: Icons.group,
    );
  }
}