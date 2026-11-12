import 'package:flutter/material.dart';
import 'package:vibin_app/pages/column_page.dart';

import '../../api/api_manager.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../widgets/future_content.dart';
import '../../widgets/settings/server/server_string_settings_field.dart';
import '../../widgets/settings/settings_title.dart';

class ServerUploadsSettingsPage extends StatefulWidget {

  const ServerUploadsSettingsPage({ super.key });

  @override
  State<StatefulWidget> createState() => _ServerUploadsSettingsPageState();
}

class _ServerUploadsSettingsPageState extends State<ServerUploadsSettingsPage> {

  final _apiManager = getIt<ApiManager>();

  late final _settingsFuture = _apiManager.service.getServerSettings();
  late final _lm = AppLocalizations.of(context)!;

  @override
  Widget build(BuildContext context) {
    return ColumnPage(
      spacing: 0,
      children: [
        SettingsTitle(
          title: _lm.settings_server_uploads_title,
          icon: Icons.upload,
          heroTag: "settings-server-uploads",
        ),
        FutureContent(
          future: _settingsFuture,
          builder: (context, settings) {
            return ListView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [

                ServerStringSettingsField(
                  setting: settings.settings["upload_path"]!,
                  title: _lm.settings_server_uploads_path_template_title,
                  description: _lm.settings_server_uploads_path_template_description,
                  icon: Icons.upload_file,
                ),
              ],
            );
          }
        ),
      ],
    );
  }
}