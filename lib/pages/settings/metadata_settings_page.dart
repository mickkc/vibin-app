import 'package:flutter/material.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/pages/settings/user_credentials_view.dart';

import '../../auth/auth_state.dart';
import '../../dtos/permission_type.dart';
import '../../main.dart';
import '../../widgets/settings/preferred_metadata_pickers.dart';
import '../../widgets/settings/settings_title.dart';

class MetadataSettingsPage extends StatelessWidget {

  const MetadataSettingsPage({ super.key });

  @override
  Widget build(BuildContext context) {
    final authState = getIt<AuthState>();
    final lm = AppLocalizations.of(context)!;
    return ListView(
      children: [
        SettingsTitle(
          title: lm.settings_app_metadata_title,
          icon: Icons.sell,
          heroTag: "settings-metadata",
        ),
        PreferredMetadataPickers(),

        if (authState.hasPermission(PermissionType.changeOwnUserSettings)) ... [
          const Divider(),
          const UserCredentialsView(),
        ]
      ],
    );
  }

}