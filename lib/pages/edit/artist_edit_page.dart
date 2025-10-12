import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/dtos/artist/artist_edit_data.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/pages/edit/search_artist_metadata_dialog.dart';
import 'package:vibin_app/widgets/edit/image_edit_field.dart';
import 'package:vibin_app/widgets/edit/responsive_edit_view.dart';

import '../../l10n/app_localizations.dart';
import '../../main.dart';

class ArtistEditPage extends StatefulWidget {
  final int? artistId;

  const ArtistEditPage({super.key, required this.artistId});

  @override
  State<ArtistEditPage> createState() => _ArtistEditPageState();
}

class _ArtistEditPageState extends State<ArtistEditPage> {

  late final lm = AppLocalizations.of(context)!;
  late final theme = Theme.of(context);
  final ApiManager apiManager = getIt<ApiManager>();

  String? imageUrl;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    if (widget.artistId != null) {
      apiManager.service.getArtist(widget.artistId!).then((artist) {
        setState(() {
          nameController.text = artist.name;
          descriptionController.text = artist.description;
          imageUrl = null;
        });
      })
      .catchError((error) {
        if (!mounted) return;
        log("An error occurred while loading artist: $error", error: error, level: Level.error.value);
        showErrorDialog(context, lm.edit_artist_load_error);
      });
    }
  }

  Future<void> openMetadataDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return SearchArtistMetadataDialog(
          onSelect: (artistMetadata) {
            setState(() {
              nameController.text = artistMetadata.name;
              descriptionController.text = artistMetadata.biography ?? "";
              imageUrl = artistMetadata.pictureUrl;
            });
          },
          initialSearch: nameController.text,
        );
      }
    );
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    try {
      final editData = ArtistEditData(
        name: nameController.text,
        description: descriptionController.text,
        imageUrl: imageUrl,
      );

      if (widget.artistId == null) {
        await apiManager.service.createArtist(editData);
      }
      else {
        await apiManager.service.updateArtist(widget.artistId!, editData);
      }

      if (imageUrl != null) {
        imageCache.clear();
        imageCache.clearLiveImages();
      }

      if (mounted) {
        final router = GoRouter.of(context);
        if (router.canPop()) {
          router.pop();
        }
        else {
          router.go("/artists/${widget.artistId}");
        }
      }
    }
    catch (error) {
      if (!mounted) return;
      log("An error occurred while saving artist: $error", error: error, level: Level.error.value);
      showErrorDialog(context, lm.edit_artist_save_error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ResponsiveEditView(
        title: lm.edit_artist_title,
        actions: [
          ElevatedButton.icon(
            onPressed: () {},
            label: Text(lm.dialog_delete),
            icon: Icon(Icons.delete_forever),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.errorContainer,
              foregroundColor: theme.colorScheme.onErrorContainer,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => openMetadataDialog(context),
            label: Text(lm.edit_artist_search_metadata),
            icon: Icon(Icons.search),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondaryContainer,
              foregroundColor: theme.colorScheme.onSecondaryContainer,
            ),
          ),
          ElevatedButton.icon(
            onPressed: save,
            label: Text(lm.dialog_save),
            icon: Icon(Icons.save),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
        imageEditWidget: ImageEditField(
          onImageChanged: (url) {
            setState(() {
              imageUrl = url;
            });
          },
          fallbackImageUrl: "/api/artists/${widget.artistId}/image?quality=original",
          imageUrl: imageUrl,
          label: lm.edit_artist_image,
          size: 256,
        ),
        children: [
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: lm.edit_artist_name,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return lm.edit_artist_name_validation_empty;
              }
              else if (value.length > 255) {
                return lm.edit_artist_name_validation_length;
              }
              return null;
            },
          ),
          TextFormField(
            controller: descriptionController,
            decoration: InputDecoration(
              labelText: lm.edit_artist_description,
            ),
            keyboardType: TextInputType.multiline,
            minLines: 3,
            maxLines: null,
          ),
        ],
      ),
    );
  }
}