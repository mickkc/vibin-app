import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vibin_app/l10n/app_localizations.dart';

import 'dtos/track/track.dart';

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
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
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

String getTotalDurationString(Iterable<Track> tracks) {
  int totalSeconds = 0;
  for (var track in tracks) {
    if (track.duration != null) {
      totalSeconds += (track.duration! / 1000).round();
    }
  }
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

Future<bool> showConfirmDialog(BuildContext context, String title, String content, {String? confirmText, String? cancelText}) async {
  bool confirmed = false;
  final lm = AppLocalizations.of(context)!;

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(cancelText ?? lm.dialog_cancel)
        ),
        ElevatedButton(
          onPressed: () {
            confirmed = true;
            Navigator.pop(context);
          },
          child: Text(confirmText ?? lm.dialog_confirm)
        )
      ],
    )
  );
  return confirmed;
}

Future<void> showMessageDialog(BuildContext context, String title, String content, {String? buttonText, IconData? icon}) async {
  final lm = AppLocalizations.of(context)!;

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      icon: icon != null ? Icon(icon, size: 48) : null,
      title: Text(title),
      content: Text(content),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(buttonText ?? lm.dialog_confirm)
        )
      ],
    )
  );
}

Future<void> showErrorDialog(BuildContext context, String content) async {
  final lm = AppLocalizations.of(context)!;

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      icon: Icon(Icons.error, size: 48, color: Theme.of(context).colorScheme.error),
      title: Text(lm.dialog_error),
      content: Text(content),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(lm.dialog_confirm)
        )
      ],
    )
  );
}

Future<void> showInfoDialog(BuildContext context, String content) async {
  final lm = AppLocalizations.of(context)!;

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      icon: Icon(Icons.info, size: 48, color: Theme.of(context).colorScheme.primary),
      title: Text(lm.dialog_info),
      content: Text(content),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(lm.dialog_confirm)
        )
      ],
    )
  );
}