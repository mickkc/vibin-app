import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vibin_app/dtos/track/base_track.dart';

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${((a * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0')}'
      '${((r * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0')}'
      '${((g * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0')}'
      '${((b * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0')}';
}

String formatDurationMs(int milliseconds) {
  final totalSeconds = (milliseconds / 1000).floor();
  final minutes = (totalSeconds / 60).floor();
  final remainingSeconds = totalSeconds % 60;
  return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
}

String formatDuration(int seconds) {
  final minutes = (seconds / 60).floor();
  final remainingSeconds = seconds % 60;
  return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
}

String randomString(int length) {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final rand = Random();
  return List.generate(length, (index) => chars[rand.nextInt(chars.length)]).join();
}

String getTotalDurationString(Iterable<BaseTrack> tracks) {
  int totalSeconds = 0;
  for (var track in tracks) {
    final duration = track.getDuration();
    if (duration != null) {
      totalSeconds += (duration / 1000).round();
    }
  }

  return getDurationString(totalSeconds);
}

String getDurationString(int totalSeconds) {
  final hours = (totalSeconds / 3600).floor();
  final minutes = ((totalSeconds % 3600) / 60).floor();
  final seconds = totalSeconds % 60;

  if (hours > 0) {
    return "${hours}h ${minutes}m ${seconds}s";
  } else if (minutes > 0) {
    return "${minutes}m ${seconds}s";
  } else {
    return "${seconds}s";
  }
}

void showSnackBar(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ),
  );
}

void showActionSnackBar(BuildContext context, String message, String actionLabel, VoidCallback onAction) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 4),
      action: SnackBarAction(
        label: actionLabel,
        onPressed: onAction,
      ),
    ),
  );
}





bool isEmbeddedMode() {
  return const bool.fromEnvironment("VIBIN_EMBEDDED_MODE", defaultValue: false);
}


