import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/dtos/pagination/user_pagination.dart';
import 'package:vibin_app/dtos/user/user.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/settings/setting_definitions.dart';
import 'package:vibin_app/widgets/future_content.dart';
import 'package:vibin_app/widgets/network_image.dart';
import 'package:vibin_app/widgets/pagination_footer.dart';

import '../auth/auth_state.dart';
import '../l10n/app_localizations.dart';
import '../settings/settings_manager.dart';

class PlaylistCollaboratorDialog extends StatefulWidget {

  final List<User> initialCollaborators;
  final Function(List<User>) onCollaboratorsUpdated;

  const PlaylistCollaboratorDialog({
    super.key,
    required this.initialCollaborators,
    required this.onCollaboratorsUpdated,
  });

  static Future<void> show(BuildContext context, {
    required List<User> initialCollaborators,
    required Function(List<User>) onCollaboratorsUpdated,
  }) {
    return showDialog(
      context: context,
      builder: (context) => PlaylistCollaboratorDialog(
        initialCollaborators: initialCollaborators,
        onCollaboratorsUpdated: onCollaboratorsUpdated,
      ),
    );
  }

  @override
  State<PlaylistCollaboratorDialog> createState() => _PlaylistCollaboratorDialogState();
}

class _PlaylistCollaboratorDialogState extends State<PlaylistCollaboratorDialog> {

  late List<User> _collaborators;
  late Future<UserPagination> _usersFuture;

  late TextEditingController _searchController;

  int _currentPage = 1;

  final _apiManager = getIt<ApiManager>();
  final _settingsManger = getIt<SettingsManager>();
  final _authState = getIt<AuthState>();

  late final int _pageSize = _settingsManger.get(Settings.pageSize);

  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _collaborators = List<User>.from(widget.initialCollaborators);
    _searchController = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }
  
  void _search() {
    setState(() {
      _currentPage = 1;
      _load();
    });
  }

  void _update() {
    setState(() {
      _load();
    });
  }

  void _load() {
    _usersFuture = _apiManager.service.getUsers(_currentPage, _pageSize, _searchController.text);
  }

  void _addCollaborator(User user) {
    setState(() {
      if (!_collaborators.any((u) => u.id == user.id)) {
        _collaborators.add(user);
      }
    });
  }

  void _removeCollaborator(User user) {
    setState(() {
      _collaborators.removeWhere((u) => u.id == user.id);
    });
  }

  @override
  Widget build(BuildContext context) {

    final lm = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(lm.playlist_actions_add_collaborators),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(lm.dialog_cancel),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onCollaboratorsUpdated(_collaborators);
            Navigator.of(context).pop();
          },
          child: Text(lm.dialog_save),
        ),
      ],
      content: Column(
        spacing: 8,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: lm.search,
            ),
            onChanged: (value) {
              _searchDebounce?.cancel();
              _searchDebounce = Timer(Duration(milliseconds: 500), _search);
            },
            onSubmitted: (value) => _search(),
          ),
          Expanded(
            child: FutureContent(
              future: _usersFuture,
              builder: (context, users) {
                return Expanded(
                  child: SizedBox(
                    width: 400,
                    child: ListView.builder(
                      itemCount: users.items.length,
                      itemBuilder: (context, index) {

                        final user = users.items[index];
                        final isOwner = user.id == _authState.user?.id;
                        final isCollaborator = isOwner || _collaborators.any((u) => u.id == user.id);

                        return ListTile(
                          title: Text(user.displayName ?? user.username),
                          leading: NetworkImageWidget(
                            url: "/api/users/${user.id}/pfp",
                            width: 44,
                            height: 44,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          trailing: Checkbox(
                            value: isCollaborator,
                            onChanged: isOwner ? null : (value) {
                              if (value == true) {
                                _addCollaborator(user);
                              } else {
                                _removeCollaborator(user);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          FutureContent(
            future: _usersFuture,
            builder: (context, pag) {
              return PaginationFooter(
                pagination: pag,
                onPageChanged: (page) {
                  _currentPage = page;
                  _update();
                },
              );
            }
          )
        ],
      ),
    );
  }
}