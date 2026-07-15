import 'package:flutter/material.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/dtos/metadata_sources.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/settings/settings_key.dart';
import 'package:vibin_app/widgets/future_content.dart';

import '../../l10n/app_localizations.dart';
import '../../settings/settings_manager.dart';

class BaseMetadataDialog<T> extends StatefulWidget {
  final String? initialSearch;
  final Function(T) onSelect;
  final Future<List<T>> Function(String, String) fetchMethod;
  final ListTile Function(BuildContext, T, void Function() onTap) itemBuilder;
  final List<String> Function(MetadataSources) sourceSelector;
  final StringSettingsKey? defaultProviderSettingKey;

  const BaseMetadataDialog({
    super.key,
    this.initialSearch,
    required this.onSelect,
    required this.fetchMethod,
    required this.itemBuilder,
    required this.sourceSelector,
    this.defaultProviderSettingKey,
  });

  @override
  createState() => _BaseMetadataDialogState<T>();
}

class _BaseMetadataDialogState<T> extends State<BaseMetadataDialog<T>> {

  bool _initialized = false;

  late String _searchQuery = widget.initialSearch ?? "";
  String _selectedProvider = "";

  List<String> _providers = [];
  bool _expanded = false;

  late Future<List<T>> _searchFuture;

  final _apiManager = getIt<ApiManager>();
  final _settingsManager = getIt<SettingsManager>();
  late final _lm = AppLocalizations.of(context)!;

  double get width => MediaQuery.of(context).size.width;

  void _search() {
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
          final defaultProvider = widget.defaultProviderSettingKey != null
              ? _settingsManager.get(widget.defaultProviderSettingKey!)
              : null;

          if (defaultProvider != null && _providers.contains(defaultProvider)) {
            _selectedProvider = defaultProvider;
          }
          else {
            _selectedProvider = _providers.first;
          }
        }

        _initialized = true;
      });
      _search();
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
                    _search();
                  },
                )
              ),
              IconButton(
                onPressed: () => setState(() {
                  _expanded = !_expanded;
                }),
                icon: Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down)
              )
            ],
          ),

          Visibility(
            visible: _expanded,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0),
                child: Row(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: Text(_lm.edit_track_search_metadata_provider)),

                    DropdownButton<String>(
                      alignment: Alignment.center,
                      underline: SizedBox.shrink(),
                      isDense: true,
                      value: _selectedProvider,
                      items: _providers.map((provider) {
                        return DropdownMenuItem<String>(
                          value: provider,
                          alignment: Alignment.center,
                          child: Text(provider),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedProvider = value;
                        });
                        _search();
                      },
                    ),
                  ],
                ),
              ),
            )
          ),

          Expanded(
            child: SizedBox(
              width: width > 600 ? 600 : width - 32,
              child: FutureContent(
                future: _searchFuture,
                hasData: (data) => data.isNotEmpty,
                builder: (context, results) {
                  return SuperListView.builder(
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