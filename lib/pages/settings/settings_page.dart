import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/pages/column_page.dart';
import 'package:vibin_app/pages/settings/settings_category_grid.dart';

import '../../auth/auth_state.dart';
import '../../discord/discord_stub.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../utils/dialogs.dart';

class SettingsPage extends StatefulWidget {

  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  final _authState = getIt<AuthState>();

  late final _lm = AppLocalizations.of(context)!;

  late final _userCategories = [
    AppSettingsCategory(
      _lm.settings_app_appearance_title,
      Icons.palette, "/settings/appearance",
      heroKey: "settings-appearance"
    ),
    AppSettingsCategory(
      _lm.settings_app_metadata_title,
      Icons.sell, "/settings/metadata",
      heroKey: "settings-metadata"
    ),
    AppSettingsCategory(
      _lm.settings_app_content_title,
      Icons.category, "/settings/content",
      heroKey: "settings-content",
      available: () => _authState.hasPermission(PermissionType.changeOwnUserSettings)
    ),
    AppSettingsCategory(
      _lm.settings_app_streaming_title,
      Icons.audio_file, "/settings/streaming",
      heroKey: "settings-streaming",
      available: () => _authState.hasPermission(PermissionType.streamTracks)
    ),
    AppSettingsCategory(
      _lm.settings_app_security_title,
      Icons.security, "/settings/security",
      heroKey: "settings-security",
      available: () => _authState.hasAnyPermission([PermissionType.manageOwn2fa, PermissionType.manageOwnUser])
    ),
    AppSettingsCategory(
      _lm.settings_app_integrations_title,
      Icons.cable, "/settings/integrations",
      heroKey: "settings-integrations",
      available: () => _authState.hasPermission(PermissionType.streamTracks) && ((!kIsWeb && Platform.isLinux) || DiscordRPC.isAvailable)
    ),
    AppSettingsCategory(
      _lm.settings_app_manage_sessions_title,
      Icons.manage_accounts, "/settings/sessions",
      heroKey: "settings-sessions",
      available: () => _authState.hasPermission(PermissionType.manageSessions)
    ),
    AppSettingsCategory(
      _lm.settings_app_manage_widgets_title,
      Icons.widgets, "/settings/widgets",
      heroKey: "settings-widgets",
      available: () => _authState.hasPermission(PermissionType.manageWidgets)
    ),
    AppSettingsCategory(
      _lm.settings_scrobbling_title,
      Icons.bar_chart, "/settings/scrobbling",
      heroKey: "settings-scrobbling",
      available: () => _authState.hasPermission(PermissionType.manageScrobbling)
    ),
  ].where((c) => c.isAvailable()).toList();

  late final _serverCategories = [
    AppSettingsCategory(
      _lm.settings_app_metadata_title,
      Icons.sell, "/settings/server/metadata",
      heroKey: "settings-server-metadata"
    ),
    AppSettingsCategory(
      _lm.settings_app_security_title,
      Icons.security, "/settings/server/security",
      heroKey: "settings-server-security"
    ),
    AppSettingsCategory(
      _lm.settings_app_manage_tasks_title,
      Icons.refresh, "/settings/server/tasks",
      heroKey: "settings-server-tasks",
      available: () => _authState.hasPermission(PermissionType.manageTasks)
    ),
    AppSettingsCategory(
      _lm.settings_server_uploads_title,
      Icons.upload, "/settings/server/uploads",
      heroKey: "settings-server-uploads",
    ),
    AppSettingsCategory(
      _lm.settings_server_misc_title,
      Icons.miscellaneous_services, "/settings/server/misc",
      heroKey: "settings-server-misc",
    ),
  ].where((c) => c.isAvailable()).toList();

  @override
  Widget build(BuildContext context) {
    return ColumnPage(
      spacing: 0,
      children: [
        Text(
          _lm.settings_app_title,
          style: TextTheme.of(context).headlineLarge,
        ),

        SettingsCategoryGrid(categories: _userCategories),

        if (_authState.hasPermission(PermissionType.changeServerSettings)) ... [
          SizedBox(height: 16),

          Text(
            _lm.settings_server_title,
            style: TextTheme.of(context).headlineLarge,
          ),

          SettingsCategoryGrid(categories: _serverCategories),
        ],

        const Divider(),

        ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(_lm.settings_app_about_title),
          subtitle: Text(_lm.settings_app_about_description),
          onTap: () => Dialogs.showAboutAppDialog(context),
        )
      ],
    );
  }
}