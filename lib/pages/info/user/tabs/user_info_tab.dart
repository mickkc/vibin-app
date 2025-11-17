import 'package:flutter/material.dart';
import 'package:vibin_app/dtos/user/user.dart';
import 'package:vibin_app/pages/info/user/favorites_section.dart';
import 'package:vibin_app/pages/info/user/user_info_view.dart';

class UserInfoTab extends StatelessWidget {
  final User user;

  const UserInfoTab({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 900) {
            return Column(
              spacing: 16,
              children: [
                FavoritesSection(userId: user.id),
                const Divider(),
                UserInfoView(user: user),
              ],
            );
          } else {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                Expanded(child: UserInfoView(user: user)),
                const VerticalDivider(),
                SingleChildScrollView(child: FavoritesSection(userId: user.id)),
              ],
            );
          }
        },
      ),
    );
  }
}
