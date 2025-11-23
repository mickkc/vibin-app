import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/dialogs/album_picker.dart';
import 'package:vibin_app/dialogs/artist_picker.dart';
import 'package:vibin_app/dtos/album/album.dart';
import 'package:vibin_app/dtos/artist/artist.dart';
import 'package:vibin_app/dtos/create_metadata.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/dtos/tags/tag.dart';
import 'package:vibin_app/dtos/track/track_edit_data.dart';
import 'package:vibin_app/dtos/uploads/pending_upload.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/pages/edit/search_lyrics_dialog.dart';
import 'package:vibin_app/pages/edit/search_track_metadata_dialog.dart';
import 'package:vibin_app/utils/dialogs.dart';
import 'package:vibin_app/utils/error_handler.dart';
import 'package:vibin_app/utils/lrc_parser.dart';
import 'package:vibin_app/widgets/edit/image_edit_field.dart';
import 'package:vibin_app/widgets/edit/nullable_int_input.dart';
import 'package:vibin_app/widgets/edit/responsive_edit_view.dart';

import '../../auth/auth_state.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/edit/tag_search_bar.dart';
import '../../widgets/tag_widget.dart';
import '../loading_overlay.dart';

class TrackEditPage extends StatefulWidget {
  final int? trackId;
  final PendingUpload? pendingUpload;

  final Function(TrackEditData)? onSave;

  const TrackEditPage({
    super.key,
    this.trackId,
    this.pendingUpload,
    this.onSave
  });

  @override
  State<TrackEditPage> createState() => _TrackEditPageState();
}

class _TrackEditPageState extends State<TrackEditPage> {

  bool initialized = false;
  late bool _isExplicit;
  late int? _trackNumber;
  late int? _trackCount;
  late int? _discNumber;
  late int? _discCount;
  late int? _year;
  late String? _imageUrl;

  late int? _trackDuration;

  late List<Tag> _tags;

  final _titleController = TextEditingController();
  final _commentController = TextEditingController();

  final _lyricsController = TextEditingController();

  late Album? _album;
  late List<Artist> _artists;

  final _apiManager = getIt<ApiManager>();
  final _authState = getIt<AuthState>();

  late final _lm = AppLocalizations.of(context)!;
  late final _theme = Theme.of(context);
  final _loadingOverlay = getIt<LoadingOverlay>();

  final _formKey = GlobalKey<FormState>();

