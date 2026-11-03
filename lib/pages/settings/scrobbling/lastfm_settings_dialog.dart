import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/dtos/scrobbling/scrobbler.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/widgets/future_content.dart';
import 'package:vibin_app/widgets/settings/server/server_string_settings_field.dart';

class LastFmSettingsDialog extends StatefulWidget {

  final Scrobbler scrobbler;
  final Function() onClose;

  const LastFmSettingsDialog({super.key, required this.scrobbler, required this.onClose});

  @override
  State<StatefulWidget> createState() => _LastfmSettingsDialogState();

  static void show(BuildContext context, Scrobbler scrobbler, Function() onClose) {
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text(scrobbler.name, style: TextTheme.of(context).headlineSmall),
        content: SizedBox(
          width: double.maxFinite,
          child: LastFmSettingsDialog(scrobbler: scrobbler, onClose: onClose),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onClose();
            },
            child: Text(AppLocalizations.of(context)!.dialog_finish),
          )
        ],
        constraints: BoxConstraints(maxWidth: 600, maxHeight: 800),
      );
    });
  }
}

class _LastfmSettingsDialogState extends State<LastFmSettingsDialog> {

  final _apiManager = getIt<ApiManager>();
  late final _lm = AppLocalizations.of(context)!;
  late final _settingsFuture = _apiManager.service.getScrobblerSettings(widget.scrobbler.id);

  @override
  Widget build(BuildContext context) {
    return FutureContent(
      future: _settingsFuture,
      builder: (context, settings) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ServerStringSettingsField(
              setting: settings.settings["lastfm_user_api_key"]!,
              title: _lm.settings_server_lastfm_api_key_title,
              icon: Icons.key,
              isPassword: true,
              breakpoint: 400,
            ),
            ServerStringSettingsField(
              setting: settings.settings["lastfm_user_shared_secret"]!,
              title: _lm.settings_server_lastfm_shared_secret_title,
              icon: Icons.key,
              isPassword: true,
              breakpoint: 400,
            ),
            const Divider(),
            ServerStringSettingsField(
              setting: settings.settings["lastfm_user_credentials_username"]!,
              title: _lm.settings_server_lastfm_username_title,
              icon: Icons.person,
              breakpoint: 400,
            ),
            ServerStringSettingsField(
              setting: settings.settings["lastfm_user_credentials_password"]!,
              title: _lm.settings_server_lastfm_password_title,
              icon: Icons.password,
              isPassword: true,
              breakpoint: 400,
            ),
          ],
        );
      }
    );
  }
}