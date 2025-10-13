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
        ),
        ListTile(
          title: Text(lm.user_info_display_name),
          subtitle: Text(user.displayName),
        ),
        ListTile(
          title: Text(lm.user_info_joined),
          subtitle: Text(DateTimeUtils.convertUtcUnixToLocalTimeString(user.createdAt, lm.datetime_format_full)),
        ),
        ListTile(
          title: Text(lm.user_info_active),
          subtitle: Text(user.isActive ? lm.dialog_yes : lm.dialog_no),
        ),
        ListTile(
          title: Text(lm.user_info_admin),
          subtitle: Text(user.isAdmin ? lm.dialog_yes : lm.dialog_no),
        ),
      ],
    );
  }
}