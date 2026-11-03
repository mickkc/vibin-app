import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/dtos/settings/setting.dart';
import 'package:vibin_app/dtos/settings/settings_map.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/widgets/future_content.dart';
import 'package:vibin_app/widgets/settings/server/server_string_settings_field.dart';
import 'package:vibin_app/widgets/settings/settings_title.dart';

class UserCredentialsView extends StatefulWidget {
  const UserCredentialsView({super.key});

  @override
  State<StatefulWidget> createState() => _UserCredentialsViewState();
}

class _UserCredentialsViewState extends State<UserCredentialsView> {

  final _apiManager = getIt<ApiManager>();

  late final _settingsFuture = _apiManager.service.getUserSettings();
  late final _lm = AppLocalizations.of(context)!;

  @override
  Widget build(BuildContext context) {
    return FutureContent(
      future: _settingsFuture,
      mockData: () {
        return SettingsMap(settings: {
          "spotify_user_client_id": Setting(key: "spotify_user_client_id", value: BoneMock.chars(32)),
          "spotify_user_client_secret": Setting(key: "spotify_user_client_secret", value: BoneMock.chars(32)),
          "lastfm_user_api_key": Setting(key: "lastfm_user_api_key", value: BoneMock.chars(32)),
          "lastfm_user_shared_secret": Setting(key: "lastfm_user_shared_secret", value: BoneMock.chars(32))
        });
      },
      builder: (context, settings) {
        return Column(
          spacing: 8,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsTitle(
              title: _lm.settings_app_credentials_title,
              subtitle: _lm.settings_app_credentials_description,
            ),
            ServerStringSettingsField(
              setting: settings.settings["spotify_user_client_id"]!,
              title: _lm.settings_server_spotify_client_id_title,
              description: _lm.settings_server_spotify_client_id_description,
              icon: Icons.devices,
            ),
            ServerStringSettingsField(
              setting: settings.settings["spotify_user_client_secret"]!,
              title: _lm.settings_server_spotify_client_secret_title,
              description: _lm.settings_server_spotify_client_secret_description,
              icon: Icons.key,
              isPassword: true,
            ),
            ServerStringSettingsField(
              setting: settings.settings["lastfm_user_api_key"]!,
              title: _lm.settings_server_lastfm_api_key_title,
              description: _lm.settings_server_lastfm_api_key_description,
              icon: Icons.key,
              isPassword: true,
            ),
            ServerStringSettingsField(
              setting: settings.settings["lastfm_user_shared_secret"]!,
              title: _lm.settings_server_lastfm_shared_secret_title,
              description: _lm.settings_server_lastfm_shared_secret_description,
              icon: Icons.password,
              isPassword: true,
            ),
          ],
        );
      }
    );
  }
}