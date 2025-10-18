import 'package:flutter/material.dart';
import 'package:vibin_app/dtos/user/user.dart';
import 'package:vibin_app/utils/datetime_utils.dart';

import '../../../../l10n/app_localizations.dart';

class UserInfoTab extends StatelessWidget {
  final User user;

  const UserInfoTab({super.key, required this.user});

  @override
  Widget build(BuildContext context) {

    final lm = AppLocalizations.of(context)!;

    return ListView(
      children: [
        ListTile(
          title: Text(lm.user_info_username),
          subtitle: Text(user.username),
          leading: const Icon(Icons.person),
        ),
        if (user.displayName != null)
          ListTile(
            title: Text(lm.user_info_display_name),
            subtitle: Text(user.displayName!),
            leading: const Icon(Icons.badge),
          ),
        if (user.description.isNotEmpty)
          ListTile(
            title: Text(lm.user_info_bio),
            subtitle: Text(user.description),
            leading: const Icon(Icons.description),
          ),
        if (user.email != null)
          ListTile(
            title: Text(lm.user_info_email),
            subtitle: Text(user.email!),
            leading: const Icon(Icons.email),
          ),
        ListTile(
          title: Text(lm.user_info_joined),
          subtitle: Text(DateTimeUtils.convertUtcUnixToLocalTimeString(user.createdAt, lm.datetime_format_full)),
          leading: const Icon(Icons.calendar_today),
        ),
        ListTile(
          title: Text(lm.user_info_active),
          subtitle: Text(user.isActive ? lm.dialog_yes : lm.dialog_no),
          leading: const Icon(Icons.check_circle),
        ),
        ListTile(
          title: Text(lm.user_info_admin),
          subtitle: Text(user.isAdmin ? lm.dialog_yes : lm.dialog_no),
          leading: const Icon(Icons.admin_panel_settings),
        ),
      ],
    );
  }
}