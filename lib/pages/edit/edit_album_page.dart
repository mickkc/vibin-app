import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:vibin_app/dtos/album/album_edit_data.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/widgets/edit/image_edit_field.dart';
import 'package:vibin_app/widgets/future_content.dart';

import '../../api/api_manager.dart';
import '../../main.dart';

class EditAlbumPage extends StatefulWidget {
  final int albumId;

  const EditAlbumPage({
    super.key,
    required this.albumId
  });

  @override
  State<EditAlbumPage> createState() => _EditAlbumPageState();
}

class _EditAlbumPageState extends State<EditAlbumPage> {

  late ApiManager apiManager = getIt<ApiManager>();
  late String albumTitle;
  late String? albumCoverUrl;
  bool initialized = false;

  Future<bool> save() async {
    try {
      final editData = AlbumEditData(title: albumTitle, coverUrl: albumCoverUrl);
      await apiManager.service.updateAlbum(widget.albumId, editData);
      return true;
    }
    catch (e) {
      log("Failed to save album: $e", error: e, level: Level.error.value);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lm = AppLocalizations.of(context)!;

    final albumFuture = apiManager.service.getAlbum(widget.albumId).then((value) {
      if (initialized) return value;
      albumTitle = value.album.title;
      albumCoverUrl = null;
      initialized = true;
      return value;
    });

    return Column(
      spacing: 16,
      children: [
        Text(
          lm.edit_album_title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        FutureContent(
          future: albumFuture,
          builder: (context, albumData) {
            return Column(
              spacing: 16,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ImageEditField(
                  fallbackImageUrl: "/api/albums/${albumData.album.id}/cover",
                  imageUrl: albumCoverUrl,
                  size: 256,
                  label: lm.edit_album_cover,
                  onImageChanged: (url) {
                    setState(() {
                      albumCoverUrl = url;
                    });
                  },
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: lm.edit_album_name,
                    border: const OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: albumTitle),
                  onChanged: (value) {
                    albumTitle = value;
                  },
                ),
                Divider(),
                Row(
                  spacing: 16,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () { Navigator.pop(context); },
                      icon: const Icon(Icons.cancel),
                      label: Text(lm.dialog_cancel),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final success = await save();
                        if (success) {
                          imageCache.clear();
                          imageCache.clearLiveImages();
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.pop(context, true);
                          });
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(lm.edit_album_save_error))
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: Text(lm.dialog_save)
                    )
                  ]
                )
              ],
            );
          }
        )
      ]
    );
  }
}