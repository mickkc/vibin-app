import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/widgets/future_content.dart';
import 'package:vibin_app/widgets/settings/server/server_boolean_settings_field.dart';
import 'package:vibin_app/widgets/settings/server/server_string_settings_field.dart';
import 'package:vibin_app/widgets/settings/server/settings_string_dropdown_field.dart';
import 'package:vibin_app/widgets/settings/server/string_list_setting.dart';
import 'package:vibin_app/widgets/settings/settings_title.dart';

import '../../l10n/app_localizations.dart';

class ServerSettingsPage extends StatefulWidget {
  const ServerSettingsPage({super.key});

  @override
  State<ServerSettingsPage> createState() => _ServerSettingsPageState();
}

class _ServerSettingsPageState extends State<ServerSettingsPage> {

  final _apiManager = getIt<ApiManager>();
  late final _settingsFuture = _apiManager.service.getServerSettings();
  late final _lm = AppLocalizations.of(context)!;

  late final _providersFuture = _apiManager.service.getMetadataProviders();

  @override
  Widget build(BuildContext context) {
    return FutureContent(
      future: _settingsFuture,
      builder: (context, settings) {
        return ListView(
          children: [
            StringListSetting(
              settingKey: "artist_name_delimiters",
              initialValue: settings.settings["artist_name_delimiters"],
              title: _lm.settings_server_artist_seperator_title,
              description: _lm.settings_server_artist_seperator_description,
              itemBuilder: (context, seperator) {
                return SelectableText(seperator.replaceAll(" ", "␣"));
              },
            ),

            const Divider(),

            SettingsTitle(title: _lm.settings_server_metadata_title),

            ServerStringSettingsField(
              settingKey: "metadata_language",
              initialValue: settings.settings["metadata_language"],
              title: _lm.settings_server_metadata_language_title,
              description: _lm.settings_server_metadata_language_description,
              icon: Icons.translate,
            ),

            ServerStringSettingsField(
              settingKey: "spotify_client_id",
              initialValue: settings.settings["spotify_client_id"],
              title: _lm.settings_server_spotify_client_id_title,
              description: _lm.settings_server_spotify_client_id_description,
              icon: Icons.devices,
            ),

            ServerStringSettingsField(
              settingKey: "spotify_client_secret",
              initialValue: settings.settings["spotify_client_secret"],
              title: _lm.settings_server_spotify_client_secret_title,
              description: _lm.settings_server_spotify_client_secret_description,
              icon: Icons.key,
              isPassword: true,
            ),

            const Divider(),

            SettingsTitle(title: _lm.settings_server_parsing_title),

            ServerStringSettingsField(
              settingKey: "lyric_file_path_template",
              initialValue: settings.settings["lyric_file_path_template"],
              title: _lm.settings_server_lyrics_path_template_title,
              description: _lm.settings_server_lyrics_path_template_description,
              icon: Icons.lyrics,
            ),

            FutureContent(
              future: _providersFuture,
              builder: (context, providers) {
                return Column(
                  spacing: 8,
                  children: [
                    ServerStringDropdownField(
                      settingKey: "primary_metadata_source",
                      initialValue: settings.settings["primary_metadata_source"],
                      title: _lm.settings_server_primary_metadata_source_title,
                      description: _lm.settings_server_primary_metadata_source_description,
                      icon: Icons.source,
                      options: providers.file + ["None"]
                    ),
                    ServerStringDropdownField(
                      settingKey: "fallback_metadata_source",
                      initialValue: settings.settings["fallback_metadata_source"],
                      title: _lm.settings_server_secondary_metadata_source_title,
                      description: _lm.settings_server_secondary_metadata_source_description,
                      icon: Icons.source,
                      options: providers.file + ["None"]
                    )
                  ],
                );
              }
            ),

            ServerBooleanSettingsField(
              settingKey: "add_genre_as_tag",
              initialValue: settings.settings["add_genre_as_tag"],
              title: _lm.settings_server_genre_as_tags_title,
              description: _lm.settings_server_genre_as_tags_description,
              icon: Icons.sell,
            ),

            const Divider(),

            SettingsTitle(title: _lm.settings_server_uploads_title),

            ServerStringSettingsField(
              settingKey: "upload_path",
              initialValue: settings.settings["upload_path"],
              title: _lm.settings_server_uploads_path_template_title,
              description: _lm.settings_server_uploads_path_template_description,
              icon: Icons.upload_file,
            ),
          ],
        );
      }
    );
  }
}