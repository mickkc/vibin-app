import 'package:flutter/material.dart';

import '../../api/api_manager.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../utils/duration_converter.dart';
import '../../widgets/future_content.dart';
import '../../widgets/settings/server/server_boolean_settings_field.dart';
import '../../widgets/settings/server/server_number_settings_field.dart';
import '../../widgets/settings/settings_title.dart';

class ServerSecuritySettingsPage extends StatefulWidget {

  const ServerSecuritySettingsPage({ super.key });

  @override
  State<StatefulWidget> createState() => _ServerSecuritySettingsPageState();
}

class _ServerSecuritySettingsPageState extends State<ServerSecuritySettingsPage> {

  final _apiManager = getIt<ApiManager>();
  late final _settingsFuture = _apiManager.service.getServerSettings();
  late final _lm = AppLocalizations.of(context)!;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SettingsTitle(
          title: _lm.settings_server_security_title,
          icon: Icons.security,
          heroTag: "settings-server-security",
        ),
        FutureContent(
          future: _settingsFuture,
          builder: (context, settings) {
            return ListView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
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
              ],
            );
          }
        ),
      ],
    );
  }
}