import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/api/exceptions/version_mismatch_exception.dart';
import 'package:vibin_app/auth/auth_state.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/main.dart';

import '../../auth/auto_login_result.dart';

class AutoLoginErrorPage extends StatefulWidget {
  const AutoLoginErrorPage({super.key});

  @override
  State<AutoLoginErrorPage> createState() => _AutoLoginErrorPageState();
}

class _AutoLoginErrorPageState extends State<AutoLoginErrorPage> {
  final _authState = getIt<AuthState>();
  late var _autoLoginResult = _authState.autoLoginResult;

  late final _router = GoRouter.of(context);
  late final _lm = AppLocalizations.of(context)!;

  void _retry() async {
    final result = await _authState.tryAutoLogin();
    _setAutoLoginResult(result);
    if (!result.isError()) {
      _authState.clearAutoLoginResult();
      _router.replace('/home');
    }
  }

  void _reconnect() async {
    await _authState.logout();
    _router.replace('/connect');
  }

  void _quit() {
    SystemNavigator.pop();
  }

  void _setAutoLoginResult(AutoLoginResult? result) {
    setState(() {
      _autoLoginResult = result;
    });
  }

  String getErrorMessage(BuildContext context) {
    if (_autoLoginResult == null || _autoLoginResult!.error == null) return '';

    final lm = AppLocalizations.of(context)!;

    if (_autoLoginResult!.error! is VersionMismatchException) {
      return lm.connect_version_mismatch(
        (_autoLoginResult!.error! as VersionMismatchException).appVersion,
        (_autoLoginResult!.error! as VersionMismatchException).serverVersion,
      );
    }

    return _autoLoginResult!.error!.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 16,
        children: [
          Text(
            _lm.autologin_failed_title,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          Text(
            _lm.autologin_failed_message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (_autoLoginResult != null && _autoLoginResult!.isError()) ...[
            Text(
              getErrorMessage(context),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          ElevatedButton(onPressed: _retry, child: Text(_lm.autologin_retry)),
          ElevatedButton(onPressed: _reconnect, child: Text(_lm.autologin_reconnect)),
          ElevatedButton(onPressed: _quit, child: Text(_lm.autologin_quit)),
        ],
      ),
    );
  }
}
