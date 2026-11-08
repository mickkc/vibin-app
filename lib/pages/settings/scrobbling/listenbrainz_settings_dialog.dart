import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/dtos/scrobbling/scrobbler.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/widgets/future_content.dart';
import 'package:vibin_app/widgets/settings/server/server_string_settings_field.dart';

class ListenBrainzSettingsDialog extends StatefulWidget {

  final Scrobbler scrobbler;
  final Function() onClose;

  const ListenBrainzSettingsDialog({super.key, required this.scrobbler, required this.onClose});

  @override
  State<StatefulWidget> createState() => _ListenBrainzSettingsDialogState();

  static void show(BuildContext context, Scrobbler scrobbler, Function() onClose) {
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text(scrobbler.name, style: TextTheme.of(context).headlineSmall),
        content: SizedBox(
          width: double.maxFinite,
          child: ListenBrainzSettingsDialog(scrobbler: scrobbler, onClose: onClose),
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

class _ListenBrainzSettingsDialogState extends State<ListenBrainzSettingsDialog> {

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
              setting: settings.settings["listenbrainz_user_token"]!,
              title: _lm.settings_scrobbling_listenbrainz_token,
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