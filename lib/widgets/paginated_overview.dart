import 'package:flutter/material.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/settings/setting_definitions.dart';
import 'package:vibin_app/settings/settings_manager.dart';
import 'package:vibin_app/widgets/entity_card_grid.dart';
import 'package:vibin_app/widgets/future_content.dart';
import 'package:vibin_app/widgets/pagination_footer.dart';

import '../l10n/app_localizations.dart';

class PaginatedOverview extends StatefulWidget {
  final Function(int page, int pageSize, String searchQuery) fetchFunction;
  final String type;
  final String title;
  final IconData? icon;
  final List<Widget>? actions;

  const PaginatedOverview({
    super.key,
    required this.fetchFunction,
    required this.type,
    required this.title,
    this.icon,
    this.actions,
  });

  @override
  State<PaginatedOverview> createState() => _PaginatedOverviewState();
}

class _PaginatedOverviewState extends State<PaginatedOverview> {
  String searchQuery = "";
  int page = 1;
  late Future<dynamic> currentPagination;

  final SettingsManager settingsManager = getIt<SettingsManager>();

  @override
  void initState() {
    super.initState();
    currentPagination = fetchData();
  }

  void updatePage(int newPage) {
    setState(() {
      page = newPage;
      currentPagination = fetchData();
    });
  }

  void updateSearch(String newSearch) {
    setState(() {
      searchQuery = newSearch;
      page = 1;
      currentPagination = fetchData();
    });
  }

  Future<dynamic> fetchData() {
    return widget.fetchFunction(page, settingsManager.get(Settings.pageSize), searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    final lm = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;
    return Column(
      spacing: 8,
      children: [
        Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.icon != null) Icon(widget.icon, size: 32),
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
            SizedBox(
              width: width > 800 ? width / 3 : 200,
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: lm.search,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  contentPadding: EdgeInsets.zero,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHigh
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  updateSearch(value);
                },
              ),
            )
          ]
        ),
        if (widget.actions != null) Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widget.actions!,
        ),
        FutureContent(
          future: currentPagination,
          hasData: (data) => data.items.isNotEmpty,
          builder: (context, pagination) {
            return Column(
              children: [
                EntityCardGrid(
                  items: pagination.items,
                  type: widget.type,
                ),
                PaginationFooter(
                  pagination: pagination,
                  onPageChanged: (newPage) => updatePage(newPage),
                )
              ],
            );
          }
        )
      ],
    );
  }
}