import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/auth/AuthState.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/pages/info/user/tabs/user_info_tab.dart';
import 'package:vibin_app/widgets/future_content.dart';
import 'package:vibin_app/widgets/network_image.dart';

import '../../../l10n/app_localizations.dart';
import '../../../main.dart';

class UserInfoPage extends StatefulWidget {
  final int userId;

  const UserInfoPage({
    super.key,
    required this.userId
  });

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> with SingleTickerProviderStateMixin {

  final ApiManager apiManager = getIt<ApiManager>();
  final AuthState authState = getIt<AuthState>();

  late final showPlaylists = authState.hasPermission(PermissionType.viewPlaylists);
  late final showActivity = authState.hasAnyPermission([
    PermissionType.viewAlbums,
    PermissionType.viewArtists,
    PermissionType.viewPlaylists
  ]);
  late final showUploads = authState.hasPermission(PermissionType.viewTracks);
  late final showEdit = authState.hasPermission(PermissionType.manageUsers);
  late final showPermissions = authState.hasPermission(PermissionType.managePermissions);

  late final userFuture = apiManager.service.getUserById(widget.userId);
  late final TabController tabController;

  @override
  void initState() {
    super.initState();

    var tabs = 1;

    // Playlists
    if (showPlaylists) tabs++;

    // Activity
    if (showActivity) tabs++;

    // Uploads
    if (showUploads) tabs++;

    // Edit
    if (showEdit) tabs++;

    // Permissions
    if (showPermissions) tabs++;

    tabController = TabController(length: tabs, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final lm = AppLocalizations.of(context)!;

    return Column(
      spacing: 32,
      children: [
        FutureContent(
          future: userFuture,
          builder: (context, user) {
            return Row(
              spacing: 16,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                NetworkImageWidget(
                  url: "/api/users/${user.id}/pfp",
                  width: 100,
                  height: 100,
                  borderRadius: BorderRadius.circular(50)
                ),
                Expanded(
                  child: Column(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.displayName, style: Theme.of(context).textTheme.headlineMedium),
                      Text(user.username),
                    ],
                  ),
                )
              ],
            );
          }
        ),

        LayoutBuilder(
          builder: (context, constraints) {

            Tab getTab(String text, IconData icon) {
              if (constraints.maxWidth < 600) {
                return Tab(icon: Icon(icon));
              } else {
                return Tab(text: text);
              }
            }

            return TabBar(
              controller: tabController,
              tabs: [
                getTab(lm.users_info, Icons.info),

                if (showPlaylists)
                  getTab(lm.users_playlists, Icons.playlist_play),

                if (showActivity)
                  getTab(lm.users_activity, Icons.timeline),

                if (showUploads)
                  getTab(lm.users_uploads, Icons.upload),

                if (showEdit)
                  getTab(lm.users_edit, Icons.edit),

                if (showPermissions)
                  getTab(lm.users_permissions, Icons.lock),
              ],
            );
          }
        ),

        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              FutureContent(
                future: userFuture,
                builder: (context, user) {
                  return UserInfoTab(user: user);
                }
              ),

              if (showPlaylists)
                Center(child: Text("Playlists")),

              if (showActivity)
              Center(child: Text("Activity")),

              if (showUploads)
                Center(child: Text("Uploads")),

              if (showEdit)
                Center(child: Text("Edit")),

              if (showPermissions)
                Center(child: Text("Permissions")),
            ],
          ),
        )
      ],
    );
  }
}