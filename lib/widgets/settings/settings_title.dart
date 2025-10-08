import 'package:flutter/material.dart';

class SettingsTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const SettingsTitle({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineMedium,
          ),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium,
          )
        ],
      )
    );
  }
}