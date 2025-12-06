import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:vibin_app/dialogs/base_search_dialog.dart';
import 'package:vibin_app/dtos/album/album.dart';
import 'package:vibin_app/dtos/album/album_edit_data.dart';
import 'package:vibin_app/utils/error_handler.dart';
import 'package:vibin_app/widgets/network_image.dart';

class AlbumPicker extends BaseSearchDialog<Album> {

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

class _AlbumPickerState extends BaseSearchDialogState<Album, AlbumPicker> {

  @override
  String get dialogTitle => lm.pick_album_title;

  @override
  Future<void> search({int page = 1}) async {
    final results = await apiManager.service.getAlbums(page, 20, searchController.text, true);
    setState(() {
      searchResultPagination = results;
    });
  }

  @override
  Widget? buildCreateNewItem(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.add),
      title: Text(lm.pick_album_create_new(searchController.text)),
      onTap: () async {
        try {
          final newAlbum = await apiManager.service.createAlbum(AlbumEditData(title: searchController.text));
          widget.onAlbumSelected(newAlbum);
          if (context.mounted) Navigator.pop(context);
        }
        catch (e, st) {
          log("An error occurred while creating album: $e", error: e, level: Level.error.value);
          if (context.mounted) ErrorHandler.showErrorDialog(context, lm.pick_album_create_error, error: e, stackTrace: st);
          return;
        }
      },
    );
  }

  @override
  Widget buildListItem(BuildContext context, Album album, int index) {
    final isSelected = widget.selectedAlbum?.id == album.id;
    return ListTile(
      leading: NetworkImageWidget(
        url: "/api/albums/${album.id}/cover?quality=64",
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
  }
}