import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';

class SectionHeader extends StatelessWidget {

  final String? viewAllRoute;
  final String title;

  const SectionHeader({
    super.key,
    required this.title,
    this.viewAllRoute
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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