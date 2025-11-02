import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';

class SectionHeader extends StatelessWidget {

  final String? viewAllRoute;
  final String title;
  final int? maxLines;

  const SectionHeader({
    super.key,
    required this.title,
    this.viewAllRoute,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        Visibility(
          visible: viewAllRoute != null,
          child: TextButton(
            onPressed: () {
              if (viewAllRoute != null) {
                GoRouter.of(context).push(viewAllRoute!);
              }
            },
            child: Text(
                AppLocalizations.of(context)!.section_view_all
            ),
          ),
        )
      ],
    );
  }
}