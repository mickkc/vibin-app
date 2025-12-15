import 'dart:async';

import 'package:flutter/material.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/widgets/pagination_footer.dart';

abstract class BaseSearchDialog<T> extends StatefulWidget {
  const BaseSearchDialog({super.key});
}

abstract class BaseSearchDialogState<T, W extends BaseSearchDialog<T>> extends State<W> {

  dynamic searchResultPagination;

  final apiManager = getIt<ApiManager>();

  late final AppLocalizations lm = AppLocalizations.of(context)!;

  Timer? searchDebounce;

  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    search();
  }

  @override
  void dispose() {
    searchDebounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  Future<void> search({int page = 1});

  String get dialogTitle;

  Widget? buildCreateNewItem(BuildContext context) => null;

  Widget buildListItem(BuildContext context, T item, int index);

  List<Widget>? buildActions(BuildContext context) => null;

  Widget? buildHeader(BuildContext context) => null;

  void onSearchChanged(String value) {
    if (searchDebounce?.isActive ?? false) searchDebounce!.cancel();
    searchDebounce = Timer(const Duration(milliseconds: 300), () async {
      search();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return AlertDialog(
      constraints: BoxConstraints(
        maxWidth: 600,
        maxHeight: 800,
      ),
      insetPadding: EdgeInsets.all(8),
      title: Text(
        dialogTitle,
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      content: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildHeader(context),

          TextField(
            decoration: InputDecoration(
              labelText: lm.search,
              prefixIcon: Icon(Icons.search),
            ),
            controller: searchController,
            onChanged: onSearchChanged,
          ),

          if (searchController.text.isNotEmpty)
            buildCreateNewItem(context),

          Expanded(
            child: searchResultPagination == null
              ? Center(child: CircularProgressIndicator())
              : SizedBox(
                  width: width > 600 ? 600 : width * 0.9,
                  child: SuperListView.builder(
                    itemCount: searchResultPagination!.items.length,
                    itemBuilder: (context, index) {
                      final item = searchResultPagination!.items[index] as T;
                      return buildListItem(context, item, index);
                    },
                  ),
                ),
          ),

          if (searchResultPagination != null)
            PaginationFooter(
              pagination: searchResultPagination,
              onPageChanged: (page) {
                search(page: page);
              },
            )

          // Filter out null widgets
        ].whereType<Widget>().toList()
      ),
      actions: buildActions(context),
    );
  }
}