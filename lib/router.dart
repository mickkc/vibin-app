import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/auth/auth_state.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/main_layout.dart';
import 'package:vibin_app/pages/drawer.dart';
import 'package:vibin_app/pages/edit/album_edit_page.dart';
import 'package:vibin_app/pages/edit/artist_edit_page.dart';
import 'package:vibin_app/pages/edit/playlist_edit_page.dart';
import 'package:vibin_app/pages/edit/track_edit_page.dart';
import 'package:vibin_app/pages/edit/user_edit_page.dart';
import 'package:vibin_app/pages/home_page.dart';
import 'package:vibin_app/pages/info/album_info_page.dart';
import 'package:vibin_app/pages/info/artist_info_page.dart';
import 'package:vibin_app/pages/info/playlist_info_page.dart';
import 'package:vibin_app/pages/info/track_info_page.dart';
import 'package:vibin_app/pages/info/user/user_info_page.dart';
import 'package:vibin_app/pages/login/auto_login_error_page.dart';
import 'package:vibin_app/pages/login/connect_page.dart';
import 'package:vibin_app/pages/login/login_page.dart';
import 'package:vibin_app/pages/overview/albums_page.dart';
import 'package:vibin_app/pages/overview/artists_page.dart';
import 'package:vibin_app/pages/overview/playlists_page.dart';
import 'package:vibin_app/pages/overview/tag_overview_page.dart';
import 'package:vibin_app/pages/overview/tracks_page.dart';
import 'package:vibin_app/pages/overview/users_page.dart';
import 'package:vibin_app/pages/settings/app_settings_page.dart';
import 'package:vibin_app/pages/settings/server_settings_page.dart';
import 'package:vibin_app/pages/settings/session_management_page.dart';
import 'package:vibin_app/pages/settings/task_management_page.dart';
import 'package:vibin_app/pages/upload_page.dart';
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
                  url: "/api/users/${authState.user?.id}/pfp?quality=64",
                  fit: BoxFit.contain,
                  width: 32,
                  height: 32,
                  padding: EdgeInsets.all(8),
                  borderRadius: BorderRadius.circular(16),
                ),
              ],
            ) : null,
            drawer: authState.loggedIn ? Drawer(
              child: DrawerComponent(),
            ) : null,
            bottomNavigationBar: loggedIn ? NowPlayingBar() : null,
            body: !authState.loggedIn ? child : MainLayoutView(
              mainContent: Listener(
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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: child,
                ),
              )
            )
          );
        },
        routes: [
          GoRoute(path: '/connect', builder: (context, state) => const ConnectPage()),
          GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
          GoRoute(path: '/home', builder: (context, state) => const HomePage()),
          GoRoute(path: '/login-error', builder: (context, state) => const AutoLoginErrorPage()),
          GoRoute(path: '/tracks', builder: (context, state) => const TrackPage()),
          GoRoute(path: '/tracks/:id', builder: (context, state) => TrackInfoPage(trackId: int.parse(state.pathParameters['id']!))),
          GoRoute(path: '/tracks/:id/edit', builder: (context, state) => TrackEditPage(trackId: int.parse(state.pathParameters['id']!))),
          GoRoute(path: '/playlists', builder: (context, state) => const PlaylistsPage()),
          GoRoute(path: '/playlists/create', builder: (context, state) => PlaylistEditPage(playlistId: null)),
          GoRoute(path: '/playlists/:id', builder: (context, state) => PlaylistInfoPage(playlistId: int.parse(state.pathParameters['id']!))),
          GoRoute(path: '/playlists/:id/edit', builder: (context, state) => PlaylistEditPage(playlistId: int.parse(state.pathParameters['id']!))),
          GoRoute(path: '/albums', builder: (context, state) => const AlbumPage()),
          GoRoute(path: '/albums/:id', builder: (context, state) => AlbumInfoPage(albumId: int.parse(state.pathParameters['id']!))),
          GoRoute(path: '/albums/:id/edit', builder: (context, state) => AlbumEditPage(albumId: int.parse(state.pathParameters['id']!))),
          GoRoute(path: '/artists', builder: (context, state) => const ArtistsPage()),
          GoRoute(path: '/artists/:id', builder: (context, state) => ArtistInfoPage(artistId: int.parse(state.pathParameters['id']!))),
          GoRoute(path: '/artists/:id/edit', builder: (context, state) => ArtistEditPage(artistId: int.parse(state.pathParameters['id']!))),
          GoRoute(path: '/settings/app', builder: (context, state) => const AppSettingsPage()),
          GoRoute(path: '/settings/server', builder: (context, state) => const ServerSettingsPage()),
          GoRoute(path: '/tags', builder: (context, state) => const TagOverviewPage()),
          GoRoute(path: '/users', builder: (context, state) => const UsersPage()),
          GoRoute(path: '/users/create', builder: (context, state) => UserEditPage(userId: null, onSave: (u) => GoRouter.of(context).push("/users/${u.id}"))),
          GoRoute(path: '/users/:id', builder: (context, state) => UserInfoPage(userId: int.parse(state.pathParameters['id']!))),
          GoRoute(path: '/sessions', builder: (context, state) => const SessionManagementPage()),
          GoRoute(path: '/tasks', builder: (context, state) => const TaskManagementPage()),
          GoRoute(path: '/uploads', builder: (context, state) => const UploadPage()),
        ],
      )
    ],
    initialLocation: isEmbeddedMode() ? "/login" : '/connect',
    redirect: (context, state) {

      final hasAutoLoginError = authState.autoLoginResult != null && authState.autoLoginResult!.isError();
      if (hasAutoLoginError) {
        return '/login-error';
      }

      final loggedIn = authState.loggedIn;
      final loggingIn = state.fullPath == '/connect' || state.fullPath == '/login';

      if (!loggedIn && !loggingIn) {
        return isEmbeddedMode() ? "/login" : '/connect'; // not logged in, redirect to login
      }
      if (loggedIn && loggingIn) return '/home'; // already logged in, skip login

      if (state.fullPath == '') return '/home';
      return null; // no redirect
    }
  );
  return router;
}