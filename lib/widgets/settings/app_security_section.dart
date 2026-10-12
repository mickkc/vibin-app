import 'package:flutter/material.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:vibin_app/widgets/future_content.dart';
import 'package:vibin_app/widgets/settings/server/server_boolean_settings_field.dart';

import '../../api/api_manager.dart';
import '../../auth/auth_state.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';

class AppSecuritySection extends StatefulWidget {

  const AppSecuritySection({ super.key });

  @override
  State<StatefulWidget> createState() => _AppSecuritySectionState();
}

class _AppSecuritySectionState extends State<AppSecuritySection> {

  final _apiManager = getIt<ApiManager>();
  final _authState = getIt<AuthState>();

  late final _settingsFuture = _apiManager.service.getUserSettings();
  late final _lm = AppLocalizations.of(context)!;

  @override
  Widget build(BuildContext context) {
    return FutureContent(
      future: _settingsFuture,
      builder: (context, settings) {
        return SuperListView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            ServerBooleanSettingsField(
              enabled: _authState.user?.email?.isNotEmpty ?? false,
              settingKey: "send_mail_on_new_login",
              initialValue: settings.settings["send_mail_on_new_login"],
              title: _lm.settings_app_security_login_notification_title,
              description: _lm.settings_app_security_login_notification_description,
              icon: Icons.notification_important,
            )
          ],
        );
      }
    );
  }
}