import 'package:flutter/material.dart';
import 'package:vibin_app/widgets/entity_card_grid.dart';
import 'package:vibin_app/widgets/future_content.dart';
import 'package:vibin_app/widgets/pagination_footer.dart';

import '../l10n/app_localizations.dart';

class PaginatedOverview extends StatefulWidget {
  final Function(int page, String searchQuery) fetchFunction;
  final String type;
  final String title;
  final IconData? icon;

  const PaginatedOverview({
    super.key,
    required this.fetchFunction,
    required this.type,
    required this.title,
    this.icon,
  });

  @override
  State<PaginatedOverview> createState() => _PaginatedOverviewState();
}

class _PaginatedOverviewState extends State<PaginatedOverview> {
  String searchQuery = "";
  int page = 1;
  late Future<dynamic> currentPagination;

  @override
  void initState() {
    super.initState();
    currentPagination = widget.fetchFunction(page, searchQuery);
  }

  void updatePage(int newPage) {
    setState(() {
      page = newPage;
      currentPagination = widget.fetchFunction(page, searchQuery);
    });
  }

  void updateSearch(String newSearch) {
    setState(() {
      searchQuery = newSearch;
      page = 1;
      currentPagination = widget.fetchFunction(page, searchQuery);
    });
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
        FutureContent(
          future: currentPagination,
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