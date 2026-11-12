import 'package:flutter/material.dart';
import 'package:vibin_app/pages/column_page.dart';

import '../../api/api_manager.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../widgets/future_content.dart';
import '../../widgets/settings/server/string_list_setting.dart';
import '../../widgets/settings/settings_title.dart';

class ServerMiscSettingsPage extends StatefulWidget {

  const ServerMiscSettingsPage({ super.key });

  @override
  State<StatefulWidget> createState() => _ServerMiscSettingsPageState();
}

class _ServerMiscSettingsPageState extends State<ServerMiscSettingsPage> {

  final _apiManager = getIt<ApiManager>();

  late final _settingsFuture = _apiManager.service.getServerSettings();
  late final _lm = AppLocalizations.of(context)!;

  @override
  Widget build(BuildContext context) {
    return ColumnPage(
      spacing: 0,
      children: [
        SettingsTitle(
          title: _lm.settings_server_misc_title,
          icon: Icons.miscellaneous_services,
          heroTag: "settings-server-misc",
        ),
        FutureContent(
          future: _settingsFuture,
          builder: (context, settings) {
            return ListView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                StringListSetting(
                  setting: settings.settings["welcome_texts"]!,
                  title: _lm.settings_server_welcome_messages_title,
                  description: _lm.settings_server_welcome_messages_description,
                ),
              ],
            );
          }
        ),
      ],
    );
  }
}