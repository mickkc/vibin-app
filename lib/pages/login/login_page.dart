import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/auth/AuthState.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/main.dart';

import '../../l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final ApiManager apiManager = getIt<ApiManager>();
  final AuthState authState = getIt<AuthState>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  late final lm = AppLocalizations.of(context)!;
  late final router = GoRouter.of(context);
  late final theme = Theme.of(context);

  Future<void> login() async {
    try {
      final loginResult = await apiManager.service.login(usernameController.text, passwordController.text);
      if (loginResult.success) {
        apiManager.setToken(loginResult.token);
        authState.login(apiManager.baseUrl, loginResult);
        router.replace("/home");
      }
      else {
        throw lm.login_invalid_credentials;
      }
    }
    catch (e) {
      if (mounted) showSnackBar(context, lm.login_error(e));
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
            lm.login_title,
            style: theme.textTheme.headlineMedium,
          ),
          Text(
            lm.login_description,
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(
            width: 300,
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: lm.login_placeholder_username
              ),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              controller: usernameController,
            ),
          ),
          SizedBox(
            width: 300,
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: lm.login_placeholder_password
              ),
              obscureText: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => login(),
              controller: passwordController,
            ),
          ),
          ElevatedButton(
            onPressed: login,
            child: Text(lm.login_button_login),
          )
        ],
      ),
    );
  }
}