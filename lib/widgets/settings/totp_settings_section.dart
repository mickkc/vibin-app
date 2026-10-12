import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/auth/auth_state.dart';
import 'package:vibin_app/dtos/totp_status.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/utils/error_handler.dart';
import 'package:vibin_app/widgets/future_content.dart';
import 'package:vibin_app/widgets/settings/base_setting_widget.dart';
import 'package:vibin_app/widgets/settings/totp_setup_dialog.dart';

class TotpSettingsSection extends StatefulWidget {

  final bool mailSupported;

  const TotpSettingsSection({
    super.key,
    required this.mailSupported
  });

  @override
  State<StatefulWidget> createState() => _TotpSettingsSectionState();

}

class _TotpSettingsSectionState extends State<TotpSettingsSection> {

  final _apiManager = getIt<ApiManager>();
  final _authState = getIt<AuthState>();

  late final _emailConfigured = _authState.user?.email?.isNotEmpty ?? false;

  late Future<TotpStatus> _statusFuture;
  late final _lm = AppLocalizations.of(context)!;
  late final _cs = Theme.of(context).colorScheme;

  static const notConfigured = "None";
  static const mailConfigured = "Mail";
  static const totpConfigured = "Totp";

  @override
  void initState() {
    super.initState();
    _statusFuture = _apiManager.service.getTotpStatus();
  }

  void update() {
    setState(() {
      _statusFuture = _apiManager.service.getTotpStatus();
    });
  }

  void setTotp(String totp) async {
    try {
      await _apiManager.service.updateTotp(totp, null);
      update();
    }
    catch (e, st) {
      if (!mounted) return;
      ErrorHandler.showErrorDialog(context, _lm.settings_server_update_error, error: e, stackTrace: st);
    }
  }

  void showTotpSetupDialog(String? secret) async {
    if (secret != null) TotpSetupDialog.show(context, secret, onComplete: update);
  }

  String getSubtitle(String status) {
    switch (status) {
      case notConfigured:
        return _lm.settings_app_totp_desc_none;
      case mailConfigured:
        return _lm.settings_app_totp_desc_mail;
      case totpConfigured:
        return _lm.settings_app_totp_desc_totp;
      default:
        logger.error("Unknown TOTP status: $status!");
        return "???";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureContent(
      mockData: () {
        return TotpStatus(status: "None", secret: "00000000000000000000000000000000");
      },
      future: _statusFuture,
      builder: (context, status) {
        return BaseSettingWidget(
          title: _lm.settings_app_totp_title,
          description: getSubtitle(status.status),
          icon: Icons.security,
          child: (context, rowCol) {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (status.status == notConfigured) ... [
                  FilledButton.icon(
                    onPressed: () => showTotpSetupDialog(status.secret),
                    label: Text(_lm.settings_app_totp_configure_totp),
                    icon: const Icon(Icons.safety_check)
                  ),
                  if (widget.mailSupported)
                    FilledButton.icon(
                      onPressed: _emailConfigured ? () => setTotp(mailConfigured) : null,
                      label: Text(_lm.settings_app_totp_configure_mail),
                      icon: const Icon(Icons.mail_lock),
                      style: FilledButton.styleFrom(backgroundColor: _cs.secondary),
                    )
                ]
                else
                  FilledButton.icon(
                    onPressed: () => setTotp(notConfigured),
                    label: Text(_lm.settings_app_totp_disable),
                    icon: const Icon(Icons.clear),
                    style: FilledButton.styleFrom(backgroundColor: _cs.secondary),
                  )
              ],
            );
          }
        );
      }
    );
  }

}