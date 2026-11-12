import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:vibin_app/auth/auth_state.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/main_layout.dart';
import 'package:vibin_app/pages/batch_edit_page.dart';
import 'package:vibin_app/pages/drawer.dart';
import 'package:vibin_app/pages/edit/album_edit_page.dart';
import 'package:vibin_app/pages/edit/artist_edit_page.dart';
import 'package:vibin_app/pages/edit/playlist_edit_page.dart';
import 'package:vibin_app/pages/edit/track_edit_page.dart';
import 'package:vibin_app/pages/edit/user_edit_page.dart';
import 'package:vibin_app/pages/glance_page.dart';
import 'package:vibin_app/pages/home_page.dart';
import 'package:vibin_app/pages/info/album_info_page.dart';
import 'package:vibin_app/pages/info/artist_info_page.dart';
import 'package:vibin_app/pages/info/playlist_info_page.dart';
import 'package:vibin_app/pages/info/track_info_page.dart';
import 'package:vibin_app/pages/info/user/user_info_page.dart';
import 'package:vibin_app/pages/login/auto_login_error_page.dart';
import 'package:vibin_app/pages/login/login_page.dart';
import 'package:vibin_app/pages/overview/albums_page.dart';
import 'package:vibin_app/pages/overview/artists_page.dart';
import 'package:vibin_app/pages/overview/playlists_page.dart';
import 'package:vibin_app/pages/overview/tag_overview_page.dart';
import 'package:vibin_app/pages/overview/tracks_page.dart';
import 'package:vibin_app/pages/overview/users_page.dart';
import 'package:vibin_app/pages/settings/appearance_settings_page.dart';
import 'package:vibin_app/pages/settings/content_settings_page.dart';
import 'package:vibin_app/pages/settings/integration_settings_page.dart';
import 'package:vibin_app/pages/settings/metadata_settings_page.dart';
import 'package:vibin_app/pages/settings/scrobbler_settings_page.dart';
import 'package:vibin_app/pages/settings/security_settings_page.dart';
import 'package:vibin_app/pages/settings/server_metadata_settings_page.dart';
import 'package:vibin_app/pages/settings/server_misc_settings_page.dart';
import 'package:vibin_app/pages/settings/server_security_settings_page.dart';
import 'package:vibin_app/pages/settings/server_uploads_settings_page.dart';
import 'package:vibin_app/pages/settings/session_management_page.dart';
import 'package:vibin_app/pages/settings/settings_page.dart';
import 'package:vibin_app/pages/settings/streaming_settings_page.dart';
import 'package:vibin_app/pages/settings/task_management_page.dart';
import 'package:vibin_app/pages/settings/widget_management_page.dart';
import 'package:vibin_app/pages/upload_page.dart';
import 'package:vibin_app/utils/error_handler.dart';
import 'package:vibin_app/utils/image_utils.dart';
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

