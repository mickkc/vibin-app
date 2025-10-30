import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:vibin_app/dtos/album/album.dart';
import 'package:vibin_app/dtos/album/album_edit_data.dart';
import 'package:vibin_app/dtos/pagination/album_pagination.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/widgets/network_image.dart';
import 'package:vibin_app/widgets/pagination_footer.dart';

import '../api/api_manager.dart';
import '../extensions.dart';
import '../main.dart';

class AlbumPicker extends StatefulWidget {

  final Album? selectedAlbum;
  final Function(Album) onAlbumSelected;

  const AlbumPicker({
    super.key,
    this.selectedAlbum,
    required this.onAlbumSelected,
  });

  @override
  State<AlbumPicker> createState() => _AlbumPickerState();
}

class _AlbumPickerState extends State<AlbumPicker> {

  AlbumPagination? _searchResults;

  final _apiManager = getIt<ApiManager>();

  late final _lm = AppLocalizations.of(context)!;

  Timer? _searchDebounce;

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _search();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _search({ int page = 1 }) async {
    final results = await _apiManager.service.getAlbums(page, 20, _searchController.text, true);
    setState(() {
      _searchResults = results;
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
        _lm.pick_album_title,
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      content: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: _lm.search,
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

          if (_searchController.text.isNotEmpty)
            ListTile(
              leading: Icon(Icons.add),
              title: Text(_lm.pick_album_create_new(_searchController.text)),
              onTap: () async {
                try {
                  final newAlbum = await _apiManager.service.createAlbum(AlbumEditData(title: _searchController.text));
                  widget.onAlbumSelected(newAlbum);
                  if (context.mounted) Navigator.pop(context);
                }
                catch (e) {
                  log("An error occurred while creating album: $e", error: e, level: Level.error.value);
                  if (context.mounted) showErrorDialog(context, _lm.pick_album_create_error);
                  return;
                }
              },
            ),

          Expanded(
            child: _searchResults == null ? Center(child: CircularProgressIndicator()) :
            SizedBox(
              width: width > 600 ? 600 : width * 0.9,
              child: ListView.builder(
                itemCount: _searchResults!.items.length,
                itemBuilder: (context, index) {
                  final album = _searchResults!.items[index];
                  final isSelected = widget.selectedAlbum?.id == album.id;
                  return ListTile(
                    leading: NetworkImageWidget(
                      url: "/api/albums/${album.id}/cover?quality=small",
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    title: Text(album.title),
                    subtitle: album.description.isNotEmpty ? Text(album.description) : null,
                    trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
                    onTap: () {
                      widget.onAlbumSelected(album);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ),

          if (_searchResults != null)
            PaginationFooter(
              pagination: _searchResults,
              onPageChanged: (page) {
                _search(page: page);
              },
            )
        ],
      ),
    );
  }
}