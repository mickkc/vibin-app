import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/auth/auth_state.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/utils/dialogs.dart';
import 'package:vibin_app/utils/error_handler.dart';
import 'package:vibin_app/widgets/network_image.dart';

class TotpSetupDialog extends StatefulWidget {

  final String secret;
  final Function()? onComplete;

  const TotpSetupDialog({super.key, required this.secret, this.onComplete});

  @override
  State<StatefulWidget> createState() => _TotpSetupDialogState();

  static void show(BuildContext context, String secret, { Function()? onComplete }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        constraints: const BoxConstraints(maxWidth: 288),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TotpSetupDialog(secret: secret, onComplete: onComplete),
        ),
      )
    );
  }
}

class _TotpSetupDialogState extends State<TotpSetupDialog> {

  final _apiManager = getIt<ApiManager>();
  final _authState = getIt<AuthState>();

  final _codeController = TextEditingController();
  late final _lm = AppLocalizations.of(context)!;
  final _codeRegexp = RegExp(r'^\d{6}$');

  bool _isCodeValid = false;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_checkCodeValid);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _checkCodeValid() {
    setState(() {
      _isCodeValid = _codeRegexp.hasMatch(_codeController.text);
    });
  }

  void _send() async {
    try {
      final resp = await _apiManager.service.updateTotp("Totp", _codeController.text);
      if (!mounted) return;

      if (resp.success) {
        Navigator.pop(context);
        showSnackBar(context, _lm.settings_app_totp_setup_code_success);
        widget.onComplete?.call();
      }
    }
    catch (e, st) {
      _codeController.clear();
      if (e is DioException && e.response?.statusCode == 400) {
        ErrorHandler.showErrorDialog(context, _lm.settings_app_totp_setup_code_invalid);
        return;
      }

      ErrorHandler.showErrorDialog(context, _lm.settings_app_totp_setup_code_error, error: e, stackTrace: st);
    }
  }

  void _copySecret() async {
    try {
      await Clipboard.setData(ClipboardData(text: widget.secret));
      if (mounted) showSnackBar(context, _lm.settings_app_totp_copy_secret_success);
    }
    catch (e, st) {
      if (!mounted) return;
      ErrorHandler.showErrorDialog(context, _lm.settings_app_totp_copy_secret_failed, error: e, stackTrace: st);
    }
  }

  void _openInApp() async {
    bool success = false;

    try {
      success = await launchUrl(Uri.parse("otpauth://${_authState.user?.username ?? "Vibin%27"}?secret=${widget.secret}&issuer=Vibin%27&algorith=SHA1&digits=6&period=30"));
    }
    catch (e, st) {
      logger.log("Could not open authenticator app.", exception: e, stackTrace: st);
    }

    if (mounted && !success) {
      Dialogs.showInfoDialog(context, _lm.settings_app_totp_open_app_failed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        const NetworkImageWidget(
          url: "/api/auth/totp/qr",
          width: 256,
          height: 256,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _copySecret,
                label: Text(_lm.settings_app_totp_copy_secret),
                icon: const Icon(Icons.copy),
              ),
              ElevatedButton.icon(
                onPressed: _openInApp,
                label: Text(_lm.settings_app_totp_open_app),
                icon: const Icon(Icons.open_in_new),
              )
            ],
          ),
        ),
        Text(
          _lm.settings_app_totp_setup,
          textAlign: TextAlign.center,
        ),
        TextField(
          controller: _codeController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: _lm.settings_app_totp_setup_code
          ),
          textAlign: TextAlign.center,
          onSubmitted: (s) => _isCodeValid ? _send() : null,
        ),
        FilledButton(
          onPressed: _isCodeValid ? _send : null,
          child: Text(_lm.dialog_confirm)
        )
      ],
    );
  }

}