  void _init() {
    if (widget.trackId == null) {
      setState(() {
        _titleController.text = widget.pendingUpload?.title ?? "";
        _isExplicit = widget.pendingUpload?.explicit ?? false;
        _trackNumber = widget.pendingUpload?.trackNumber;
        _trackCount = widget.pendingUpload?.trackCount;
        _discNumber = widget.pendingUpload?.discNumber;
        _discCount = widget.pendingUpload?.discCount;
        _year = widget.pendingUpload?.year;
        _imageUrl = widget.pendingUpload?.coverUrl;
        _commentController.text = widget.pendingUpload?.comment ?? "";
        _lyricsController.text = widget.pendingUpload?.lyrics ?? "";

        _album = widget.pendingUpload?.album;
        _artists = widget.pendingUpload?.artists ?? [];
        _tags = widget.pendingUpload?.tags ?? [];

        _trackDuration = null;

        initialized = true;
      });
      return;
    }

    _apiManager.service.getTrack(widget.trackId!).then((data) {
      setState(() {
        _titleController.text = data.title;
        _isExplicit = data.explicit;
        _trackNumber = data.trackNumber;
        _trackCount = data.trackCount;
        _discNumber = data.discNumber;
        _discCount = data.discCount;
        _year = data.year;
        _commentController.text = data.comment ?? "";
        _imageUrl = null;

        _album = data.album;
        _artists = data.artists;
        _tags = data.tags;

        _trackDuration = data.duration;

        initialized = true;
      });
    });

    _apiManager.service.getTrackLyrics(widget.trackId!).then((data) {
      setState(() {
        _lyricsController.text = data.lyrics ?? "";
      });
    });
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  Future<void> _showArtistPicker() async {
    await showDialog(
      context: context,
      builder: (context) {
        return ArtistPickerDialog(
          selected: _artists,
          onChanged: (artists) {
            setState(() {
              _artists = artists;
            });
          },
          allowEmpty: false,
          allowMultiple: true
        );
      }
    );
  }

  Future<void> _showAlbumPicker() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlbumPicker(
          selectedAlbum: _album,
          onAlbumSelected: (album) {
            setState(() {
              _album = album;
            });
          },
        );
      }
    );
  }

  Future<void> _searchMetadata() async {
    await showDialog(
      context: context,
      builder: (context) {
        return SearchTrackMetadataDialog(
          initialSearch: _titleController.text,
          onSelect: (metadata) async {
            _loadingOverlay.show(context);
            try {
              final createdMetadata = await _apiManager.service.createMetadata(
                CreateMetadata(
                  artistNames: metadata.artists ?? [],
                  tagNames: metadata.tags ?? [],
                  albumName: metadata.album
                )
              );

              setState(() {
                _titleController.text = metadata.title;
                _isExplicit = metadata.explicit ?? _isExplicit;
                _trackNumber = metadata.trackNumber;
                _trackCount = metadata.trackCount;
                _discNumber = metadata.discNumber;
                _discCount = metadata.discCount;
                _year = metadata.year;
                _commentController.text = metadata.comment ?? "";
                _imageUrl = metadata.coverImageUrl;
                _album = createdMetadata.album ?? _album;
                _artists = createdMetadata.artists.isNotEmpty ? createdMetadata.artists : _artists;
                _tags = createdMetadata.tags.isNotEmpty ? createdMetadata.tags : _tags;
              });
            }
            catch (e, st) {
              log("Error applying metadata: $e", error: e, level: Level.error.value);
              if (context.mounted) ErrorHandler.showErrorDialog(context, _lm.edit_track_apply_metadata_error, error: e, stackTrace: st);
            }
            finally {
              _loadingOverlay.hide();
            }
          },
        );
      }
    );
  }

  Future<void> _searchLyrics() async {
    await showDialog(
      context: context,
      builder: (context) {
        return SearchLyricsDialog(
          onSelect: (metadata) {
            setState(() {
              _lyricsController.text = metadata.content;
            });
          },
          initialSearch: "${_artists.isEmpty ? "" : "${_artists.first.name} - "}${_titleController.text}",
          duration: _trackDuration,
        );
      }
    );
  }

  Future<void> _save() async {

    if (!_formKey.currentState!.validate()) return;

    _loadingOverlay.show(context);

    try {
      final editData = TrackEditData(
        title: _titleController.text,
        explicit: _isExplicit,
        trackNumber: _trackNumber,
        trackCount: _trackCount,
        discNumber: _discNumber,
        discCount: _discCount,
        year: _year,
        comment: _commentController.text,
        imageUrl: _imageUrl,
        album: _album?.id,
        artists: _artists.map((a) => a.id).toList(),
        tags: _tags.map((t) => t.id).toList(),
        lyrics: _lyricsController.text.isEmpty ? null : _lyricsController.text
      );

      if (widget.onSave != null) {
        widget.onSave!(editData);
      }
      else if (widget.trackId != null) {
        await _apiManager.service.updateTrack(widget.trackId!, editData);
      }
      else {
        throw "Cannot save track: no track ID and no onSave callback provided";
      }

      if (mounted) Navigator.pop(context);
    }
    catch (e, st) {
      log("Error saving track: $e", error: e, level: Level.error.value);
      if (mounted) ErrorHandler.showErrorDialog(context, _lm.edit_track_save_error, error: e, stackTrace: st);
    }
    finally {
      _loadingOverlay.hide();
    }
  }

  Future<void> _delete() async {

    if (widget.trackId == null) return;

    final confirmed = await Dialogs.showConfirmDialog(context, _lm.delete_track_confirmation, _lm.delete_track_confirmation_warning);
    if (!confirmed) return;

    try {
      await _apiManager.service.deleteTrack(widget.trackId!);
      if (mounted) Navigator.pop(context);
    }
    catch (e, st) {
      log("Error deleting track: $e", error: e, level: Level.error.value);
      if (mounted) ErrorHandler.showErrorDialog(context, _lm.delete_track_error, error: e, stackTrace: st);
    }
  }

  @override
  Widget build(BuildContext context) {

    final lm = AppLocalizations.of(context)!;

    return !initialized ? Center(child: CircularProgressIndicator()) : Material(
      child: Form(
        key: _formKey,
        child: ResponsiveEditView(
          title: lm.edit_track_title,
          actions: [
            if (_authState.hasPermission(PermissionType.deleteTracks) && widget.trackId != null)
              ElevatedButton.icon(
                onPressed: _delete,
                label: Text(lm.dialog_delete),
                icon: Icon(Icons.delete_forever),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _theme.colorScheme.errorContainer,
                  foregroundColor: _theme.colorScheme.onErrorContainer,
                ),
              ),

            ElevatedButton.icon(
              onPressed: _searchMetadata,
              label: Text(lm.edit_track_search_metadata),
              icon: Icon(Icons.search),
              style: ElevatedButton.styleFrom(
                backgroundColor: _theme.colorScheme.secondaryContainer,
                foregroundColor: _theme.colorScheme.onSecondaryContainer,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _save,
              icon: Icon(Icons.save),
              label: Text(lm.dialog_save),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            )
          ],
          imageEditWidget: ImageEditField(
            imageUrl: _imageUrl,
            onImageChanged: (imageUrl) {
              setState(() {
                _imageUrl = imageUrl;
              });
            },
            fallbackImageUrl: "/api/tracks/${widget.trackId}/cover",
            size: 256,
            label: lm.edit_track_cover,
          ),
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: lm.edit_track_name,
              ),
              controller: _titleController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return lm.edit_track_name_validation_empty;
                }
                if (value.length > 255) {
                  return lm.edit_track_name_validation_length;
                }
                return null;
              },
            ),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: lm.edit_track_artists
              ),
              controller: TextEditingController(text: _artists.map((a) => a.name).join(", ")),
              onTap: _showArtistPicker,
            ),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                  labelText: lm.edit_track_album
              ),
              controller: TextEditingController(text: _album?.title ?? ""),
              onTap: _showAlbumPicker,
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: lm.edit_track_comment,
              ),
              controller: _commentController,
              maxLines: null,
            ),
            NullableIntInput(
              value: _year,
              onChanged: (yr) {
                _year = yr;
              },
              label: lm.edit_track_year,
            ),
            Row(
              spacing: 16,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.music_note),
                Expanded(
                  child: NullableIntInput(
                    value: _trackNumber,
                    onChanged: (tn) {
                      _trackNumber = tn;
                    },
                    label: lm.edit_track_number,
                  ),
                ),
                Text("/"),
                Expanded(
                  child: NullableIntInput(
                    value: _trackCount,
                    onChanged: (tc) {
                      _trackCount = tc;
                    },
                    label: lm.edit_track_count,
                  ),
                ),
              ],
            ),
            Row(
              spacing: 16,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.album),
                Expanded(
                  child: NullableIntInput(
                    value: _discNumber,
                    onChanged: (dn) {
                      _discNumber = dn;
                    },
                    label: lm.edit_track_disc_number,
                  ),
                ),
                Text("/"),
                Expanded(
                  child: NullableIntInput(
                    value: _discCount,
                    onChanged: (dc) {
                      _discCount = dc;
                    },
                    label: lm.edit_track_disc_count,
                  ),
                ),
              ],
            ),
            SwitchListTile(
              value: _isExplicit,
              onChanged: (bool value) {
                setState(() {
                  _isExplicit = value;
                });
              },
              title: Text(lm.edit_track_explicit)
            ),
            Divider(),
            Text(
              lm.tags,
              style: _theme.textTheme.headlineMedium,
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags.isEmpty ? [Text(lm.edit_track_no_tags)] : _tags.map((tag) => TagWidget(
                tag: tag,
                onTap: () async {
                  setState(() {
                    _tags.remove(tag);
                  });
                },
              )).toList()
            ),
            TagSearchBar(
              ignoredTags: _tags,
              onTagSelected: (tag) {
                setState(() {
                  _tags.add(tag);
                });
              },
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  lm.edit_track_lyrics,
                  style: _theme.textTheme.headlineMedium,
                ),
                IconButton(
                  onPressed: _searchLyrics,
                  icon: Icon(Icons.search),
                  tooltip: lm.edit_track_search_lyrics,
                )
              ],
            ),
            Text(lm.edit_track_lyrics_hint),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              controller: _lyricsController,
              maxLines: null,
              minLines: 6,
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final strAmount = await Dialogs.showInputDialog(
                  context,
                  lm.edit_track_lyrics_shift_title,
                  lm.edit_track_lyrics_shift_amount,
                  hintText: lm.edit_track_lyrics_shift_amount_hint
                );
                if (strAmount == null || strAmount.isEmpty || !context.mounted) return;

                final amount = double.tryParse(strAmount.trim().replaceFirst(",", "."));
                if (amount == null) {
                  ErrorHandler.showErrorDialog(context, lm.edit_track_lyrics_shift_amount_validation);
                  return;
                }

                final parsed = LrcParser.parseLyrics(_lyricsController.text);
                parsed.shiftAll(Duration(milliseconds: (amount * 1000).round()));
                _lyricsController.text = LrcParser.writeLrc(parsed);
              },
              label: Text(lm.edit_track_lyrics_shift_title),
              icon: Icon(Icons.schedule),
            )
          ],
        ),
      ),
    );
  }
}