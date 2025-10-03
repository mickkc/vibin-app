import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:logger/logger.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/dialogs/artist_picker.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/dtos/track/track_edit_data.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/pages/edit/search_metadata_dialog.dart';
import 'package:vibin_app/widgets/edit/image_edit_field.dart';
import 'package:vibin_app/widgets/edit/nullable_int_input.dart';
import 'package:vibin_app/widgets/edit/responsive_edit_view.dart';

import '../../auth/AuthState.dart';
import '../../l10n/app_localizations.dart';

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
  late String trackTitle;
  late bool isExplicit;
  late int? trackNumber;
  late int? trackCount;
  late int? discNumber;
  late int? discCount;
  late int? year;
  late String comment;
  late String? imageUrl;

  late String? albumName;
  late List<String> artistNames;

  final ApiManager apiManager = getIt<ApiManager>();
  final AuthState authState = getIt<AuthState>();

  void init() {
    if (initialized) return;

    if (widget.trackId == null) {
      setState(() {
        trackTitle = widget.trackTitle ?? "";
        isExplicit = widget.isExplicit ?? false;
        trackNumber = widget.trackNumber;
        trackCount = widget.trackCount;
        discNumber = widget.discNumber;
        discCount = widget.discCount;
        year = widget.year;
        comment = widget.comment ?? "";
        imageUrl = widget.imageUrl;

        albumName = null;
        artistNames = [];

        initialized = true;
      });
      return;
    }

    apiManager.service.getTrack(widget.trackId!).then((data) {
      setState(() {
        trackTitle = data.title;
        isExplicit = data.explicit;
        trackNumber = data.trackNumber;
        trackCount = data.trackCount;
        discNumber = data.discNumber;
        discCount = data.discCount;
        year = data.year;
        comment = data.comment ?? "";
        imageUrl = null;

        albumName = data.album.title;
        artistNames = data.artists.map((a) => a.name).toList();

        initialized = true;
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
          initialSearch: trackTitle,
          onSelect: (metadata) {
            setState(() {
              trackTitle = metadata.title;
              if (metadata.explicit != null) {
                isExplicit = metadata.explicit!;
              }
              trackNumber = metadata.trackNumber;
              trackCount = metadata.trackCount;
              discNumber = metadata.discNumber;
              discCount = metadata.discCount;
              year = metadata.year;
              comment = metadata.comment ?? comment;
              imageUrl = metadata.coverImageUrl;
            });
          },
        );
      }
    );
  }

  Future<bool> save() async {
    try {
      final editData = TrackEditData(
        title: trackTitle,
        explicit: isExplicit,
        trackNumber: trackNumber,
        trackCount: trackCount,
        discNumber: discNumber,
        discCount: discCount,
        year: year,
        comment: comment,
        imageUrl: imageUrl,
        albumName: albumName,
        artistNames: artistNames,
        tagNames: null,
      );
      if (widget.onSave != null) {
        widget.onSave!(editData);
      } else if (widget.trackId != null) {
        await apiManager.service.updateTrack(widget.trackId!, editData);
      } else {
        throw "Cannot save track: no track ID and no onSave callback provided";
      }
      return true;
    }
    catch (e) {
      log("Error saving track: $e", error: e, level: Level.error.value);
      return false;
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
      child: ResponsiveEditView(
        title: lm.edit_track_title,
        actions: [
          if (authState.hasPermission(PermissionType.deleteTracks) && widget.trackId != null)
            ElevatedButton.icon(
              onPressed: () {},
              label: Text(lm.dialog_delete),
              icon: Icon(Icons.delete_forever),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),

          ElevatedButton.icon(
            onPressed: () async { await searchMetadata(); },
            label: Text(lm.edit_track_search_metadata),
            icon: Icon(Icons.search),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final success = await save();
              if (success) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
              else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(lm.edit_track_save_error))
                  );
                }
              }
            },
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
          TextField(
            decoration: InputDecoration(
              labelText: lm.edit_track_name,
            ),
            controller: TextEditingController(text: trackTitle),
            onChanged: (value) {
              trackTitle = value;
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
          TextField(
            decoration: InputDecoration(
              labelText: lm.edit_track_comment,
            ),
            controller: TextEditingController(text: comment),
            onChanged: (value) {
              comment = value;
            },
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
          )
        ],
      ),
    );
  }
}