import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/auth/AuthState.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/widgets/fullscreen_box.dart';

import '../l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  ApiManager apiManager = getIt<ApiManager>();
  AuthState authState = getIt<AuthState>();
  String username = "";
  String password = "";

  void onChangedUsername(String newValue) {
    setState(() {
      username = newValue;
    });
  }

  void onChangedPassword(String newValue) {
    setState(() {
      password = newValue;
    });
  }

  Future<void> login() async {
    try {
      final loginResult = await apiManager.service.login(username, password);
      if (loginResult.success) {
        apiManager.setToken(loginResult.token);
        authState.login(apiManager.baseUrl, loginResult);
        GoRouter.of(context).replace("/home");
      }
      else {
        throw "Invalid username or password";
      }
    }
    catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Login failed: $e"))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lm = AppLocalizations.of(context)!;
    return FullScreenBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 8,
        children: [
          Text(
            lm.login_title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            lm.login_description,
            style: Theme.of(context).textTheme.bodyMedium,
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
              onChanged: onChangedUsername,
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
              onSubmitted: (value) {
                login();
              },
              onChanged: onChangedPassword,
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