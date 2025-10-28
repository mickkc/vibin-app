import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/auth/auth_state.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/widgets/network_image.dart';

import '../api/api_manager.dart';
import '../main.dart';

class DrawerComponent extends StatelessWidget {
  
  const DrawerComponent({super.key});
  
  void _goTo(BuildContext context, String route) {
    Navigator.pop(context);
    GoRouter.of(context).go(route);
  }
  
  @override
  Widget build(BuildContext context) {
    final lm = AppLocalizations.of(context)!;
    final authState = getIt<AuthState>();
    return ListView(
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          child: Text(lm.drawer_title, style: Theme.of(context).textTheme.headlineMedium),
        ),
        if (authState.user != null) ... [
          ListTile(
            leading: NetworkImageWidget(
              url: "/api/users/${authState.user!.id}/pfp?quality=small",
              width: 40,
              height: 40,
              borderRadius: BorderRadius.circular(20),
              fit: BoxFit.cover,
            ),
            title: Text(authState.user?.displayName ?? authState.user?.username ?? ""),
            subtitle: Text(authState.user?.email ?? authState.user?.username ?? ""),
          )
        ],
        ListTile(
          leading: Icon(Icons.home),
          title: Text(lm.drawer_home),
          onTap: () => _goTo(context, '/'),
        ),
        ListTile(
          leading: Icon(Icons.search),
          title: Text(lm.drawer_search),
          onTap: () => _goTo(context, '/search'),
        ),
        Divider(),
        if (authState.hasPermission(PermissionType.viewTracks))
          ListTile(
            leading: Icon(Icons.library_music),
            title: Text(lm.tracks),
            onTap: () => _goTo(context, '/tracks'),
          ),
        if (authState.hasPermission(PermissionType.viewAlbums))
          ListTile(
            leading: Icon(Icons.album),
            title: Text(lm.albums),
            onTap: () => _goTo(context, '/albums'),
          ),
        if (authState.hasPermission(PermissionType.viewArtists))
          ListTile(
            leading: Icon(Icons.person),
            title: Text(lm.artists),
            onTap: () => _goTo(context, '/artists'),
          ),
        if (authState.hasPermission(PermissionType.viewPlaylists))
          ListTile(
            leading: Icon(Icons.playlist_play),
            title: Text(lm.playlists),
            onTap: () => _goTo(context, '/playlists'),
          ),
        if (authState.hasPermission(PermissionType.viewTags))
          ListTile(
            leading: Icon(Icons.sell),
            title: Text(lm.tags),
            onTap: () => _goTo(context, '/tags'),
          ),
        if (authState.hasPermission(PermissionType.viewUsers))
          ListTile(
            leading: Icon(Icons.group),
            title: Text(lm.users),
            onTap: () => _goTo(context, '/users'),
          ),
        Divider(),
        if (authState.user != null)
          ListTile(
            leading: Icon(Icons.person),
            title: Text(lm.drawer_profile),
            onTap: () => _goTo(context, '/users/${authState.user!.id}'),
          ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text(lm.drawer_app_settings),
          onTap: () => _goTo(context, '/settings/app'),
        ),
        if (authState.hasPermission(PermissionType.changeServerSettings)) ... [
          ListTile(
            leading: Icon(Icons.electrical_services),
            title: Text(lm.drawer_server_settings),
            onTap: () => _goTo(context, '/settings/server'),
          )
        ],
        ListTile(
          leading: Icon(Icons.logout),
          title: Text(lm.drawer_logout),
          onTap: () async {
            Navigator.pop(context);
            final apiManager = getIt<ApiManager>();
            await apiManager.service.logout();
            authState.logout();
          },
        ),
      ],
    );
  }
  
}