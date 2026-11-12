import 'package:flutter/material.dart';
import 'package:vibin_app/widgets/conditional_hero.dart';

class SettingsTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? heroTag;

  const SettingsTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.heroTag
  });

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
          Row(
            spacing: 8,
            children: [
              if (icon != null)
                ConditionalHero(
                  tag: heroTag == null ? null : "$heroTag-icon",
                  child: Icon(icon, size: 32),
                ),
              ConditionalHero(
                tag: heroTag == null ? null : "$heroTag-title",
                flightShuttleBuilder: textHeroFlightShuttleBuilder,
                child: Text(
                  title,
                  style: theme.textTheme.headlineMedium,
                ),
              ),
            ],
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium,
            )
        ],
      )
    );
  }
}