import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vibin_app/l10n/app_localizations.dart';

import 'package:vibin_app/discord/discord.dart';
import 'package:vibin_app/discord/rpc_updater.dart';
import 'package:vibin_app/pages/column_page.dart';
import '../../settings/setting_definitions.dart';
import '../../widgets/settings/bool_settings_field.dart';
import '../../widgets/settings/enum_settings_field.dart';
import '../../widgets/settings/settings_title.dart';
import '../../widgets/settings/string_settings_field.dart';

class IntegrationSettingsPage extends StatelessWidget {

  const IntegrationSettingsPage({ super.key });

  @override
  Widget build(BuildContext context) {

    final lm = AppLocalizations.of(context)!;

    return ColumnPage(
      spacing: 0,
      children: [
        SettingsTitle(
          title: lm.settings_app_integrations_title,
          icon: Icons.cable,
          heroTag: "settings-integrations",
        ),


        if (DiscordRPC.isAvailable) ... [
          SettingsTitle(
            title: lm.settings_app_discord_rpc_title,
          ),


          StreamBuilder(
            stream: RpcUpdater.instance.connectedStream,
            initialData: RpcUpdater.instance.connected,
            builder: (context, snapshot) {
              switch (snapshot.data) {
                case true:
                  return ListTile(
                  leading: const Icon(Icons.check),
                  title: Text(lm.settings_app_discord_rpc_connected_title, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                  subtitle: Text(lm.settings_app_discord_rpc_connected_subtitle),
                  );
                case false:
                  return ListTile(
                  leading: const Icon(Icons.close),
                  title: Text(lm.settings_app_discord_rpc_disconnected_title, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  subtitle: Text(lm.settings_app_discord_rpc_disconnected_subtitle),
                  );
                case null:
                  return SizedBox.shrink();
              }
            }
          ),

          BoolSettingsField(
            settingsKey: Settings.enableDiscordRpc,
            title: lm.settings_app_discord_rpc_enable_title,
            description: lm.settings_app_discord_rpc_enable_description,
            icon: Icons.discord,
            onChange: (enable) {
              if (enable) {
                RpcUpdater.instance.start();
              }
              else {
                RpcUpdater.instance.stop();
              }
            },
          ),

          StringSettingsField(
            settingsKey: Settings.stateTemplate,
            label: lm.settings_app_discord_rpc_state_template_title,
            description: lm.settings_app_discord_rpc_state_template_description,
            fieldWidth: 200,
            icon: Icons.title,
          ),

          StringSettingsField(
            settingsKey: Settings.detailTemplate,
            label:  lm.settings_app_discord_rpc_detail_template_title,
            description: lm.settings_app_discord_rpc_detail_template_description,
            fieldWidth: 200,
            icon: Icons.info,
          ),

          StringSettingsField(
            settingsKey: Settings.largeAssetTemplate,
            label: lm.settings_app_discord_rpc_large_asset_template_title,
            description: lm.settings_app_discord_rpc_large_asset_template_description,
            fieldWidth: 200,
            icon: Icons.image,
          ),

          StringSettingsField(
            settingsKey: Settings.smallAssetTemplate,
            label: lm.settings_app_discord_rpc_small_asset_template_title,
            description: lm.settings_app_discord_rpc_small_asset_template_description,
            fieldWidth: 200,
            icon: Icons.pause,
          ),

          EnumSettingsField(
            settingKey: Settings.displayType,
            title: lm.settings_app_discord_rpc_display_type_title,
            description: lm.settings_app_discord_rpc_display_type_description,
            optionLabel: (type) {
              switch (type) {
                case DiscordStatusDisplayType.name:
                  return lm.settings_app_discord_rpc_display_type_name;
                case DiscordStatusDisplayType.state:
                  return lm.settings_app_discord_rpc_display_type_state;
                case DiscordStatusDisplayType.details:
                  return lm.settings_app_discord_rpc_display_type_details;
              }
            },
            icon: Icons.label_important,
          ),

          if (!kIsWeb && Platform.isLinux) ...[
            const Divider(),
            BoolSettingsField(
              settingsKey: Settings.linuxEnableDbusMpris,
              title: lm.settings_app_enable_linux_dbus_integration_title,
              description: lm.settings_app_enable_linux_dbus_integration_description,
              icon: Icons.cable,
            ),
          ]
        ],
      ],
    );
  }
}