import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/widgets/overview/paginated_overview.dart';

import '../../auth/auth_state.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/entity_card.dart';

class UsersPage extends StatelessWidget {

  UsersPage({super.key});

  final _apiManager = getIt<ApiManager>();
  final _authState = getIt<AuthState>();

  @override
  Widget build(BuildContext context) {

    final lm = AppLocalizations.of(context)!;

    return PaginatedOverview(
      fetchFunction: (page, pageSize, query) {
        return _apiManager.service.getUsers(page, pageSize, query);
      },
      type: EntityCardType.user,
      title: lm.users,
      icon: Icons.group,
      actions: [
        if (_authState.hasPermission(PermissionType.createUsers))
          ElevatedButton.icon(
            onPressed: () {
              GoRouter.of(context).push("/users/create");
            },
            label: Text(lm.users_create),
            icon: Icon(Icons.person_add),
          )
      ],
    );
  }
}