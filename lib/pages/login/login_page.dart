import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/auth/auth_state.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/main.dart';

import '../../l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _apiManager = getIt<ApiManager>();
  final _authState = getIt<AuthState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  late final _lm = AppLocalizations.of(context)!;
  late final _router = GoRouter.of(context);
  late final _theme = Theme.of(context);

  Future<void> _login() async {
    try {
      final loginResult = await _apiManager.service.login(_usernameController.text, _passwordController.text);
      if (loginResult.success) {
        _apiManager.setToken(loginResult.token);
        _authState.login(_apiManager.baseUrl, loginResult);
        _router.replace("/home");
      }
      else {
        throw _lm.login_invalid_credentials;
      }
    }
    catch (e) {
      if (mounted) showSnackBar(context, _lm.login_error(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
          SizedBox(
            width: 300,
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: _lm.login_placeholder_username
              ),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              controller: _usernameController,
            ),
          ),
          SizedBox(
            width: 300,
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: _lm.login_placeholder_password
              ),
              obscureText: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _login(),
              controller: _passwordController,
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