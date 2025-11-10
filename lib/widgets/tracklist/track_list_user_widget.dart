import 'package:flutter/material.dart';
import 'package:vibin_app/widgets/network_image.dart';

import '../../dtos/id_name.dart';

class TrackListUserWidget extends StatelessWidget {

  final bool isMobile;
  final IdName? user;
  final String? tooltip;

  const TrackListUserWidget({
    super.key,
    required this.isMobile,
    required this.user,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {

    if (user == null) {
      // Vibedef
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: const Icon(Icons.auto_awesome),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: !isMobile
        ? Tooltip(
            message: tooltip ?? user!.name,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                NetworkImageWidget(
                  url: "/api/users/${user!.id}/pfp?quality=64",
                  width: 32,
                  height: 32,
                  borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                ),
                Flexible(
                  child: Text(
                    user!.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )
                ),
              ],
            ),
        )
        : Tooltip(
            message: tooltip ?? user!.name,
            child: NetworkImageWidget(
              url: "/api/users/${user!.id}/pfp?quality=64",
              width: 32,
              height: 32,
              borderRadius: const BorderRadius.all(Radius.circular(16.0)),
            ),
        ),
    );
  }

}