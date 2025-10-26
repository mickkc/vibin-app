import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:logger/logger.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/dialogs/artist_picker.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/dtos/track/track_edit_data.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/pages/edit/search_lyrics_dialog.dart';
import 'package:vibin_app/pages/edit/search_track_metadata_dialog.dart';
import 'package:vibin_app/utils/lrc_parser.dart';
import 'package:vibin_app/widgets/edit/image_edit_field.dart';
import 'package:vibin_app/widgets/edit/nullable_int_input.dart';
import 'package:vibin_app/widgets/edit/responsive_edit_view.dart';
import 'package:vibin_app/widgets/edit/tag_search_bar.dart';

import '../../auth/auth_state.dart';
import '../../dtos/tags/tag.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/tag_widget.dart';

class TrackEditPage extends StatefulWidget {
  final int? trackId;

  final String? trackTitle;
  final bool? isExplicit;
  final int? trackNumber;
  final int? trackCount;
  final int? discNumber;
  final int? discCount;
  final int? year;
  final String? comment;
  final String? imageUrl;

  final Function(TrackEditData)? onSave;

  const TrackEditPage({
    super.key,
    required this.trackId,
    this.trackTitle,
    this.isExplicit,
    this.trackNumber,
    this.trackCount,
    this.discNumber,
    this.discCount,
    this.year,
    this.comment,
    this.imageUrl,
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

  late String? _albumName;
  late List<String> _artistNames;

  final _apiManager = getIt<ApiManager>();
  final _authState = getIt<AuthState>();

  late final _lm = AppLocalizations.of(context)!;
  late final _theme = Theme.of(context);

  final _formKey = GlobalKey<FormState>();

  void _init() {
    if (widget.trackId == null) {
      setState(() {
        _titleController.text = widget.trackTitle ?? "";
        _isExplicit = widget.isExplicit ?? false;
        _trackNumber = widget.trackNumber;
        _trackCount = widget.trackCount;
        _discNumber = widget.discNumber;
        _discCount = widget.discCount;
        _year = widget.year;
        _titleController.text = widget.comment ?? "";
        _imageUrl = widget.imageUrl;

        _albumName = null;
        _artistNames = [];
        _tags = [];

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

        _albumName = data.album.title;
        _artistNames = data.artists.map((a) => a.name).toList();
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
          selected: _artistNames,
          onChanged: (artists) {
            setState(() {
              _artistNames = artists;
            });
          },
          allowEmpty: false,
          allowMultiple: true
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
          onSelect: (metadata) {
            setState(() {
              _titleController.text = metadata.title;
              if (metadata.explicit != null) {
                _isExplicit = metadata.explicit!;
              }
              _trackNumber = metadata.trackNumber;
              _trackCount = metadata.trackCount;
              _discNumber = metadata.discNumber;
              _discCount = metadata.discCount;
              _year = metadata.year;
              _commentController.text = metadata.comment ?? "";
              _imageUrl = metadata.coverImageUrl;
              _albumName = metadata.albumName ?? _albumName;
              _artistNames = metadata.artistNames ?? _artistNames;
            });
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
          initialSearch: "${_artistNames.isEmpty ? "" : "${_artistNames.first} - "}${_titleController.text}",
          duration: _trackDuration,
        );
      }
    );
  }

  Future<void> _save() async {

    if (!_formKey.currentState!.validate()) return;

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
        albumName: _albumName,
        artistNames: _artistNames,
        tagIds: _tags.map((t) => t.id).toList(),
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
    catch (e) {
      log("Error saving track: $e", error: e, level: Level.error.value);
      if (mounted) showErrorDialog(context, _lm.edit_track_save_error);
    }
  }

  Future<void> _delete() async {

    if (widget.trackId == null) return;

    final confirmed = await showConfirmDialog(context, _lm.delete_track_confirmation, _lm.delete_track_confirmation_warning);
    if (!confirmed) return;

    try {
      await _apiManager.service.deleteTrack(widget.trackId!);
      if (mounted) Navigator.pop(context);
    }
    catch (e) {
      log("Error deleting track: $e", error: e, level: Level.error.value);
      if (mounted) showErrorDialog(context, _lm.delete_track_error);
    }
  }

  Future<List<String>> _autoCompleteAlbumNames(String query) async {
    final suggestions = await _apiManager.service.autocompleteAlbums(query, null);
    return suggestions;
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
                this._imageUrl = imageUrl;
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
              controller: TextEditingController(text: _artistNames.join(", ")),
              onTap: _showArtistPicker,
            ),
            TypeAheadField<String>(
              controller: TextEditingController(text: _albumName),
              builder: (context, controller, focusNode) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: lm.edit_track_album,
                  ),
                  onChanged: (value) {
                    _albumName = value;
                  },
                );
              },
              itemBuilder: (context, suggestion) {
                return ListTile(title: Text(suggestion));
              },
              onSelected: (album) {
                setState(() {
                  _albumName = album;
                });
              },
              suggestionsCallback: (pattern) {
                if (pattern.trim().length < 2) return [];
                return _autoCompleteAlbumNames(pattern);
              }
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
              children: _tags.isEmpty ? [Text(lm.edit_track_no_tags)] : _tags.map((tag) => Tooltip(
                message: tag.description,
                child: TagWidget(
                  tag: tag,
                  onTap: () async {
                    setState(() {
                      _tags.remove(tag);
                    });
                  },
                )
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
                final strAmount = await showInputDialog(
                  context,
                  lm.edit_track_lyrics_shift_title,
                  lm.edit_track_lyrics_shift_amount,
                  hintText: lm.edit_track_lyrics_shift_amount_hint
                );
                if (strAmount == null || strAmount.isEmpty || !context.mounted) return;

                final amount = double.tryParse(strAmount.trim().replaceFirst(",", "."));
                if (amount == null) {
                  showErrorDialog(context, lm.edit_track_lyrics_shift_amount_validation);
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