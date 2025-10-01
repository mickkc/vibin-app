import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/auth/AuthState.dart';
import 'package:vibin_app/pages/edit/edit_album_page.dart';
import 'package:vibin_app/pages/info/album_info_page.dart';
import 'package:vibin_app/pages/login/auto_login_error_page.dart';
import 'package:vibin_app/pages/login/connect_page.dart';
import 'package:vibin_app/pages/drawer.dart';
import 'package:vibin_app/pages/home_page.dart';
import 'package:vibin_app/pages/login/login_page.dart';
import 'package:vibin_app/pages/info/playlist_info_page.dart';
import 'package:vibin_app/pages/info/track_info_page.dart';
import 'package:vibin_app/pages/tracks_page.dart';
import 'package:vibin_app/widgets/network_image.dart';
import 'package:vibin_app/widgets/nowplaying/now_playing_bar.dart';

GoRouter configureRouter(AuthState authState) {
  final router = GoRouter(
    refreshListenable: authState,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          final loggedIn = authState.loggedIn;
          return Scaffold(
            appBar: loggedIn ? AppBar(
              leading: Builder(
                builder: (context) {
                  return IconButton(
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    icon: Icon(Icons.menu)
                  );
                }
              ),
              title: Text('Vibin\''),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              actions: [
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
            drawer: authState.loggedIn ? Drawer(
              child: DrawerComponent(),
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
          GoRoute(path: '/login-error', builder: (context, state) => AutoLoginErrorPage()),
          GoRoute(path: '/tracks/:id', builder: (context, state) => TrackInfoPage(trackId: int.parse(state.pathParameters['id']!))),
          GoRoute(path: '/playlists/:id', builder: (context, state) => PlaylistInfoPage(playlistId: int.parse(state.pathParameters['id']!))),
          GoRoute(path: '/albums/:id', builder: (context, state) => AlbumInfoPage(albumId: int.parse(state.pathParameters['id']!))),
          GoRoute(path: '/albums/:id/edit', builder: (context, state) => EditAlbumPage(albumId: int.parse(state.pathParameters['id']!))),
          GoRoute(path: '/tracks', builder: (context, state) => TrackPage())
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