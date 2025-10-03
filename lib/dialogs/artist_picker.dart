import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/settings/settings_manager.dart';

import '../l10n/app_localizations.dart';
import '../main.dart';

class ArtistPickerDialog extends StatefulWidget {
  final List<String> selected;
  final Function(List<String>) onChanged;
  final bool allowEmpty;
  final bool allowMultiple;
  
  const ArtistPickerDialog({
    super.key,
    required this.selected,
    required this.onChanged,
    this.allowEmpty = false,
    this.allowMultiple = true,
  });
  
  @override
  State<ArtistPickerDialog> createState() => _ArtistPickerDialogState();
}

class _ArtistPickerDialogState extends State<ArtistPickerDialog> {
  
  late List<String> selectedArtists;

  String search = "";
  String currentSearch = "";

  final ApiManager apiManager = getIt<ApiManager>();
  final SettingsManager settingsManager = getIt<SettingsManager>();

  Future<List<String>> fetchArtistNameSuggestions(String query) async {
    final suggestions = await apiManager.service.autocompleteArtists(query, null);
    return suggestions.where((name) => !selectedArtists.contains(name)).toList();
  }
  
  @override
  void initState() {
    super.initState();
    selectedArtists = List.from(widget.selected);
  }

  void removeArtist(String artistName) {
    setState(() {
      selectedArtists.remove(artistName);
    });
  }

  void addArtist(String artistName) {
    if (selectedArtists.contains(artistName)) return;
    setState(() {
      if (widget.allowMultiple) {
        selectedArtists.add(artistName);
      } else {
        selectedArtists = [artistName];
      }
      search = "";
      currentSearch = "";
    });
  }

  List<String> getAdditionalArtists() {
    return selectedArtists.where((a) => !widget.selected.contains(a)).toList();
  }

  bool isValid() {
    if (selectedArtists.isEmpty && !widget.allowEmpty) return false;
    return true;
  }
  
  @override
  Widget build(BuildContext context) {
    final lm = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;

    return AlertDialog(
      constraints: BoxConstraints(
        maxWidth: 600,
        maxHeight: 800,
      ),
      insetPadding: EdgeInsets.all(8),
      title: Text(
        widget.allowMultiple ? lm.pick_artists_title : lm.pick_artist_title,
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      content: Column(
        spacing: 16,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 8,
            children: [
              Expanded(
                child: TypeAheadField<String>(
                  controller: TextEditingController(text: search),
                  itemBuilder: (context, suggestion) {
                    return ListTile(title: Text(suggestion));
                  },
                  builder: (context, controller, focusNode) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: lm.search,
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        currentSearch = value;
                      },
                      onSubmitted: (value) {
                        if (value.trim().isEmpty) return;
                        addArtist(value.trim());
                      },
                    );
                  },
                  onSelected: addArtist,
                  suggestionsCallback: (pattern) async {
                    if (pattern.trim().length < 2) return [];
                    return fetchArtistNameSuggestions(pattern);
                  },
                  hideOnEmpty: true,
                  hideOnLoading: true,
                  hideWithKeyboard: true
                ),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  if (currentSearch.isEmpty) return;
                  addArtist(currentSearch.trim());
                },
              )
            ],
          ),


          Expanded(
            child: SizedBox(
              width: width > 600 ? 600 : width - 64,
              child: ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: selectedArtists.map((additionalArtist) {
                  return ListTile(
                    title: Text(additionalArtist),
                    leading: Icon(Icons.person),
                    trailing: IconButton(
                      icon: Icon(Icons.remove_circle),
                      onPressed: () {
                        removeArtist(additionalArtist);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: isValid() ? () {
            widget.onChanged(selectedArtists);
            Navigator.of(context).pop();
          } : null,
          child: Text(lm.dialog_finish),
        )
      ],
    );
  }
}