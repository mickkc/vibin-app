import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/utils/permission_translator.dart';

import '../../l10n/app_localizations.dart';

class UserPermissionToggle extends StatefulWidget {
  final int userId;
  final bool initialValue;
  final PermissionType permissionType;
  final void Function(bool)? onChanged;

  const UserPermissionToggle({
    super.key,
    required this.userId,
    required this.initialValue,
    required this.permissionType,
    this.onChanged,
  });

  @override
  State<UserPermissionToggle> createState() => _UserPermissionToggleState();
}

class _UserPermissionToggleState extends State<UserPermissionToggle> {
  late bool hasPermission;

  final apiManager = getIt<ApiManager>();
  late final lm = AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    hasPermission = widget.initialValue;
  }

  Future<void> setPermission(bool value) async {

    if (value == hasPermission) return;

    try {
      final result = await apiManager.service.updateUserPermissions(widget.userId, widget.permissionType.value);
      if (result.granted == hasPermission) {
        return;
      }

      if (widget.onChanged != null) {
        widget.onChanged!(result.granted);
      }
      setState(() {
        hasPermission = result.granted;
      });
    }
    catch (e) {
      log("An error occurred while changing permissions: $e", error: e, level: Level.error.value);
      if (context.mounted) showErrorDialog(context, lm.permissions_change_error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(lm.translatePermission(widget.permissionType)),
      trailing: Switch(
        value: hasPermission,
        onChanged: (value) async {
          await setPermission(value);
        },
      ),
      onTap: () async {
        await setPermission(!hasPermission);
      },
    );
  }
}