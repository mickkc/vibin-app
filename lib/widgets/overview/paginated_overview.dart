import 'package:flutter/material.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/pages/column_page.dart';
import 'package:vibin_app/settings/setting_definitions.dart';
import 'package:vibin_app/settings/settings_manager.dart';
import 'package:vibin_app/widgets/entity_card.dart';
import 'package:vibin_app/widgets/entity_card_grid.dart';
import 'package:vibin_app/widgets/future_content.dart';
import 'package:vibin_app/widgets/overview/overview_header.dart';
import 'package:vibin_app/widgets/pagination_footer.dart';

class PaginatedOverview extends StatefulWidget {
  final Function(int page, int pageSize, String searchQuery) fetchFunction;
  final EntityCardType type;
  final String title;
  final IconData icon;
  final List<Widget>? actions;

  const PaginatedOverview({
    super.key,
    required this.fetchFunction,
    required this.type,
    required this.title,
    required this.icon,
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
    return ColumnPage(
      children: [
        OverviewHeader(
          title: widget.title,
          icon: widget.icon,
          searchQuery: searchQuery,
          onSearchSubmitted: (value) {
            updateSearch(value);
          }
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