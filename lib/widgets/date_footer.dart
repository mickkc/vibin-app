import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/utils/datetime_utils.dart';

class DateFooter extends StatelessWidget {
  final int createdAt;
  final int? updatedAt;

  const DateFooter({
    super.key,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  Widget build(BuildContext context) {

    final lm = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        Icon(
          Icons.info_outline,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lm.datetime_created_at(DateTimeUtils.convertUtcUnixToLocalTimeString(createdAt, lm.datetime_format_full)),
              style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)
            ),
            if (updatedAt != null)
              Text(
                lm.datetime_updated_at(DateTimeUtils.convertUtcUnixToLocalTimeString(updatedAt!, lm.datetime_format_full)),
                style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)
              )
          ]
        )
      ],
    );
  }
}