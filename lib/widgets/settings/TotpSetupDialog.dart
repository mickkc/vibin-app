import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/utils/error_handler.dart';
import 'package:vibin_app/utils/url_utils.dart';
import 'package:vibin_app/widgets/network_image.dart';

class TotpSetupDialog extends StatefulWidget {

  const TotpSetupDialog({super.key});

  @override
  State<StatefulWidget> createState() => _TotpsetupdialogState();

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        constraints: const BoxConstraints(maxWidth: 288),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TotpSetupDialog(),
        ),
      )
    );
  }
}

class _TotpsetupdialogState extends State<TotpSetupDialog> {

  final _apiManager = getIt<ApiManager>();
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

  _checkCodeValid() {
    setState(() {
      _isCodeValid = _codeRegexp.hasMatch(_codeController.text);
    });
  }

  void _send() async {
    try {
      final resp = await _apiManager.service.updateTotp("Totp", _codeController.text);
      if (resp.success) {
        Navigator.pop(context);
        showSnackBar(context, _lm.settings_app_totp_setup_code_success);
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
        ),
        FilledButton(
          onPressed: _isCodeValid ? _send : null,
          child: Text(_lm.dialog_confirm)
        )
      ],
    );
  }

}