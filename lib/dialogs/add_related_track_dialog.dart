import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/dtos/pagination/minimal_track_pagination.dart';
import 'package:vibin_app/dtos/track/minimal_track.dart';
import 'package:vibin_app/dtos/track/related_track.dart';
import 'package:vibin_app/dtos/track/track.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/settings/setting_definitions.dart';
import 'package:vibin_app/utils/error_handler.dart';
import 'package:vibin_app/widgets/entity_card.dart';
import 'package:vibin_app/widgets/future_content.dart';
import 'package:vibin_app/widgets/network_image.dart';
import 'package:vibin_app/widgets/pagination_footer.dart';

import '../settings/settings_manager.dart';

class AddRelatedTrackDialog extends StatefulWidget {

  final int trackId;
  final List<int> relatedTrackIds;
  final void Function(RelatedTrack) onTrackAdded;

  const AddRelatedTrackDialog({
    super.key,
    required this.trackId,
    required this.relatedTrackIds,
    required this.onTrackAdded,
  });

  static Future<void> show(BuildContext context, int trackId, List<int> relatedTrackIds, void Function(RelatedTrack) onTrackAdded) {
    return showDialog(
      context: context,
      builder: (context) => AddRelatedTrackDialog(
        trackId: trackId,
        relatedTrackIds: relatedTrackIds,
        onTrackAdded: onTrackAdded,
      )
    );
  }

  @override
  State<AddRelatedTrackDialog> createState() => _AddRelatedTrackDialogState();
}

class _AddRelatedTrackDialogState extends State<AddRelatedTrackDialog> {

  final _searchController = TextEditingController();
  final _relationDescriptionController = TextEditingController();
  final _reverseDescriptionController = TextEditingController();
  bool _mutualRelation = false;

  final _formKey = GlobalKey<FormState>();

  late final _lm = AppLocalizations.of(context)!;
  late final _theme = Theme.of(context);

  final _apiManager = getIt<ApiManager>();
  final _settingsManager = getIt<SettingsManager>();

  late Future<MinimalTrackPagination> _searchResults;

  void _searchTracks(int page) async {
      _searchResults = _apiManager.service.searchTracks(
      _searchController.text,
      _settingsManager.get(Settings.advancedTrackSearch),
      page,
      _settingsManager.get(Settings.pageSize)
    );
  }

  Timer? _searchDebounce;

  Track? _currentTrack;
  MinimalTrack? _selectedTrack;

  @override
  void initState() {
    super.initState();
    _searchTracks(1);

    _apiManager.service.getTrack(widget.trackId).then((track) {
      setState(() {
        _currentTrack = track;
      });
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedTrack == null || _currentTrack == null) {
      return;
    }

    try {
      final response = await _apiManager.service.addRelatedTrack(
        widget.trackId,
        _selectedTrack!.id,
        _relationDescriptionController.text,
        _mutualRelation,
        _mutualRelation ? _reverseDescriptionController.text : null,
      );

      if (!response.success) {
        throw Exception("Failed to add related track: success was false");
      }

      widget.onTrackAdded(RelatedTrack(
          track: _selectedTrack!,
          relationDescription: _relationDescriptionController.text)
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
    catch (e, st) {
      log("Error adding related track", error: e, stackTrace: st);
      if (mounted) {
        ErrorHandler.showErrorDialog(context, _lm.edit_related_tracks_add_error, error: e, stackTrace: st);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    return AlertDialog(
      constraints: BoxConstraints(
        maxWidth: 600,
        maxHeight: 800,
      ),
      title: Text(_lm.edit_related_tracks_add),
      content: Column(
        spacing: 8,
        children: [
          TextFormField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: _lm.search,
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (value) {
              if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
              _searchDebounce = Timer(const Duration(milliseconds: 500), () {
                setState(() {
                  _searchTracks(1);
                });
              });
            },
          ),

          Expanded(
            child: SizedBox(
              width: width > 600 ? 600 : width - 40,
              child: FutureContent(
                future: _searchResults,
                builder: (context, tracks) {
                  return SuperListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: tracks.items.length,
                    itemBuilder: (context, index) {
                      final searchResult = tracks.items[index];
                      final isAlreadyRelated = widget.relatedTrackIds.contains(searchResult.id);
                      final isCurrentTrack = widget.trackId == searchResult.id;
                      final isSelected = _selectedTrack?.id == searchResult.id;
                      return ListTile(
                        leading: NetworkImageWidget(
                          url: "/api/tracks/${searchResult.id}/cover?size=64",
                          width: 48,
                          height: 48,
                        ),
                        title: Text(searchResult.title),
                        subtitle: Text(searchResult.artists.map((e) => e.name).join(", ")),
                        trailing: IconButton(
                          onPressed: (isAlreadyRelated || isCurrentTrack) ? null : () async {
                            setState(() {
                              _selectedTrack = searchResult;
                            });
                          },
                          icon: Icon(
                            Icons.check,
                            color: isSelected
                                ? _theme.colorScheme.primary
                                : (isAlreadyRelated || isCurrentTrack)
                                  ? _theme.colorScheme.onSurfaceVariant
                                  : _theme.colorScheme.onSurface,
                          )
                        ),
                      );
                    },
                  );
                }
              )
            ),
          ),

          FutureContent(
            future: _searchResults,
            builder: (context, pag) {
              return PaginationFooter(
                pagination: pag,
                onPageChanged: (page) => setState(() {
                  _searchTracks(page);
                })
              );
            }
          ),

          const Divider(),

          if (_currentTrack != null && _selectedTrack != null)
            Form(
              key: _formKey,
              child: SizedBox(
                height: 210,
                child: Row(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (width > 600)
                      EntityCard(
                        type: EntityCardType.track,
                        entity: _currentTrack!,
                        coverSize: 128,
                      ),
                    Expanded(
                      child: Column(
                        spacing: 8,
                        children: [
                          TextFormField(
                            controller: _relationDescriptionController,
                            decoration: InputDecoration(
                              labelText: _lm.edit_related_tracks_relation_description,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return _lm.edit_related_tracks_relation_description_required;
                              }
                              return null;
                            },
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: _mutualRelation,
                                onChanged: (value) {
                                  setState(() {
                                    _mutualRelation = value ?? false;
                                  });
                                },
                              ),
                              Expanded(
                                child: TextFormField(
                                  enabled: _mutualRelation,
                                  controller: _reverseDescriptionController,
                                  decoration: InputDecoration(
                                    labelText: _lm.edit_related_tracks_reverse_description,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          FilledButton(
                            onPressed: _save,
                            child: Text(_lm.dialog_save)
                          )
                        ],
                      ),
                    ),
                    if (width > 600)
                      EntityCard(
                        type: EntityCardType.track,
                        entity: _selectedTrack!,
                        coverSize: 128,
                      ),
                  ],
                ),
              )
            )
        ],
      ),
    );
  }
}