import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/widgets/fullscreen_box.dart';

import '../../api/api_manager.dart';
import '../../auth/AuthState.dart';
import '../../main.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = getIt<AuthState>();
    final apiManager = getIt<ApiManager>();
    final lm = AppLocalizations.of(context)!;
    return FullScreenBox(
      child: Center(
        child: ListView(
          children: [
            if (authState.hasPermission(PermissionType.manageOwnUser)) ... [
              ListTile(
                leading: Icon(Icons.person),
                title: Text(lm.settings_edit_profile),
                onTap: () {
                  GoRouter.of(context).push('/settings/profile');
                },
              )
            ],
            ListTile(
              leading: Icon(Icons.settings),
              title: Text(lm.settings_app_settings),
              onTap: () {
                GoRouter.of(context).push('/settings/app');
              },
            ),
            if (authState.hasPermission(PermissionType.changeServerSettings))... [
              ListTile(
                leading: Icon(Icons.electrical_services),
                title: Text(lm.settings_server_settings),
                onTap: () {
                  GoRouter.of(context).push('/settings/server');
                },
              )
            ],
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text(lm.settings_logout),
              onTap: () async {
                await apiManager.service.logout();
                authState.logout();
              },
            ),
          ],
        )
      ),
    );
  }
}