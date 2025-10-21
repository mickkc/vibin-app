import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/auth/auth_state.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/dtos/user/user.dart';
import 'package:vibin_app/pages/edit/user_edit_page.dart';
import 'package:vibin_app/pages/info/user/tabs/user_activity_tab.dart';
import 'package:vibin_app/pages/info/user/tabs/user_info_tab.dart';
import 'package:vibin_app/pages/info/user/tabs/user_permissions_tab.dart';
import 'package:vibin_app/pages/info/user/tabs/user_playlists_tab.dart';
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

  final _apiManager = getIt<ApiManager>();
  final _authState = getIt<AuthState>();

  late final _showPlaylists = _authState.hasPermission(PermissionType.viewPlaylists);
  late final _showActivity = _authState.hasPermissions([
    PermissionType.viewTracks,
    PermissionType.viewArtists,
  ]);
  late final _showUploads = _authState.hasPermission(PermissionType.viewTracks);
  late final _showEdit = _authState.hasPermission(PermissionType.manageUsers);
  late final _showPermissions = _authState.hasPermission(PermissionType.managePermissions);

  late Future<User> _userFuture = _apiManager.service.getUserById(widget.userId);
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    var tabs = 1;

    // Playlists
    if (_showPlaylists) tabs++;

    // Activity
    if (_showActivity) tabs++;

    // Uploads
    if (_showUploads) tabs++;

    // Edit
    if (_showEdit) tabs++;

    // Permissions
    if (_showPermissions) tabs++;

    _tabController = TabController(length: tabs, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final lm = AppLocalizations.of(context)!;

    return Material(
      child: Column(
        spacing: 16,
        children: [
          FutureContent(
            future: _userFuture,
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
                        Text(user.displayName ?? user.username, style: Theme.of(context).textTheme.headlineMedium),
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
                controller: _tabController,
                tabs: [
                  getTab(lm.users_info, Icons.info),

                  if (_showPlaylists)
                    getTab(lm.users_playlists, Icons.playlist_play),

                  if (_showActivity)
                    getTab(lm.users_activity, Icons.timeline),

                  if (_showUploads)
                    getTab(lm.users_uploads, Icons.upload),

                  if (_showEdit)
                    getTab(lm.users_edit, Icons.edit),

                  if (_showPermissions)
                    getTab(lm.users_permissions, Icons.lock),
                ],
              );
            }
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                FutureContent(
                  future: _userFuture,
                  builder: (context, user) {
                    return UserInfoTab(user: user);
                  }
                ),

                if (_showPlaylists)
                  UserPlaylistsTab(userId: widget.userId),

                if (_showActivity)
                  UserActivityTab(userId: widget.userId),

                if (_showUploads)
                  Center(child: Text("Uploads")),

                if (_showEdit)
                  Expanded(
                    child: UserEditPage(
                      userId: widget.userId,
                      onSave: (user) {
                        setState(() {
                          _userFuture = Future.value(user);
                        });
                      },
                    )
                  ),

                if (_showPermissions)
                  UserPermissionsTab(userId: widget.userId),
              ],
            ),
          )
        ],
      ),
    );
  }
}