import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:vibin_app/dialogs/base_search_dialog.dart';
import 'package:vibin_app/dtos/artist/artist.dart';
import 'package:vibin_app/dtos/artist/artist_edit_data.dart';
import 'package:vibin_app/utils/error_handler.dart';
import 'package:vibin_app/widgets/network_image.dart';

class ArtistPickerDialog extends BaseSearchDialog<Artist> {
  final List<Artist> selected;
  final Function(List<Artist>) onChanged;
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

class _ArtistPickerDialogState extends BaseSearchDialogState<Artist, ArtistPickerDialog> {

  late List<Artist> _selectedArtists;

  @override
  void initState() {
    super.initState();
    _selectedArtists = List.from(widget.selected);
  }

  @override
  String get dialogTitle => widget.allowMultiple ? lm.pick_artists_title : lm.pick_artist_title;

  @override
  Future<void> search({int page = 1}) async {
    final results = await apiManager.service.getArtists(page, 10, searchController.text);
    setState(() {
      searchResultPagination = results;
    });
  }

  void _removeArtist(Artist artist) {
    setState(() {
      _selectedArtists.removeWhere((a) => a.id == artist.id);
    });
  }

  void _addArtist(Artist artist) {
    if (_selectedArtists.any((a) => a.id == artist.id)) return;
    setState(() {
      if (widget.allowMultiple) {
        _selectedArtists.add(artist);
      } else {
        _selectedArtists = [artist];
      }
    });
  }

  bool _isValid() {
    if (_selectedArtists.isEmpty && !widget.allowEmpty) return false;
    return true;
  }

  @override
  Widget? buildHeader(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.start,
      runAlignment: WrapAlignment.start,
      children: [
        for (final artist in _selectedArtists)
          Chip(
            deleteIcon: Icon(Icons.remove),
            label: Text(artist.name),
            onDeleted: () {
              _removeArtist(artist);
            },
          ),
      ],
    );
  }

  @override
  Widget? buildCreateNewItem(BuildContext context) {
    return ListTile(
      title: Text(lm.pick_artist_create_new(searchController.text)),
      leading: Icon(Icons.add),
      onTap: () async {
        try {
          final newArtist = await apiManager.service.createArtist(ArtistEditData(name: searchController.text));
          _addArtist(newArtist);
        } catch (e, st) {
          log("An error occurred while creating new artist: $e", error: e, level: Level.error.value);
          if (context.mounted) ErrorHandler.showErrorDialog(context, lm.pick_artist_create_error, error: e, stackTrace: st);
        }
      },
    );
  }

  @override
  Widget buildListItem(BuildContext context, Artist artist, int index) {
    final contains = _selectedArtists.any((a) => a.id == artist.id);

    return ListTile(
      leading: NetworkImageWidget(
        url: "/api/artists/${artist.id}/image?quality=64",
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(22),
      ),
      title: Text(artist.name),
      subtitle: artist.description.isEmpty ? null : Text(artist.description),
      onTap: () {
        if (contains) {
          _removeArtist(artist);
        }
        else {
          _addArtist(artist);
        }
      },
      trailing: contains ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      ElevatedButton(
        onPressed: _isValid() ? () {
          widget.onChanged(_selectedArtists);
          Navigator.of(context).pop();
        } : null,
        child: Text(lm.dialog_finish),
      )
    ];
  }
}