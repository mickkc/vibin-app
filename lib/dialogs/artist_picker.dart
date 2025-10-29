import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/dtos/id_or_name.dart';
import 'package:vibin_app/dtos/pagination/artist_pagination.dart';
import 'package:vibin_app/widgets/network_image.dart';
import 'package:vibin_app/widgets/pagination_footer.dart';

import '../l10n/app_localizations.dart';
import '../main.dart';

class ArtistPickerDialog extends StatefulWidget {
  final List<IdOrName> selected;
  final Function(List<IdOrName>) onChanged;
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

  late List<IdOrName> _selectedArtists;

  final _searchController = TextEditingController();
  ArtistPagination? _searchResults;

  Timer? _searchDebounce;

  final _apiManager = getIt<ApiManager>();
  
  @override
  void initState() {
    super.initState();
    _selectedArtists = List.from(widget.selected);
    _search();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _removeArtist(int index) {
    setState(() {
      _selectedArtists.removeAt(index);
    });
  }

  void _addArtist(IdOrName artist) {
    if (_selectedArtists.any((a) => a.id == artist.id)) return;
    setState(() {
      if (widget.allowMultiple) {
        _selectedArtists.add(artist);
      } else {
        _selectedArtists = [artist];
      }
    });
  }

  bool _doesContainName(String name) {
    for (final artist in _selectedArtists) {
      if (artist.name.toLowerCase() == name.toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  bool _isValid() {
    if (_selectedArtists.isEmpty && !widget.allowEmpty) return false;
    return true;
  }

  Future<void> _search({int page = 1}) async {
    final results = await _apiManager.service.getArtists(page, 10, _searchController.text);
    setState(() {
      _searchResults = results;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final lm = AppLocalizations.of(context)!;
    final _width = MediaQuery.of(context).size.width;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            runAlignment: WrapAlignment.start,
            children: [
              for (final artist in _selectedArtists)
                Chip(
                  deleteIcon: Icon(Icons.remove),
                  label: Text(artist.id == null ? "${artist.name} (${lm.pick_artist_new})" : "${artist.name} (${artist.id})"),
                  onDeleted: () {
                    _removeArtist(_selectedArtists.indexOf(artist));
                  },
                ),
            ],
          ),

          TextField(
            decoration: InputDecoration(
              labelText: lm.search,
              prefixIcon: Icon(Icons.search),
            ),
            controller: _searchController,
            onChanged: (value) async {
              if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
              _searchDebounce = Timer(const Duration(milliseconds: 300), () async {
                _search();
              });
            },
          ),

          if (_searchController.text.isNotEmpty && !_doesContainName(_searchController.text))
            ListTile(
              title: Text(lm.pick_artist_create_new(_searchController.text)),
              leading: Icon(Icons.add),
              onTap: () {
                _addArtist(IdOrName(name: _searchController.text));
                setState(() {
                  _searchController.text = "";
                });
              },
            ),

          if (_searchResults != null) ... [
            Expanded(
              child: SizedBox(
                width: _width > 600 ? 600 : _width * 0.9,
                child: ListView(
                  children: _searchResults!.items.map<Widget>((artist) {
                    final contains = _selectedArtists.any((a) => a.id == artist.id);

                    return ListTile(
                      leading: NetworkImageWidget(
                        url: "/api/artists/${artist.id}/image?quality=small",
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      title: Text(artist.name),
                      subtitle: artist.description.isEmpty ? null : Text(artist.description),
                      onTap: () {
                        if (contains) {
                          _removeArtist(_selectedArtists.indexWhere((a) => a.id == artist.id));
                        }
                        else {
                          _addArtist(IdOrName(id: artist.id, name: artist.name));
                        }
                      },
                      trailing: contains ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null
                    );
                  }).toList(),
                ),
              ),
            ),

            PaginationFooter(
              pagination: _searchResults,
              onPageChanged: (newPage) async {
                await _search(page: newPage);
              },
            )
          ]
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