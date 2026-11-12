import 'package:flutter/material.dart';
import 'package:vibin_app/pages/column_page.dart';

import '../../api/api_manager.dart';
import '../../dtos/metadata_fetch_type.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../widgets/future_content.dart';
import '../../widgets/settings/server/server_boolean_settings_field.dart';
import '../../widgets/settings/server/server_number_settings_field.dart';
import '../../widgets/settings/server/server_string_settings_field.dart';
import '../../widgets/settings/server/settings_string_dropdown_field.dart';
import '../../widgets/settings/server/string_list_setting.dart';
import '../../widgets/settings/settings_title.dart';

class ServerMetadataSettingsPage extends StatefulWidget {

  const ServerMetadataSettingsPage({ super.key });

  @override
  State<StatefulWidget> createState() => _ServerMetadataSettingsPageState();
}

class _ServerMetadataSettingsPageState extends State<ServerMetadataSettingsPage> {

  final _apiManager = getIt<ApiManager>();

  late final _settingsFuture = _apiManager.service.getServerSettings();
  late final _lm = AppLocalizations.of(context)!;

  late final _providersFuture = _apiManager.service.getMetadataProviders();

  @override
  Widget build(BuildContext context) {
    return ColumnPage(
      spacing: 0,
      children: [
        SettingsTitle(
          title: _lm.settings_server_metadata_title,
          icon: Icons.sell,
          heroTag: "settings-server-metadata",
        ),
        FutureContent(
          future: _settingsFuture,
          builder: (context, settings) {
            return ListView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [

                ServerStringSettingsField(
                  setting: settings.settings["metadata_language"]!,
                  title: _lm.settings_server_metadata_language_title,
                  description: _lm
                      .settings_server_metadata_language_description,
                  icon: Icons.translate,
                ),

                ServerNumberSettingsField<int>(
                  setting: settings.settings["metadata_limit"]!,
                  title: _lm.settings_server_metadata_limit_title,
                  description: _lm.settings_server_metadata_limit_description,
                  icon: Icons.format_list_numbered,
                  parser: int.parse,
                ),

                ServerBooleanSettingsField(
                  setting: settings.settings["extended_metadata"]!,
                  title: _lm.settings_server_metadata_extended_title,
                  description: _lm
                      .settings_server_metadata_extended_description,
                  icon: Icons.info,
                ),

                const Divider(),

                ServerStringSettingsField(
                  setting: settings.settings["spotify_client_id"]!,
                  title: _lm.settings_server_spotify_client_id_title,
                  description: _lm
                      .settings_server_spotify_client_id_description,
                  icon: Icons.devices,
                ),

                ServerStringSettingsField(
                  setting: settings.settings["spotify_client_secret"]!,
                  title: _lm.settings_server_spotify_client_secret_title,
                  description: _lm
                      .settings_server_spotify_client_secret_description,
                  icon: Icons.key,
                  isPassword: true,
                ),

                ServerStringSettingsField(
                  setting: settings.settings["lastfm_api_key"]!,
                  title: _lm.settings_server_lastfm_api_key_title,
                  description: _lm.settings_server_lastfm_api_key_description,
                  icon: Icons.key,
                  isPassword: true,
                ),

                const Divider(),

                StringListSetting(
                  setting: settings.settings["artist_name_delimiters"]!,
                  title: _lm.settings_server_artist_seperator_title,
                  description: _lm
                      .settings_server_artist_seperator_description,
                  itemBuilder: (context, seperator) {
                    return SelectableText(seperator.replaceAll(" ", "␣"));
                  },
                ),

                const Divider(),

                SettingsTitle(title: _lm.settings_server_parsing_title),

                ServerStringSettingsField(
                  setting: settings.settings["lyric_file_path_template"]!,
                  title: _lm.settings_server_lyrics_path_template_title,
                  description: _lm
                      .settings_server_lyrics_path_template_description,
                  icon: Icons.lyrics,
                ),

                FutureContent(
                    future: _providersFuture,
                    builder: (context, providers) {
                      return Column(
                        spacing: 8,
                        children: [
                          ServerStringDropdownField(
                              setting: settings
                                  .settings["primary_metadata_source"]!,
                              title: _lm
                                  .settings_server_primary_metadata_source_title,
                              description: _lm
                                  .settings_server_primary_metadata_source_description,
                              icon: Icons.source,
                              options: providers.file + ["None"]
                          ),
                          ServerStringDropdownField(
                              setting: settings
                                  .settings["fallback_metadata_source"]!,
                              title: _lm
                                  .settings_server_secondary_metadata_source_title,
                              description: _lm
                                  .settings_server_secondary_metadata_source_description,
                              icon: Icons.source,
                              options: providers.file + ["None"]
                          ),

                          ServerBooleanSettingsField(
                            setting: settings.settings["add_genre_as_tag"]!,
                            title: _lm.settings_server_genre_as_tags_title,
                            description: _lm
                                .settings_server_genre_as_tags_description,
                            icon: Icons.sell,
                          ),

                          ServerStringDropdownField(
                              setting: settings
                                  .settings["artist_metadata_fetch_type"]!,
                              title: _lm
                                  .settings_server_artist_metadata_matching_type_title,
                              description: _lm
                                  .settings_server_artist_metadata_matching_type_description,
                              icon: Icons.filter_list,
                              options: MetadataFetchType.values,
                              itemFormatter: (type) =>
                                  MetadataFetchType.format(type, _lm)
                          ),

                          ServerStringDropdownField(
                              setting: settings
                                  .settings["artist_metadata_source"]!,
                              title: _lm
                                  .settings_server_artist_metadata_provider_title,
                              description: _lm
                                  .settings_server_artist_metadata_provider_description,
                              icon: Icons.source,
                              options: providers.artist + ["None"]
                          ),

                          ServerStringDropdownField(
                              setting: settings
                                  .settings["album_metadata_fetch_type"]!,
                              title: _lm
                                  .settings_server_album_metadata_matching_type_title,
                              description: _lm
                                  .settings_server_album_metadata_matching_type_description,
                              icon: Icons.filter_list,
                              options: MetadataFetchType.values,
                              itemFormatter: (type) =>
                                  MetadataFetchType.format(type, _lm)
                          ),

                          ServerStringDropdownField(
                              setting: settings
                                  .settings["album_metadata_source"]!,
                              title: _lm
                                  .settings_server_album_metadata_provider_title,
                              description: _lm
                                  .settings_server_album_metadata_provider_description,
                              icon: Icons.source,
                              options: providers.album + ["None"]
                          ),

                          ServerStringDropdownField(
                              setting: settings
                                  .settings["lyrics_metadata_source"]!,
                              title: _lm
                                  .settings_server_lyrics_metadata_provider_title,
                              description: _lm
                                  .settings_server_lyrics_metadata_provider_description,
                              icon: Icons.source,
                              options: providers.lyrics + ["None"]
                          )
                        ],
                      );
                    }
                ),
              ]
            );
          }
        )
      ],
    );
  }
}