Page<void> _buildTransitionPage({required Widget child, required LocalKey? key}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(curved),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

GoRouter configureRouter(AuthState authState) {

  // Workaround to differentiate between mouse-initiated and code-initiated pushes
  bool pushedPreviousPage = false;

  final List<String> poppedRoutes = [];

  final observer = PopObserver(onPush: () {
    if (pushedPreviousPage) return;
    poppedRoutes.clear();
  });

  final enableMouseNavigation = !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);


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
                InkWell(
                  onTap: () {
                    if (authState.user == null) return;
                    GoRouter.of(context).push("/users/${authState.user?.id}");
                  },
                  child: NetworkImageWidget(
                    url: ImageUtils.buildUrl(authState.user?.imageId, ImageType.user, 64),
                    fit: BoxFit.contain,
                    width: 32,
                    height: 32,
                    padding: EdgeInsets.all(8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ],
            ) : null,
            drawer: authState.loggedIn ? Drawer(
              child: DrawerComponent(),
            ) : null,
            bottomNavigationBar: loggedIn ? NowPlayingBar() : null,
            body: TalkerListener(
              talker: logger,
              listener: (data) {
                if (data.logLevel == LogLevel.error || data.logLevel == LogLevel.critical) {
                  showErrorSnackBar(context, data.displayMessage, AppLocalizations.of(context)!.dialog_error_details, () {
                    ErrorHandler.showErrorDialog(context, data.displayMessage, error: data.exception ?? data.error, stackTrace: data.stackTrace, showDetails: true);
                  });
                }
              },
              child: MainLayoutView(
                showSidebar: loggedIn,
                mainContent: Listener(
                  onPointerDown: enableMouseNavigation && loggedIn ? (PointerDownEvent event) async {
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
                  } : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: child,
                  ),
                )
              )
            )
          );
        },
        routes: [
          GoRoute(path: '/login', pageBuilder: (c, s) => _buildTransitionPage(child: const LoginPage(), key: s.pageKey)),
          GoRoute(path: '/home', pageBuilder: (c, s) => _buildTransitionPage(child: const HomePage(), key: s.pageKey)),
          GoRoute(path: '/login-error', pageBuilder: (c, s) => _buildTransitionPage(child: const AutoLoginErrorPage(), key: s.pageKey)),
          GoRoute(path: '/tracks', pageBuilder: (c, s) => _buildTransitionPage(child: const TrackPage(), key: s.pageKey)),
          GoRoute(path: '/tracks/:id', pageBuilder: (c, s) => _buildTransitionPage(child: TrackInfoPage(trackId: int.parse(s.pathParameters['id']!)), key: s.pageKey)),
          GoRoute(path: '/tracks/:id/edit', pageBuilder: (c, s) => _buildTransitionPage(child: TrackEditPage(trackId: int.parse(s.pathParameters['id']!)), key: s.pageKey)),
          GoRoute(path: '/playlists', pageBuilder: (c, s) => _buildTransitionPage(child: const PlaylistsPage(), key: s.pageKey)),
          GoRoute(path: '/playlists/create', pageBuilder: (c, s) => _buildTransitionPage(child: PlaylistEditPage(playlistId: null), key: s.pageKey)),
          GoRoute(path: '/playlists/:id', pageBuilder: (c, s) => _buildTransitionPage(child: PlaylistInfoPage(playlistId: int.parse(s.pathParameters['id']!)), key: s.pageKey)),
          GoRoute(path: '/playlists/:id/edit', pageBuilder: (c, s) => _buildTransitionPage(child: PlaylistEditPage(playlistId: int.parse(s.pathParameters['id']!)), key: s.pageKey)),
          GoRoute(path: '/albums', pageBuilder: (c, s) => _buildTransitionPage(child: const AlbumPage(), key: s.pageKey)),
          GoRoute(path: '/albums/:id', pageBuilder: (c, s) => _buildTransitionPage(child: AlbumInfoPage(albumId: int.parse(s.pathParameters['id']!)), key: s.pageKey)),
          GoRoute(path: '/albums/:id/edit', pageBuilder: (c, s) => _buildTransitionPage(child: AlbumEditPage(albumId: int.parse(s.pathParameters['id']!)), key: s.pageKey)),
          GoRoute(path: '/artists', pageBuilder: (c, s) => _buildTransitionPage(child: const ArtistsPage(), key: s.pageKey)),
          GoRoute(path: '/artists/:id', pageBuilder: (c, s) => _buildTransitionPage(child: ArtistInfoPage(artistId: int.parse(s.pathParameters['id']!)), key: s.pageKey)),
          GoRoute(path: '/artists/:id/edit', pageBuilder: (c, s) => _buildTransitionPage(child: ArtistEditPage(artistId: int.parse(s.pathParameters['id']!)), key: s.pageKey)),
          GoRoute(path: '/tags', pageBuilder: (c, s) => _buildTransitionPage(child: const TagOverviewPage(), key: s.pageKey)),
          GoRoute(path: '/users', pageBuilder: (c, s) => _buildTransitionPage(child: const UsersPage(), key: s.pageKey)),
          GoRoute(path: '/users/create', pageBuilder: (c, s) => _buildTransitionPage(child: UserEditPage(userId: null, onSave: (u) => GoRouter.of(c).push("/users/${u.id}")), key: s.pageKey)),
          GoRoute(path: '/users/:id', pageBuilder: (c, s) => _buildTransitionPage(child: UserInfoPage(userId: int.parse(s.pathParameters['id']!)), key: s.pageKey)),
          GoRoute(path: '/uploads', pageBuilder: (c, s) => _buildTransitionPage(child: const UploadPage(), key: s.pageKey)),
          GoRoute(path: '/glance', pageBuilder: (c, s) => _buildTransitionPage(child: const GlancePage(), key: s.pageKey)),
          GoRoute(path: '/bulk', pageBuilder: (c, s) => _buildTransitionPage(child: const BatchEditPage(), key: s.pageKey)),
          GoRoute(path: '/logs', pageBuilder: (c, s) => _buildTransitionPage(child: TalkerScreen(talker: logger, appBarTitle: AppLocalizations.of(c)!.drawer_logs, theme: TalkerScreenTheme(
            backgroundColor: Theme.of(c).colorScheme.surface,
            textColor: Theme.of(c).colorScheme.onSurface,
            cardColor: Theme.of(c).colorScheme.surfaceContainer
          )), key: s.pageKey)),

          GoRoute(path: '/settings', pageBuilder: (c, s) => _buildTransitionPage(child: const SettingsPage(), key: s.pageKey)),
          GoRoute(path: '/settings/scrobbling', pageBuilder: (c, s) => _buildTransitionPage(child: const ScrobblerSettingsPage(), key: s.pageKey)),
          GoRoute(path: "/settings/appearance", pageBuilder: (c, s) => _buildTransitionPage(child: const AppearanceSettingsPage(), key: s.pageKey)),
          GoRoute(path: "/settings/metadata", pageBuilder: (c, s) => _buildTransitionPage(child: const MetadataSettingsPage(), key: s.pageKey)),
          GoRoute(path: "/settings/content", pageBuilder: (c, s) => _buildTransitionPage(child: const ContentSettingsPage(), key: s.pageKey)),
          GoRoute(path: "/settings/streaming", pageBuilder: (c, s) => _buildTransitionPage(child: const StreamingSettingsPage(), key: s.pageKey)),
          GoRoute(path: "/settings/security", pageBuilder: (c, s) => _buildTransitionPage(child: const SecuritySettingsPage(), key: s.pageKey)),
          GoRoute(path: '/settings/widgets', pageBuilder: (c, s) => _buildTransitionPage(child: const WidgetManagementPage(), key: s.pageKey)),
          GoRoute(path: '/settings/sessions', pageBuilder: (c, s) => _buildTransitionPage(child: const SessionManagementPage(), key: s.pageKey)),
          GoRoute(path: '/settings/integrations', pageBuilder: (c, s) => _buildTransitionPage(child: const IntegrationSettingsPage(), key: s.pageKey)),
          GoRoute(path: '/settings/server/metadata', pageBuilder: (c, s) => _buildTransitionPage(child: const ServerMetadataSettingsPage(), key: s.pageKey)),
          GoRoute(path: '/settings/server/tasks', pageBuilder: (c, s) => _buildTransitionPage(child: const TaskManagementPage(), key: s.pageKey)),
          GoRoute(path: '/settings/server/security', pageBuilder: (c, s) => _buildTransitionPage(child: const ServerSecuritySettingsPage(), key: s.pageKey)),
          GoRoute(path: '/settings/server/misc', pageBuilder: (c, s) => _buildTransitionPage(child: const ServerMiscSettingsPage(), key: s.pageKey)),
          GoRoute(path: '/settings/server/uploads', pageBuilder: (c, s) => _buildTransitionPage(child: const ServerUploadsSettingsPage(), key: s.pageKey)),
        ],
      )
    ],
    initialLocation: "/login",
    redirect: (context, state) {

      final hasAutoLoginError = authState.autoLoginResult != null && authState.autoLoginResult!.isError();
      if (hasAutoLoginError) {
        return '/login-error';
      }

      final loggedIn = authState.loggedIn;
      final loggingIn = state.fullPath == '/login';

      if (!loggedIn && !loggingIn) {
        return "/login"; // not logged in, redirect to login
      }
      if (loggedIn && loggingIn) return '/home'; // already logged in, skip login

      if (state.fullPath == '') return '/home';
      return null; // no redirect
    }
  );
  return router;
}