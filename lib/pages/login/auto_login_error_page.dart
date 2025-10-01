import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/auth/AuthState.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/widgets/fullscreen_box.dart';

import '../../auth/auto_login_result.dart';

class AutoLoginErrorPage extends StatefulWidget {
  const AutoLoginErrorPage({super.key});

  @override
  State<AutoLoginErrorPage> createState() => _AutoLoginErrorPageState();
}

class _AutoLoginErrorPageState extends State<AutoLoginErrorPage> {
  final authState = getIt<AuthState>();
  late var autoLoginResult = authState.autoLoginResult;

  void retry() async {
    final result = await authState.tryAutoLogin();
    setAutoLoginResult(result);
    if (!result.isError()) {
      authState.clearAutoLoginResult();
      GoRouter.of(context).replace('/home');
    }
  }

  void reconnect() async {
    await authState.logout();
    GoRouter.of(context).replace('/connect');
  }

  void quit() {
    SystemNavigator.pop();
  }

  void setAutoLoginResult(AutoLoginResult? result) {
    setState(() {
      autoLoginResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lm = AppLocalizations.of(context)!;
    return FullScreenBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 16,
        children: [
          Text(
            lm.autologin_failed_title,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          Text(
            lm.autologin_failed_message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (autoLoginResult != null && autoLoginResult!.isError()) ...[
            Text(
              autoLoginResult!.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          ElevatedButton(onPressed: retry, child: Text(lm.autologin_retry)),
          ElevatedButton(onPressed: reconnect, child: Text(lm.autologin_reconnect)),
          ElevatedButton(onPressed: quit, child: Text(lm.autologin_quit)),
        ],
      ),
    );
  }
}
