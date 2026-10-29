import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/dtos/metadata_fetch_type.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/utils/duration_converter.dart';
import 'package:vibin_app/widgets/future_content.dart';
import 'package:vibin_app/widgets/settings/server/server_boolean_settings_field.dart';
import 'package:vibin_app/widgets/settings/server/server_number_settings_field.dart';
import 'package:vibin_app/widgets/settings/server/server_string_settings_field.dart';
import 'package:vibin_app/widgets/settings/server/settings_string_dropdown_field.dart';
import 'package:vibin_app/widgets/settings/server/string_list_setting.dart';
import 'package:vibin_app/widgets/settings/settings_title.dart';

import '../../auth/auth_state.dart';
import '../../dtos/permission_type.dart';
import '../../l10n/app_localizations.dart';

class ServerSettingsPage extends StatefulWidget {
  const ServerSettingsPage({super.key});

  @override
  State<ServerSettingsPage> createState() => _ServerSettingsPageState();
}

class _ServerSettingsPageState extends State<ServerSettingsPage> {

  final _apiManager = getIt<ApiManager>();
  final _authState = getIt<AuthState>();

  late final _settingsFuture = _apiManager.service.getServerSettings();
  late final _lm = AppLocalizations.of(context)!;

  late final _providersFuture = _apiManager.service.getMetadataProviders();

