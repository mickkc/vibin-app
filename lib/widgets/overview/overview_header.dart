import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class OverviewHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? searchQuery;
  final void Function(String)? onSearchChanged;
  final void Function(String) onSearchSubmitted;

  const OverviewHeader({
    super.key,
    required this.title,
    required this.icon,
    this.searchQuery,
    this.onSearchChanged,
    required this.onSearchSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Row(
      spacing: 8,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
        SizedBox(
          width: width > 800 ? width / 3 : 200,
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: AppLocalizations.of(context)!.search,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              contentPadding: EdgeInsets.zero,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHigh
            ),
            controller: TextEditingController(text: searchQuery),
            onChanged: onSearchChanged,
            textInputAction: TextInputAction.search,
            onSubmitted: onSearchSubmitted,
          ),
        )
      ]
    );
  }
}