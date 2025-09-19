import 'package:flutter/cupertino.dart';
import 'package:vibin_app/auth/AuthState.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/main.dart';

class PermissionWidget extends StatelessWidget {
  final List<PermissionType> requiredPermissions;
  final Widget child;

  final authState = getIt<AuthState>();

  PermissionWidget({
    super.key,
    required this.requiredPermissions,
    required this.child
  });

  @override
  Widget build(BuildContext context) {
    final hasPermissions = authState.user != null && (authState.user!.isAdmin || requiredPermissions.every((perm) => authState.permissions.contains(perm.value)));
    if (hasPermissions) {
      return child;
    } else {
      return const SizedBox.shrink();
    }
  }
}