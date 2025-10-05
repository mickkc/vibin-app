import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/dtos/track/track_info_metadata.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/widgets/future_content.dart';
import 'package:vibin_app/widgets/network_image.dart';

import '../../l10n/app_localizations.dart';

class SearchTrackMetadataDialog extends StatefulWidget {
  final String? initialSearch;
  final Function(TrackInfoMetadata) onSelect;

  const SearchTrackMetadataDialog({
    super.key,
    this.initialSearch,
    required this.onSelect,
  });

  @override
  createState() => _SearchTrackMetadataDialogState();
}

class _SearchTrackMetadataDialogState extends State<SearchTrackMetadataDialog> {

  bool initialized = false;

  late String searchQuery = widget.initialSearch ?? "";
  String selectedProvider = "";

  List<String> providers = [];

  late Future<List<TrackInfoMetadata>> searchFuture;

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

    final future = apiManager.service.searchTrackMetadata(searchQuery, selectedProvider);
    setState(() {
      searchFuture = future;
    });
  }

  @override
  void initState() {
    super.initState();

    apiManager.service.getMetadataProviders().then((providers) {
      setState(() {
        this.providers = providers.track;
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
                      return ListTile(
                        title: Text(item.title),
                        subtitle: Text(item.artistNames?.join(", ") ?? ""),
                        leading: item.coverImageUrl == null ? null : NetworkImageWidget(
                          url: item.coverImageUrl!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        onTap: () {
                          widget.onSelect(item);
                          Navigator.of(context).pop();
                        },
                      );
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