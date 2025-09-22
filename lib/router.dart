import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/auth/AuthState.dart';
import 'package:vibin_app/pages/auto_login_error_page.dart';
import 'package:vibin_app/pages/connect_page.dart';
import 'package:vibin_app/pages/home_page.dart';
import 'package:vibin_app/pages/login_page.dart';
import 'package:vibin_app/pages/settings/settings_page.dart';
import 'package:vibin_app/pages/track_info_page.dart';
import 'package:vibin_app/widgets/network_image.dart';
import 'package:vibin_app/widgets/now_playing_bar.dart';

GoRouter configureRouter(AuthState authState) {
  final router = GoRouter(
    refreshListenable: authState,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          final loggedIn = authState.loggedIn;
          return Scaffold(
            appBar: loggedIn ? AppBar(
              leading: IconButton(
                onPressed: () {
                  final router = GoRouter.of(context);
                  if (router.canPop()) {
                    router.pop();
                  }
                },
                icon: Icon(Icons.arrow_back)
              ),
              title: Text('Vibin\''),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              actions: [
                IconButton(
                    onPressed: () {
                      GoRouter.of(context).push('/settings');
                    },
                    icon: Icon(Icons.settings)
                ),
                NetworkImageWidget(
                  url: "/api/users/${authState.user?.id}/pfp?quality=small",
                  fit: BoxFit.contain,
                  width: 32,
                  height: 32,
                  padding: EdgeInsets.all(8),
                  borderRadius: BorderRadius.circular(16),
                )
              ],
            ) : null,
            bottomNavigationBar: loggedIn ? NowPlayingBar() : null,
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: child,
              ),
            ),
          );
        },
        routes: [
          GoRoute(path: '/connect', builder: (context, state) => ConnectPage()),
          GoRoute(path: '/login', builder: (context, state) => LoginPage()),
          GoRoute(path: '/home', builder: (context, state) => HomePage()),
          GoRoute(path: '/settings', builder: (context, state) => SettingsPage()),
          GoRoute(path: '/login-error', builder: (context, state) => AutoLoginErrorPage()),
          GoRoute(path: '/tracks/:id', builder: (context, state) => TrackInfoPage(trackId: int.parse(state.pathParameters['id']!))),
        ],
      )
    ],
    initialLocation: '/connect',
    redirect: (context, state) {

      final hasAutoLoginError = authState.autoLoginResult != null && authState.autoLoginResult!.isError();
      if (hasAutoLoginError) {
        return '/login-error';
      }

      final loggedIn = authState.loggedIn;
      final loggingIn = state.fullPath == '/connect' || state.fullPath == '/login';

      if (!loggedIn && !loggingIn) return '/connect'; // force connect/login
      if (loggedIn && loggingIn) return '/home'; // already logged in, skip login

      if (state.fullPath == '') return '/home';
      return null; // no redirect
    }
  );
  return router;
}