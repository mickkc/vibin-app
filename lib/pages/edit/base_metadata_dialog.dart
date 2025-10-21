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

  bool _initialized = false;

  late String _searchQuery = widget.initialSearch ?? "";
  String _selectedProvider = "";

  List<String> _providers = [];

  late Future<List<T>> _searchFuture;

  final _apiManager = getIt<ApiManager>();
  late final _lm = AppLocalizations.of(context)!;

  double get width => MediaQuery.of(context).size.width;

  void search() {
    if (_searchQuery.isEmpty || _selectedProvider.isEmpty) {
      setState(() {
        _searchFuture = Future.value([]);
      });
      return;
    }

    final future = widget.fetchMethod(_searchQuery, _selectedProvider);
    setState(() {
      _searchFuture = future;
    });
  }

  @override
  void initState() {
    super.initState();

    _apiManager.service.getMetadataProviders().then((providers) {
      setState(() {
        _providers = widget.sourceSelector(providers);
        if (_providers.isNotEmpty) {
          _selectedProvider = _providers.first;
        }
        _initialized = true;
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
      title: Text(_lm.edit_track_search_metadata),
      insetPadding: EdgeInsets.all(8),
      content: !_initialized ? Center(child: CircularProgressIndicator()) : Column(
        spacing: 8,
        children: [
          Row(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: _lm.search,
                    prefixIcon: Icon(Icons.search)
                  ),
                  onChanged: (value) {
                    _searchQuery = value;
                  },
                  controller: TextEditingController(text: _searchQuery),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    _searchQuery = value;
                    search();
                  },
                ),
              ),
              SizedBox(
                width: 200,
                child: DropdownButton<String>(
                  value: _selectedProvider,
                  items: _providers.map((provider) {
                    return DropdownMenuItem<String>(
                      value: provider,
                      child: Text(provider),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedProvider = value;
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
                future: _searchFuture,
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