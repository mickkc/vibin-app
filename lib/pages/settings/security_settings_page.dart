import 'package:flutter/material.dart';

import '../../api/api_manager.dart';
import '../../auth/auth_state.dart';
import '../../dtos/permission_type.dart';
import '../../dtos/success.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../widgets/future_content.dart';
import '../../widgets/settings/app_security_section.dart';
import '../../widgets/settings/settings_title.dart';
import '../../widgets/settings/totp_settings_section.dart';

class SecuritySettingsPage extends StatefulWidget {

  const SecuritySettingsPage({ super.key });

  @override
  State<StatefulWidget> createState() => _SecuritySettingsPage();
}

class _SecuritySettingsPage extends State<SecuritySettingsPage> {

  final _apiManager = getIt<ApiManager>();
  final _authState = getIt<AuthState>();
  late final _lm = AppLocalizations.of(context)!;

  late Future<Success> _mailSupportedFuture;

  @override
  void initState() {
    _mailSupportedFuture = _apiManager.service.isMailSupported();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SettingsTitle(
          title: _lm.settings_app_security_title,
          icon: Icons.security,
          heroTag: "settings-security",
        ),

        FutureContent(
          future: _mailSupportedFuture,
          mockData: () => Success(success: true),
          builder: (context, supported) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_authState.hasPermission(PermissionType.manageOwn2fa))
                  TotpSettingsSection(mailSupported: supported.success),

                if (_authState.hasPermission(PermissionType.manageOwnUser))
                  AppSecuritySection(mailSupported: supported.success),
              ],
            );
          },
        )
      ],
    );
  }

}