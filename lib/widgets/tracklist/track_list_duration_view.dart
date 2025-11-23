import 'package:flutter/material.dart';

import '../../extensions.dart';

class TrackListDurationView extends StatelessWidget {
  final int? duration;

  const TrackListDurationView({
    super.key,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: duration == null
          ? SizedBox.shrink()
          : Text(
              formatDurationMs(duration!),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)
            ),
    );
  }

}