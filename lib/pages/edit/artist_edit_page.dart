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

  late final _lm = AppLocalizations.of(context)!;
  late final _theme = Theme.of(context);
  final _apiManager = getIt<ApiManager>();

  String? _imageUrl;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    if (widget.artistId != null) {
      _apiManager.service.getArtist(widget.artistId!).then((artist) {
        setState(() {
          _nameController.text = artist.name;
          _descriptionController.text = artist.description;
          _imageUrl = null;
        });
      })
      .catchError((error) {
        if (!mounted) return;
        log("An error occurred while loading artist: $error", error: error, level: Level.error.value);
        showErrorDialog(context, _lm.edit_artist_load_error);
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
              _nameController.text = artistMetadata.name;
              _descriptionController.text = artistMetadata.biography ?? "";
              _imageUrl = artistMetadata.pictureUrl;
            });
          },
          initialSearch: _nameController.text,
        );
      }
    );
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    try {
      final editData = ArtistEditData(
        name: _nameController.text,
        description: _descriptionController.text,
        imageUrl: _imageUrl,
      );

      if (widget.artistId == null) {
        await _apiManager.service.createArtist(editData);
      }
      else {
        await _apiManager.service.updateArtist(widget.artistId!, editData);
      }

      if (_imageUrl != null) {
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
      showErrorDialog(context, _lm.edit_artist_save_error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ResponsiveEditView(
        title: _lm.edit_artist_title,
        actions: [
          ElevatedButton.icon(
            onPressed: () {},
            label: Text(_lm.dialog_delete),
            icon: Icon(Icons.delete_forever),
            style: ElevatedButton.styleFrom(
              backgroundColor: _theme.colorScheme.errorContainer,
              foregroundColor: _theme.colorScheme.onErrorContainer,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => openMetadataDialog(context),
            label: Text(_lm.edit_artist_search_metadata),
            icon: Icon(Icons.search),
            style: ElevatedButton.styleFrom(
              backgroundColor: _theme.colorScheme.secondaryContainer,
              foregroundColor: _theme.colorScheme.onSecondaryContainer,
            ),
          ),
          ElevatedButton.icon(
            onPressed: save,
            label: Text(_lm.dialog_save),
            icon: Icon(Icons.save),
            style: ElevatedButton.styleFrom(
              backgroundColor: _theme.colorScheme.primaryContainer,
              foregroundColor: _theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
        imageEditWidget: ImageEditField(
          onImageChanged: (url) {
            setState(() {
              _imageUrl = url;
            });
          },
          fallbackImageUrl: "/api/artists/${widget.artistId}/image?quality=original",
          imageUrl: _imageUrl,
          label: _lm.edit_artist_image,
          size: 256,
        ),
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: _lm.edit_artist_name,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return _lm.edit_artist_name_validation_empty;
              }
              else if (value.length > 255) {
                return _lm.edit_artist_name_validation_length;
              }
              return null;
            },
          ),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: _lm.edit_artist_description,
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