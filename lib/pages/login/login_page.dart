import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/auth/auth_state.dart';
import 'package:vibin_app/dtos/login_result.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/utils/dialogs.dart';
import 'package:vibin_app/utils/error_handler.dart';

import '../../api/exceptions/version_mismatch_exception.dart';
import '../../l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _apiManager = getIt<ApiManager>();
  final _authState = getIt<AuthState>();

  late final _serverAddressController = TextEditingController(text: _apiManager.baseUrl);
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool? _serverUrlValid;

  late final _lm = AppLocalizations.of(context)!;
  late final _router = GoRouter.of(context);
  late final _theme = Theme.of(context);

  /// Tries to authenticate a session with a 2fa code.
  /// Returns false if the request failed (wrong code or rate limited) or true
  /// if the code was correct and the session was verified.
  /// Also shows an error and waits for it to get closed before returning.
  Future<bool> _tryAuthenticate2fa(String token, String code) async {
    try {
      return (await _apiManager.service.authenticateTotp(token, code)).success;
    }
    catch (e, st) {
      if (!mounted) return false;
      if (e is DioException && e.response?.statusCode == 429) {
        await ErrorHandler.showErrorDialog(context, _lm.login_totp_rate_limited, error: e, stackTrace: st);
      }
      else {
        await ErrorHandler.showErrorDialog(context, _lm.login_totp_failed, error: e, stackTrace: st);
      }
      return false;
    }
  }

  /// Prompts the user for a 2fa code until a correct code is entered or the
  /// user cancels the input.
  Future<bool> _prompt2fa(LoginResult loginResult) async {
    String? totpCode;
    do {
      if (!mounted) return false;

      totpCode = await Dialogs.showInputDialog(
        context,
        _lm.login_totp_title,
        _lm.settings_app_totp_setup_code,
        description: _lm.login_totp_description,
        autoFillHints: [AutofillHints.oneTimeCode],
        maxWidth: 400
      );

      if (totpCode == null) return false;

    } while(!(await _tryAuthenticate2fa(loginResult.token, totpCode)));

    return true;
  }

  Future<bool> _setAndValidateServerUrl() async {
    if (isEmbeddedMode()) return true;
    try {
      var url = _serverAddressController.text;
      if (url.isEmpty) return false;
      _apiManager.setBaseUrl(url);
      await _apiManager.checkConnection();
      if (mounted) {
        setState(() {
          _serverUrlValid = true;
        });
      }
      return true;
    }
    catch (e, st) {
      if (mounted) {
        if (e is VersionMismatchException) {
          ErrorHandler.showErrorDialog(context, _lm.login_connection_version_mismatch(e.appVersion, e.serverVersion));
        }
        else {
          ErrorHandler.showErrorDialog(context, _lm.login_connection_error, error: e, stackTrace: st);
        }
        setState(() {
          _serverUrlValid = false;
        });
      }
      return false;
    }
  }
  
  Future<void> _login() async {
    if (_serverUrlValid != true && !(await _setAndValidateServerUrl())) return;
    try {
      await _authState.loadDeviceId();
      final deviceName = await _authState.loadDeviceName();
      final loginResult = await _apiManager.service.login(_usernameController.text, _passwordController.text, _authState.deviceId!, deviceName);
      if (loginResult.success) {
        if (loginResult.totpRequired) {
          final totpSuccessful = await _prompt2fa(loginResult);
          if (!totpSuccessful) {
            return;
          }
        }
        _apiManager.setToken(loginResult.token);
        _authState.login(_apiManager.baseUrl, loginResult);
        _router.replace("/home");
      }
      else {
        throw _lm.login_invalid_credentials;
      }
    }
    catch (e, st) {
      if (e is DioException) {
        if (e.response?.statusCode == 401 && mounted) {
          ErrorHandler.showErrorDialog(context, _lm.login_invalid_credentials);
          return;
        }
      }
      if (mounted) ErrorHandler.showErrorDialog(context, _lm.login_error(e), error: e, stackTrace: st);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _serverAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 8,
        children: [
          Text(
            _lm.login_title,
            style: _theme.textTheme.headlineMedium,
          ),
          Text(
            _lm.login_description,
            style: _theme.textTheme.bodyMedium,
          ),
          if (!isEmbeddedMode())
            SizedBox(
              width: 300,
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: _lm.login_placeholder_instance_url,
                  suffixIcon: _serverUrlValid != null
                    ? Icon(
                        _serverUrlValid! ? Icons.check_circle : Icons.error,
                        color: _serverUrlValid! ? _theme.colorScheme.primary : _theme.colorScheme.error
                      )
                    : null,
                  prefixIcon: Icon(Icons.dns),
                  hintText: "http://localhost:8080"
                ),
                onChanged: (s) {
                  if (_serverUrlValid != null) {
                    setState(() {
                      _serverUrlValid = null;
                    });
                  }
                },
                onSubmitted: (_) => _setAndValidateServerUrl(),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                controller: _serverAddressController,
                autofillHints: [AutofillHints.url],
              ),
            ),
          SizedBox(
            width: 300,
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: _lm.login_placeholder_username,
                prefixIcon: Icon(Icons.person)
              ),
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.done,
              controller: _usernameController,
              autofillHints: [AutofillHints.username],
            ),
          ),
          SizedBox(
            width: 300,
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: _lm.login_placeholder_password,
                prefixIcon: Icon(Icons.lock)
              ),
              obscureText: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _login(),
              controller: _passwordController,
              autofillHints: [AutofillHints.password],
            ),
          ),
          ElevatedButton(
            onPressed: _login,
            child: Text(_lm.login_button_login),
          )
        ],
      ),
    );
  }
}