import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:vibin_app/api/api_manager.dart';

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
  
  late List<String> _selectedArtists;

  String _search = "";
  String _currentSearch = "";

  final _apiManager = getIt<ApiManager>();

  Future<List<String>> fetchArtistNameSuggestions(String query) async {
    final suggestions = await _apiManager.service.autocompleteArtists(query, null);
    return suggestions.where((name) => !_selectedArtists.contains(name)).toList();
  }
  
  @override
  void initState() {
    super.initState();
    _selectedArtists = List.from(widget.selected);
  }

  void _removeArtist(String artistName) {
    setState(() {
      _selectedArtists.remove(artistName);
    });
  }

  void _addArtist(String artistName) {
    if (_selectedArtists.contains(artistName)) return;
    setState(() {
      if (widget.allowMultiple) {
        _selectedArtists.add(artistName);
      } else {
        _selectedArtists = [artistName];
      }
      _search = "";
      _currentSearch = "";
    });
  }

  bool _isValid() {
    if (_selectedArtists.isEmpty && !widget.allowEmpty) return false;
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
                  controller: TextEditingController(text: _search),
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
                        _currentSearch = value;
                      },
                      onSubmitted: (value) {
                        if (value.trim().isEmpty) return;
                        _addArtist(value.trim());
                      },
                    );
                  },
                  onSelected: _addArtist,
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
                  if (_currentSearch.isEmpty) return;
                  _addArtist(_currentSearch.trim());
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
                children: _selectedArtists.map((additionalArtist) {
                  return ListTile(
                    title: Text(additionalArtist),
                    leading: Icon(Icons.person),
                    trailing: IconButton(
                      icon: Icon(Icons.remove_circle),
                      onPressed: () {
                        _removeArtist(additionalArtist);
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
          onPressed: _isValid() ? () {
            widget.onChanged(_selectedArtists);
            Navigator.of(context).pop();
          } : null,
          child: Text(lm.dialog_finish),
        )
      ],
    );
  }
}