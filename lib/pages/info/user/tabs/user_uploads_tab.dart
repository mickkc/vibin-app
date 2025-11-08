import 'package:flutter/material.dart';
import 'package:vibin_app/widgets/entity_card_grid.dart';
import 'package:vibin_app/widgets/future_content.dart';

import '../../../../api/api_manager.dart';
import '../../../../main.dart';
import '../../../../widgets/entity_card.dart';

class UserUploadsTab extends StatelessWidget {
  final int userId;

  const UserUploadsTab({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final apiManager = getIt<ApiManager>();
    final uploadsFuture = apiManager.service.getUploadedTracksByUser(userId);

    return FutureContent(
      future: uploadsFuture,
      hasData: (u) => u.isNotEmpty,
      builder: (context, tracks) {
        return EntityCardGrid(
          items: tracks,
          type: EntityCardType.track,
        );
      }
    );
  }
}