import 'dart:ui';

import 'package:flutter/gestures.dart';
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
import 'package:vibin_app/pages/overview/albums_page.dart';
import 'package:vibin_app/pages/overview/artists_page.dart';
import 'package:vibin_app/pages/overview/playlists_page.dart';
import 'package:vibin_app/pages/overview/tracks_page.dart';
import 'package:vibin_app/widgets/network_image.dart';
import 'package:vibin_app/widgets/nowplaying/now_playing_bar.dart';

class PopObserver extends NavigatorObserver {

  final Function onPush;

  PopObserver({required this.onPush});

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    onPush();
  }
}

GoRouter configureRouter(AuthState authState) {

  // Workaround to differentiate between mouse-initiated and code-initiated pushes
  bool pushedPreviousPage = false;

  final List<String> poppedRoutes = [];

  final observer = PopObserver(onPush: () {
    if (pushedPreviousPage) return;
    poppedRoutes.clear();
  });


  final router = GoRouter(
    refreshListenable: authState,
    routes: [
      ShellRoute(
        observers: [observer],
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
              child: Listener(
                onPointerDown: (PointerDownEvent event) async {
                  final router = GoRouter.of(context);
                  if (event.kind == PointerDeviceKind.mouse) {
                    if (event.buttons == kBackMouseButton && router.canPop()) {
                      poppedRoutes.add(router.state.matchedLocation);
                      router.pop();
                    }
                    else if (event.buttons == kForwardMouseButton && poppedRoutes.isNotEmpty) {
                      final routeToPush = poppedRoutes.removeLast();
                      pushedPreviousPage = true;
                      await router.push(routeToPush, extra: 1);
                      pushedPreviousPage = false;
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: child,
                ),
              ),
            ),
          );
        },
        routes: [
          GoRoute(path: '/connect', builder: (context, state) => ConnectPage()),
          GoRoute(path: '/login', builder: (context, state) => LoginPage()),
          GoRoute(path: '/home', builder: (context, state) => HomePage()),
          GoRoute(path: '/login-error', builder: (context, state) => AutoLoginErrorPage()),
          GoRoute(path: '/tracks', builder: (context, state) => TrackPage()),
          GoRoute(path: '/tracks/:id', builder: (context, state) => TrackInfoPage(trackId: int.parse(state.pathParameters['id']!))),
          GoRoute(path: '/playlists', builder: (context, state) => PlaylistsPage()),
          GoRoute(path: '/playlists/:id', builder: (context, state) => PlaylistInfoPage(playlistId: int.parse(state.pathParameters['id']!))),
          GoRoute(path: '/albums', builder: (context, state) => AlbumPage()),
          GoRoute(path: '/albums/:id', builder: (context, state) => AlbumInfoPage(albumId: int.parse(state.pathParameters['id']!))),
          GoRoute(path: '/albums/:id/edit', builder: (context, state) => EditAlbumPage(albumId: int.parse(state.pathParameters['id']!))),
          GoRoute(path: '/artists', builder: (context, state) => ArtistsPage()),
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