  @override
  Widget build(BuildContext context) {
    return FutureContent(
      future: _settingsFuture,
      builder: (context, settings) {
        return SuperListView(
          children: [
            StringListSetting(
              setting: settings.settings["artist_name_delimiters"]!,
              title: _lm.settings_server_artist_seperator_title,
              description: _lm.settings_server_artist_seperator_description,
              itemBuilder: (context, seperator) {
                return SelectableText(seperator.replaceAll(" ", "␣"));
              },
            ),

            const Divider(),

            SettingsTitle(title: _lm.settings_server_metadata_title),

            ServerStringSettingsField(
              setting: settings.settings["metadata_language"]!,
              title: _lm.settings_server_metadata_language_title,
              description: _lm.settings_server_metadata_language_description,
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
              description: _lm.settings_server_metadata_extended_description,
              icon: Icons.info,
            ),

            const Divider(),

            ServerStringSettingsField(
              setting: settings.settings["spotify_client_id"]!,
              title: _lm.settings_server_spotify_client_id_title,
              description: _lm.settings_server_spotify_client_id_description,
              icon: Icons.devices,
            ),

            ServerStringSettingsField(
              setting: settings.settings["spotify_client_secret"]!,
              title: _lm.settings_server_spotify_client_secret_title,
              description: _lm.settings_server_spotify_client_secret_description,
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

            SettingsTitle(title: _lm.settings_server_parsing_title),

            ServerStringSettingsField(
              setting: settings.settings["lyric_file_path_template"]!,
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
                      setting: settings.settings["primary_metadata_source"]!,
                      title: _lm.settings_server_primary_metadata_source_title,
                      description: _lm.settings_server_primary_metadata_source_description,
                      icon: Icons.source,
                      options: providers.file + ["None"]
                    ),
                    ServerStringDropdownField(
                      setting: settings.settings["fallback_metadata_source"]!,
                      title: _lm.settings_server_secondary_metadata_source_title,
                      description: _lm.settings_server_secondary_metadata_source_description,
                      icon: Icons.source,
                      options: providers.file + ["None"]
                    ),

                    ServerBooleanSettingsField(
                      setting: settings.settings["add_genre_as_tag"]!,
                      title: _lm.settings_server_genre_as_tags_title,
                      description: _lm.settings_server_genre_as_tags_description,
                      icon: Icons.sell,
                    ),

                    const Divider(),

                    ServerStringDropdownField(
                      setting: settings.settings["artist_metadata_fetch_type"]!,
                      title: _lm.settings_server_artist_metadata_matching_type_title,
                      description: _lm.settings_server_artist_metadata_matching_type_description,
                      icon: Icons.filter_list,
                      options: MetadataFetchType.values,
                      itemFormatter: (type) => MetadataFetchType.format(type, _lm)
                    ),

                    ServerStringDropdownField(
                      setting: settings.settings["artist_metadata_source"]!,
                      title: _lm.settings_server_artist_metadata_provider_title,
                      description: _lm.settings_server_artist_metadata_provider_description,
                      icon: Icons.source,
                      options: providers.artist + ["None"]
                    ),

                    ServerStringDropdownField(
                      setting: settings.settings["album_metadata_fetch_type"]!,
                      title: _lm.settings_server_album_metadata_matching_type_title,
                      description: _lm.settings_server_album_metadata_matching_type_description,
                      icon: Icons.filter_list,
                      options: MetadataFetchType.values,
                      itemFormatter: (type) => MetadataFetchType.format(type, _lm)
                    ),

                    ServerStringDropdownField(
                      setting: settings.settings["album_metadata_source"]!,
                      title: _lm.settings_server_album_metadata_provider_title,
                      description: _lm.settings_server_album_metadata_provider_description,
                      icon: Icons.source,
                      options: providers.album + ["None"]
                    ),

                    ServerStringDropdownField(
                      setting: settings.settings["lyrics_metadata_source"]!,
                      title: _lm.settings_server_lyrics_metadata_provider_title,
                      description: _lm.settings_server_lyrics_metadata_provider_description,
                      icon: Icons.source,
                      options: providers.lyrics + ["None"]
                    )
                  ],
                );
              }
            ),

            const Divider(),

            SettingsTitle(title: _lm.settings_server_uploads_title),

            ServerStringSettingsField(
              setting: settings.settings["upload_path"]!,
              title: _lm.settings_server_uploads_path_template_title,
              description: _lm.settings_server_uploads_path_template_description,
              icon: Icons.upload_file,
            ),

            const Divider(),

            SettingsTitle(title: _lm.settings_server_security_title),

            ServerNumberSettingsField<int>(
              setting: settings.settings["session_expiration_validity"]!,
              title: _lm.settings_server_security_session_expiration_title,
              description: _lm.settings_server_security_session_expiration_description,
              icon: Icons.security,
              parser: (str) => DurationConverter.parseDuration(str),
              formatter: (int num) => DurationConverter.formatDurationFull(num),
              errorMessage: _lm.settings_server_security_session_expiration_parsing_error,
            ),

            ServerNumberSettingsField<int>(
              setting: settings.settings["login_notification_validity"]!,
              title: _lm.settings_server_security_login_notification_validity_title,
              description: _lm.settings_server_security_login_notification_validity_description,
              icon: Icons.mail_lock,
              parser: (str) => DurationConverter.parseDuration(str),
              formatter: (int num) => DurationConverter.formatDurationFull(num),
              errorMessage: _lm.settings_server_security_login_notification_validity_parsing_error,
            ),

            ServerBooleanSettingsField(
              setting: settings.settings["include_ip_in_login_notification"]!,
              title: _lm.settings_server_security_ip_in_login_notification_title,
              description: _lm.settings_server_security_ip_in_login_notification_desc,
              icon: Icons.onetwothree
            ),

            ServerBooleanSettingsField(
              setting: settings.settings["include_location_in_login_notification"]!,
              title: _lm.settings_server_security_location_in_login_notification_title,
              description: _lm.settings_server_security_location_in_login_notification_desc,
              icon: Icons.location_pin
            ),

            ServerNumberSettingsField<int>(
              setting: settings.settings["totp_mail_expiration_validity"]!,
              title: _lm.settings_server_security_totp_mail_validity_title,
              description: _lm.settings_server_security_totp_mail_validity_desc,
              icon: Icons.mark_email_read,
              parser: (str) => DurationConverter.parseDuration(str),
              formatter: (int num) => DurationConverter.formatDurationFull(num),
              errorMessage: _lm.settings_server_security_login_notification_validity_parsing_error,
            ),

            const Divider(),

            SettingsTitle(title: _lm.settings_server_misc_title),

            if (_authState.hasPermission(PermissionType.manageTasks))
              ListTile(
                leading: const Icon(Icons.refresh),
                title: Text(_lm.settings_app_manage_tasks_title),
                subtitle: Text(_lm.settings_app_manage_tasks_description),
                onTap: () {
                  GoRouter.of(context).push("/tasks");
                },
              ),

            StringListSetting(
              setting: settings.settings["welcome_texts"]!,
              title: _lm.settings_server_welcome_messages_title,
              description: _lm.settings_server_welcome_messages_description,
            ),
          ],
        );
      }
    );
  }
}