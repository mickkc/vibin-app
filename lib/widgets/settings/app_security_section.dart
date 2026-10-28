import 'package:flutter/material.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:vibin_app/widgets/future_content.dart';
import 'package:vibin_app/widgets/settings/server/server_boolean_settings_field.dart';

import '../../api/api_manager.dart';
import '../../auth/auth_state.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';

class AppSecuritySection extends StatefulWidget {
  final bool mailSupported;

  const AppSecuritySection({
    super.key,
    required this.mailSupported
  });

  @override
  State<StatefulWidget> createState() => _AppSecuritySectionState();
}

class _AppSecuritySectionState extends State<AppSecuritySection> {

  final _apiManager = getIt<ApiManager>();
  final _authState = getIt<AuthState>();

  late final _settingsFuture = _apiManager.service.getUserSettings();

  late final _lm = AppLocalizations.of(context)!;

  late final _enableLoginNotificationSetting = (_authState.user?.email?.isNotEmpty ?? false) && (_authState.user?.emailVerified ?? false);

  @override
  Widget build(BuildContext context) {
    return FutureContent(
      future: _settingsFuture,
      builder: (context, settings) {
        return SuperListView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            if (widget.mailSupported)
              ServerBooleanSettingsField(
                enabled: _enableLoginNotificationSetting,
                settingKey: "send_mail_on_new_login",
                initialValue: _enableLoginNotificationSetting && settings.settings["send_mail_on_new_login"],
                title: _lm.settings_app_security_login_notification_title,
                description: _enableLoginNotificationSetting
                  ? _lm.settings_app_security_login_notification_description
                  : _lm.settings_app_security_login_notification_unavailable,
                icon: Icons.notification_important,
              )
          ],
        );
      }
    );
  }
}