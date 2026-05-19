import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/dtos/listen_duration.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/widgets/future_content.dart';
import 'package:vibin_app/widgets/icon_text.dart';

class TrackListenDuration extends StatelessWidget {
  int trackId;

  TrackListenDuration(this.trackId, {super.key});

  final apiManager = getIt<ApiManager>();
  late final durationFuture = apiManager.service.getUserListenDurationForTrack(trackId);
  
  @override
  Widget build(BuildContext context) {
    return FutureContent(
      future: durationFuture,
      mockData: () { return ListenDuration(duration: 123); },
      builder: (context, duration) {
        return IconText(
          icon: Icons.timer,
          text: getDurationString(duration.duration)
        );
      }
    );
  }
}