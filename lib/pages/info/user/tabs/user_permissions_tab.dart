import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/widgets/future_content.dart';
import 'package:vibin_app/widgets/settings/user_permission_toggle.dart';

class UserPermissionsTab extends StatelessWidget {
  final int userId;

  UserPermissionsTab({super.key, required this.userId});

  final _apiManager = getIt<ApiManager>();
  late final Future<List<String>> _currentPermissionsFuture = _apiManager.service.getPermissionsForUser(userId);

  @override
  Widget build(BuildContext context) {

    return FutureContent(
      future: _currentPermissionsFuture,
      builder: (context, grantedPermissions) {
        return SuperListView.builder(
          itemCount: PermissionType.values.length,
          itemBuilder: (context, index) {

            final permission = PermissionType.values[index];
            final hasPermission = grantedPermissions.contains(permission.value);

            return UserPermissionToggle(
              userId: userId,
              initialValue: hasPermission,
              permissionType: permission,
              onChanged: (granted) {
                if (granted) {
                  grantedPermissions.add(permission.value);
                } else {
                  grantedPermissions.remove(permission.value);
                }
              },
            );
          },
        );
      }
    );
  }
}