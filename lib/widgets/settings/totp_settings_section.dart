import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/dtos/totp_status.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/utils/error_handler.dart';
import 'package:vibin_app/widgets/colored_icon_button.dart';
import 'package:vibin_app/widgets/future_content.dart';
import 'package:vibin_app/widgets/settings/totp_setup_dialog.dart';

class TotpSettingsSection extends StatefulWidget {
  const TotpSettingsSection({super.key});

  @override
  State<StatefulWidget> createState() => _TotpSettingsSectionState();

}

class _TotpSettingsSectionState extends State<TotpSettingsSection> {

  final _apiManager = getIt<ApiManager>();
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
        return LayoutBuilder(
          builder: (context, constraints) {
            return ListTile(
              leading: const Icon(Icons.security),
              title: Text(_lm.settings_app_totp_title),
              subtitle: Text(getSubtitle(status.status)),
              trailing: Row(
                spacing: 8,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (status.status == notConfigured) ... [

                    if (constraints.maxWidth > 600)
                      FilledButton.icon(
                        onPressed: () => showTotpSetupDialog(status.secret),
                        label: Text(_lm.settings_app_totp_configure_totp),
                        icon: const Icon(Icons.safety_check)
                      )
                    else
                      ColoredIconButton(
                        onPressed: () => showTotpSetupDialog(status.secret),
                        tooltip: _lm.settings_app_totp_configure_totp,
                        icon: Icons.safety_check,
                        backgroundColor: _cs.primary,
                        iconColor: _cs.onPrimary,
                      ),

                    if (constraints.maxWidth > 600)
                      FilledButton.icon(
                        onPressed: () => setTotp(mailConfigured),
                        label: Text(_lm.settings_app_totp_configure_mail),
                        icon: const Icon(Icons.mail_lock),
                        style: FilledButton.styleFrom(backgroundColor: _cs.secondary)
                      )
                    else
                      ColoredIconButton(
                        onPressed: () => setTotp(mailConfigured),
                        tooltip: _lm.settings_app_totp_configure_mail,
                        icon: Icons.mail_lock,
                        backgroundColor: _cs.secondary,
                        iconColor: _cs.onSecondary,
                      ),
                  ]
                  else
                    if (constraints.maxWidth > 600)
                      FilledButton.icon(
                        onPressed: () => setTotp(notConfigured),
                        label: Text(_lm.settings_app_totp_disable),
                        icon: const Icon(Icons.clear),
                        style: FilledButton.styleFrom(backgroundColor: _cs.secondary),
                      )
                    else
                      ColoredIconButton(
                        onPressed: () => setTotp(notConfigured),
                        tooltip: _lm.settings_app_totp_disable,
                        icon: Icons.clear,
                        backgroundColor: _cs.secondary,
                        iconColor: _cs.onSecondary,
                      ),
                ],
              )
            );
          }
        );
      }
    );
  }

}