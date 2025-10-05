import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:vibin_app/dtos/album/album_edit_data.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/pages/edit/search_album_metadata_dialog.dart';
import 'package:vibin_app/widgets/edit/image_edit_field.dart';
import 'package:vibin_app/widgets/edit/responsive_edit_view.dart';

import '../../api/api_manager.dart';
import '../../main.dart';

class AlbumEditPage extends StatefulWidget {
  final int albumId;

  const AlbumEditPage({
    super.key,
    required this.albumId
  });

  @override
  State<AlbumEditPage> createState() => _AlbumEditPageState();
}

class _AlbumEditPageState extends State<AlbumEditPage> {

  late ApiManager apiManager = getIt<ApiManager>();
  late String? albumCoverUrl;

  late final lm = AppLocalizations.of(context)!;
  late final theme = Theme.of(context);

  bool initialized = false;

  final formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController yearController;

  final yearRegexp = RegExp(r'^\d{4}$');

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    yearController = TextEditingController();

    apiManager.service.getAlbum(widget.albumId).then((value) {
      setState(() {
        titleController.text = value.album.title;
        descriptionController.text = value.album.description;
        yearController.text = value.album.year?.toString() ?? "";
        albumCoverUrl = null;
        initialized = true;
      });
      return;
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    yearController.dispose();
    super.dispose();
  }
  
  void showMetadataDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SearchAlbumMetadataDialog(onSelect: (metadata) {
          setState(() {
            titleController.text = metadata.title;
            descriptionController.text = metadata.description ?? "";
            yearController.text = metadata.year?.toString() ?? "";
            albumCoverUrl = metadata.coverImageUrl;
          });
        }, initialSearch: titleController.text);
      }
    );
  }

  Future<void> save() async {

    if (!formKey.currentState!.validate()) return;

    try {
      final editData = AlbumEditData(
        title: titleController.text,
        description: descriptionController.text,
        year: yearController.text.isEmpty ? null : int.tryParse(yearController.text),
        coverUrl: albumCoverUrl
      );
      await apiManager.service.updateAlbum(widget.albumId, editData);
      imageCache.clear();
      imageCache.clearLiveImages();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context, true);
      });
    }
    catch (e) {
      log("Failed to save album: $e", error: e, level: Level.error.value);
      if (mounted) showErrorDialog(context, lm.edit_album_save_error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return !initialized ? Center(child: CircularProgressIndicator()) : Material(
      child: Form(
        key: formKey,
        child: ResponsiveEditView(
          title: lm.edit_album_title,
          imageEditWidget: ImageEditField(
            onImageChanged: (albumCoverUrl) {
              setState(() {
                this.albumCoverUrl = albumCoverUrl;
              });
            },
            fallbackImageUrl: "/api/albums/${widget.albumId}/cover",
            imageUrl: albumCoverUrl,
            size: 256,
            label: lm.edit_album_cover,
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: () { Navigator.pop(context); },
              icon: const Icon(Icons.cancel),
              label: Text(lm.dialog_cancel),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondaryContainer,
                foregroundColor: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            ElevatedButton.icon(
              onPressed: showMetadataDialog,
              icon: const Icon(Icons.search),
              label: Text(lm.edit_album_search_metadata),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondaryContainer,
                foregroundColor: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            ElevatedButton.icon(
              onPressed: save,
              icon: const Icon(Icons.save),
              label: Text(lm.dialog_save),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
              ),
            )
          ],
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: lm.edit_album_name,
              ),
              controller: titleController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return lm.edit_album_name_validation_empty;
                }
                if (value.length > 255) {
                  return lm.edit_album_name_validation_length;
                }
                return null;
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: lm.edit_album_description,
              ),
              controller: descriptionController,
              maxLines: null,
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: lm.edit_album_year,
              ),
              controller: yearController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return null;
                }
                if (!yearRegexp.hasMatch(value)) {
                  return lm.edit_album_year_validation_not_number;
                }
                return null;
              }
            )
          ],
        ),
      ),
    );
  }
}