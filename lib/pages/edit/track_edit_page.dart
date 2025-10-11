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

import '../../auth/AuthState.dart';
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
  late bool isExplicit;
  late int? trackNumber;
  late int? trackCount;
  late int? discNumber;
  late int? discCount;
  late int? year;
  late String? imageUrl;

  late int? trackDuration;

  late List<Tag> tags;

  TextEditingController titleController = TextEditingController();
  TextEditingController commentController = TextEditingController();

  TextEditingController lyricsController = TextEditingController();

  late String? albumName;
  late List<String> artistNames;

  final ApiManager apiManager = getIt<ApiManager>();
  final AuthState authState = getIt<AuthState>();

  late final lm = AppLocalizations.of(context)!;
  late final theme = Theme.of(context);

  final formKey = GlobalKey<FormState>();

  void init() {
    if (widget.trackId == null) {
      setState(() {
        titleController.text = widget.trackTitle ?? "";
        isExplicit = widget.isExplicit ?? false;
        trackNumber = widget.trackNumber;
        trackCount = widget.trackCount;
        discNumber = widget.discNumber;
        discCount = widget.discCount;
        year = widget.year;
        titleController.text = widget.comment ?? "";
        imageUrl = widget.imageUrl;

        albumName = null;
        artistNames = [];
        tags = [];

        initialized = true;
      });
      return;
    }

    apiManager.service.getTrack(widget.trackId!).then((data) {
      setState(() {
        titleController.text = data.title;
        isExplicit = data.explicit;
        trackNumber = data.trackNumber;
        trackCount = data.trackCount;
        discNumber = data.discNumber;
        discCount = data.discCount;
        year = data.year;
        commentController.text = data.comment ?? "";
        imageUrl = null;

        albumName = data.album.title;
        artistNames = data.artists.map((a) => a.name).toList();
        tags = data.tags;

        trackDuration = data.duration;

        initialized = true;
      });
    });

    apiManager.service.getTrackLyrics(widget.trackId!).then((data) {
      setState(() {
        lyricsController.text = data.lyrics ?? "";
      });
    });
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> showArtistPicker() async {
    await showDialog(
      context: context,
      builder: (context) {
        return ArtistPickerDialog(
          selected: artistNames,
          onChanged: (artists) {
            setState(() {
              artistNames = artists;
            });
          },
          allowEmpty: false,
          allowMultiple: true
        );
      }
    );
  }

  Future<void> searchMetadata() async {
    await showDialog(
      context: context,
      builder: (context) {
        return SearchTrackMetadataDialog(
          initialSearch: titleController.text,
          onSelect: (metadata) {
            setState(() {
              titleController.text = metadata.title;
              if (metadata.explicit != null) {
                isExplicit = metadata.explicit!;
              }
              trackNumber = metadata.trackNumber;
              trackCount = metadata.trackCount;
              discNumber = metadata.discNumber;
              discCount = metadata.discCount;
              year = metadata.year;
              commentController.text = metadata.comment ?? "";
              imageUrl = metadata.coverImageUrl;
              albumName = metadata.albumName ?? albumName;
              artistNames = metadata.artistNames ?? artistNames;
            });
          },
        );
      }
    );
  }

  Future<void> searchLyrics() async {
    await showDialog(
      context: context,
      builder: (context) {
        return SearchLyricsDialog(
          onSelect: (metadata) {
            setState(() {
              lyricsController.text = metadata.content;
            });
          },
          initialSearch: "${artistNames.isEmpty ? "" : "${artistNames.first} - "}${titleController.text}",
          duration: trackDuration,
        );
      }
    );
  }

  Future<void> save() async {

    if (!formKey.currentState!.validate()) return;

    try {
      final editData = TrackEditData(
        title: titleController.text,
        explicit: isExplicit,
        trackNumber: trackNumber,
        trackCount: trackCount,
        discNumber: discNumber,
        discCount: discCount,
        year: year,
        comment: commentController.text,
        imageUrl: imageUrl,
        albumName: albumName,
        artistNames: artistNames,
        tagIds: tags.map((t) => t.id).toList(),
        lyrics: lyricsController.text.isEmpty ? null : lyricsController.text
      );

      if (widget.onSave != null) {
        widget.onSave!(editData);
      }
      else if (widget.trackId != null) {
        await apiManager.service.updateTrack(widget.trackId!, editData);
      }
      else {
        throw "Cannot save track: no track ID and no onSave callback provided";
      }

      if (mounted) Navigator.pop(context);
    }
    catch (e) {
      log("Error saving track: $e", error: e, level: Level.error.value);
      if (mounted) showErrorDialog(context, lm.edit_track_save_error);
    }
  }

  Future<List<String>> autoCompleteAlbumNames(String query) async {
    final suggestions = await apiManager.service.autocompleteAlbums(query, null);
    return suggestions;
  }

  @override
  Widget build(BuildContext context) {

    final lm = AppLocalizations.of(context)!;

    return !initialized ? CircularProgressIndicator() : Material(
      child: Form(
        key: formKey,
        child: ResponsiveEditView(
          title: lm.edit_track_title,
          actions: [
            if (authState.hasPermission(PermissionType.deleteTracks) && widget.trackId != null)
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
              onPressed: searchMetadata,
              label: Text(lm.edit_track_search_metadata),
              icon: Icon(Icons.search),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondaryContainer,
                foregroundColor: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            ElevatedButton.icon(
              onPressed: save,
              icon: Icon(Icons.save),
              label: Text(lm.dialog_save),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            )
          ],
          imageEditWidget: ImageEditField(
            imageUrl: imageUrl,
            onImageChanged: (imageUrl) {
              setState(() {
                this.imageUrl = imageUrl;
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
              controller: titleController,
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
              controller: TextEditingController(text: artistNames.join(", ")),
              onTap: showArtistPicker,
            ),
            TypeAheadField<String>(
              controller: TextEditingController(text: albumName),
              builder: (context, controller, focusNode) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: lm.edit_track_album,
                  ),
                  onChanged: (value) {
                    albumName = value;
                  },
                );
              },
              itemBuilder: (context, suggestion) {
                return ListTile(title: Text(suggestion));
              },
              onSelected: (album) {
                setState(() {
                  albumName = album;
                });
              },
              suggestionsCallback: (pattern) {
                if (pattern.trim().length < 2) return [];
                return autoCompleteAlbumNames(pattern);
              }
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: lm.edit_track_comment,
              ),
              controller: commentController,
              maxLines: null,
            ),
            NullableIntInput(
              value: year,
              onChanged: (yr) {
                year = yr;
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
                    value: trackNumber,
                    onChanged: (tn) {
                      trackNumber = tn;
                    },
                    label: lm.edit_track_number,
                  ),
                ),
                Text("/"),
                Expanded(
                  child: NullableIntInput(
                    value: trackCount,
                    onChanged: (tc) {
                      trackCount = tc;
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
                    value: discNumber,
                    onChanged: (dn) {
                      discNumber = dn;
                    },
                    label: lm.edit_track_disc_number,
                  ),
                ),
                Text("/"),
                Expanded(
                  child: NullableIntInput(
                    value: discCount,
                    onChanged: (dc) {
                      discCount = dc;
                    },
                    label: lm.edit_track_disc_count,
                  ),
                ),
              ],
            ),
            SwitchListTile(
              value: isExplicit,
              onChanged: (bool value) {
                setState(() {
                  isExplicit = value;
                });
              },
              title: Text(lm.edit_track_explicit)
            ),
            Divider(),
            Text(
              lm.tags,
              style: theme.textTheme.headlineMedium,
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.isEmpty ? [Text(lm.edit_track_no_tags)] : tags.map((tag) => Tooltip(
                message: tag.description,
                child: TagWidget(
                  tag: tag,
                  onTap: () async {
                    setState(() {
                      tags.remove(tag);
                    });
                  },
                )
              )).toList()
            ),
            TagSearchBar(
              ignoredTags: tags,
              onTagSelected: (tag) {
                setState(() {
                  tags.add(tag);
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
                  style: theme.textTheme.headlineMedium,
                ),
                IconButton(
                  onPressed: searchLyrics,
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
              controller: lyricsController,
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

                final parsed = LrcParser.parseLyrics(lyricsController.text);
                parsed.shiftAll(Duration(milliseconds: (amount * 1000).round()));
                lyricsController.text = LrcParser.writeLrc(parsed);
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