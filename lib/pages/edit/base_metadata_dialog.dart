import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/dtos/metadata_sources.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/widgets/future_content.dart';

import '../../l10n/app_localizations.dart';

class BaseMetadataDialog<T> extends StatefulWidget {
  final String? initialSearch;
  final Function(T) onSelect;
  final Future<List<T>> Function(String, String) fetchMethod;
  final ListTile Function(BuildContext, T, void Function() onTap) itemBuilder;
  final List<String> Function(MetadataSources) sourceSelector;

  const BaseMetadataDialog({
    super.key,
    this.initialSearch,
    required this.onSelect,
    required this.fetchMethod,
    required this.itemBuilder,
    required this.sourceSelector,
  });

  @override
  createState() => _BaseMetadataDialogState<T>();
}

class _BaseMetadataDialogState<T> extends State<BaseMetadataDialog<T>> {

  bool initialized = false;

  late String searchQuery = widget.initialSearch ?? "";
  String selectedProvider = "";

  List<String> providers = [];

  late Future<List<T>> searchFuture;

  final ApiManager apiManager = getIt<ApiManager>();

  late final lm = AppLocalizations.of(context)!;
  late final theme = Theme.of(context);

  double get width => MediaQuery.of(context).size.width;

  void search() {
    if (searchQuery.isEmpty || selectedProvider.isEmpty) {
      setState(() {
        searchFuture = Future.value([]);
      });
      return;
    }

    final future = widget.fetchMethod(searchQuery, selectedProvider);
    setState(() {
      searchFuture = future;
    });
  }

  @override
  void initState() {
    super.initState();

    apiManager.service.getMetadataProviders().then((providers) {
      setState(() {
        this.providers = widget.sourceSelector(providers);
        if (this.providers.isNotEmpty) {
          selectedProvider = this.providers.first;
        }
        initialized = true;
      });
      search();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      constraints: BoxConstraints(
        maxWidth: 600,
        maxHeight: 800,
      ),
      title: Text(lm.edit_track_search_metadata),
      insetPadding: EdgeInsets.all(8),
      content: !initialized ? Center(child: CircularProgressIndicator()) : Column(
        spacing: 8,
        children: [
          Row(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: lm.search,
                    prefixIcon: Icon(Icons.search)
                  ),
                  onChanged: (value) {
                    searchQuery = value;
                  },
                  controller: TextEditingController(text: searchQuery),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    searchQuery = value;
                    search();
                  },
                ),
              ),
              SizedBox(
                width: 200,
                child: DropdownButton<String>(
                  value: selectedProvider,
                  items: providers.map((provider) {
                    return DropdownMenuItem<String>(
                      value: provider,
                      child: Text(provider),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      selectedProvider = value;
                    });
                    search();
                  },
                ),
              )
            ],
          ),
          Expanded(
            child: SizedBox(
              width: width > 600 ? 600 : width - 32,
              child: FutureContent(
                future: searchFuture,
                hasData: (data) => data.isNotEmpty,
                builder: (context, results) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final item = results[index];
                      return widget.itemBuilder(context, item, () {
                        widget.onSelect(item);
                        Navigator.of(context).pop();
                      });
                    },
                  );
                }
              ),
            ),
          )
        ],
      ),
    );
  }
}