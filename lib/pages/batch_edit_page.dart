import 'dart:math';

import 'package:flutter/material.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/batch/batch_action_interface.dart';
import 'package:vibin_app/batch/change_album_action.dart';
import 'package:vibin_app/batch/playlist_action.dart';
import 'package:vibin_app/batch/regenerate_file_metadata_action.dart';
import 'package:vibin_app/batch/regex_replace_action.dart';
import 'package:vibin_app/batch/reset_listening_duration_action.dart';
import 'package:vibin_app/batch/tags_action.dart';
import 'package:vibin_app/dtos/batch/batch_edit.dart';
import 'package:vibin_app/dtos/track/minimal_track.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/pages/column_page.dart';
import 'package:vibin_app/widgets/batch_changes_dialog.dart';
import 'package:vibin_app/widgets/entity_card.dart';

import '../sections/section_header.dart';

class BatchEditPage extends StatefulWidget {

  const BatchEditPage({super.key});

  @override
  State<BatchEditPage> createState() => _BatchEditPageState();
}

class _BatchEditPageState extends State<BatchEditPage> {

  late final _lm = AppLocalizations.of(context)!;
  late final _api = getIt<ApiManager>();

  bool _useAdvancedQuery = false;
  late TextEditingController _searchQueryTextController;
  int _currentPage = 1;
  int _totalTracks = 1;
  List<MinimalTrack> _currentTracks = [];
  final List<int> _selectedTracks = [];
  final List<BatchAction> _actions = [];

  late final _cs = Theme.of(context).colorScheme;

  Map<String, BatchAction Function()> _actionMap = {};

  @override
  void initState() {
    _searchQueryTextController = TextEditingController(text: "");

    super.initState();
  }

  void _fillActionMap() {
    if (_actionMap.isNotEmpty) return;
    _actionMap = {
      _lm.batch_edit_actions_change_album: () { return ChangeAlbumAction(); },
      _lm.batch_edit_actions_add_to_playlist: () { return PlaylistAction(false); },
      _lm.batch_edit_actions_remove_from_playlist: () { return PlaylistAction(true); },
      _lm.batch_edit_actions_add_tags: () { return TagsAction(false); },
      _lm.batch_edit_actions_remove_tags: () { return TagsAction(true); },
      _lm.batch_edit_actions_change_title: () { return RegexReplaceAction("TITLE", _lm.batch_edit_actions_change_title); },
      _lm.batch_edit_actions_change_comment: () { return RegexReplaceAction("CHANGE_COMMENT", _lm.batch_edit_actions_change_comment); },
      _lm.batch_edit_actions_remove_listen_duration: () { return ResetListeningDurationAction(); },
      _lm.batch_edit_actions_regenerate_file_metadata: () { return RegenerateFileMetadataAction(); },
    };
  }

  void _search() async {
    try {
      final tracks = await _api.service.searchTracks(_searchQueryTextController.text, _useAdvancedQuery, 1, 50);
      setState(() {
        _currentTracks = tracks.items;
        _currentPage = tracks.currentPage;
        _totalTracks = tracks.total;
      });
    }
    catch (e, st) {
      logger.handle(e, st, _useAdvancedQuery ? _lm.batch_edit_track_advanced_search_failed : _lm.batch_edit_track_search_failed);
    }
  }

  void _loadMore() async {
    try {
      final tracks = await _api.service.searchTracks(_searchQueryTextController.text, _useAdvancedQuery, _currentPage + 1, 50);
      setState(() {
        _currentTracks.addAll(tracks.items);
        _currentPage += 1;
        _totalTracks = tracks.total;
      });
    }
    catch (e, st) {
      logger.handle(e, st, _useAdvancedQuery ? _lm.batch_edit_track_advanced_search_failed : _lm.batch_edit_track_search_failed);
    }
  }

  void _toggleTrackSelected(int id) {
    setState(() {
      if (_selectedTracks.contains(id)) {
        _selectedTracks.remove(id);
      }
      else {
        _selectedTracks.add(id);
      }
    });
  }

  void _addAction() {
    _fillActionMap();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_lm.batch_edit_actions_title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: _actionMap.entries.map((action) {
            return TextButton(
              onPressed: () {
                setState(() {
                  _actions.add(action.value());
                });
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: _cs.secondaryContainer,
                foregroundColor: _cs.onSecondaryContainer
              ),
              child: Text(action.key),
            );
          }).toList(),
        )
      )
    );
  }

  void _removeAction(BatchAction action) {
    setState(() {
      _actions.remove(action);
    });
  }

  void _run(bool dry) async {
    final dto = BatchEdit(
      _useAdvancedQuery ? null : _selectedTracks,
      _useAdvancedQuery ? _searchQueryTextController.text : null,
      _actions.map((a) => a.dataToJson()).toList(),
      dry
    );

    try {
      final result = await _api.service.batchEditTracks(dto);
      if (mounted) BatchChangesDialog.show(context, result, dto);
    }
    catch (e, st) {
      logger.handle(e, st, _lm.batch_edit_run_error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColumnPage(
      spacing: 8,
      children: [

/*        Row(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(_lm.batch_edit_selection_source),
            DropdownMenu(
              width: null,
              initialSelection: _useAdvancedQuery,
              onSelected: (value) {
                if (value is bool) {
                  setState(() {
                    _useAdvancedQuery = value;
                  });
                }
              },
              dropdownMenuEntries: [
                DropdownMenuEntry(value: false, label: _lm.batch_edit_selection_manual),
                DropdownMenuEntry(value: true, label: _lm.batch_edit_selection_search_language),
              ],
            ),
            if (_useAdvancedQuery)
              IconButton(
                onPressed: () => launchUrl(Uri.parse("https://codeberg.org/mickkc/vibin/wiki/Search%20Language.md")),
                icon: const Icon(Icons.chrome_reader_mode),
                tooltip: _lm.batch_edit_search_language_open_wiki,
              )
          ],
        ),*/

        SectionHeader(
          title: _lm.batch_edit_selection_source,
          trailing: DropdownMenu(
            width: null,
            initialSelection: _useAdvancedQuery,
            onSelected: (value) {
              if (value is bool) {
                setState(() {
                  _useAdvancedQuery = value;
                });
              }
            },
            dropdownMenuEntries: [
              DropdownMenuEntry(value: false, label: _lm.batch_edit_selection_manual),
              DropdownMenuEntry(value: true, label: _lm.batch_edit_selection_search_language),
            ],
          ),
        ),

        TextField(
          controller: _searchQueryTextController,
          decoration: InputDecoration(
            labelText: _lm.search,
            prefixIcon: Icon(Icons.search)
          ),
          onEditingComplete: _search,
        ),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            _useAdvancedQuery
                ? _lm.batch_edit_found_track_amount(_totalTracks)
                : _lm.batch_edit_selected_track_amount(_selectedTracks.length),
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),

        SizedBox(
          height: 205,
          child: _currentTracks.isNotEmpty ? SuperListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _currentTracks.length + 1,
            itemBuilder: (context, index) {

              if (index == _currentTracks.length) {

                if (_currentTracks.length >= _totalTracks) {
                  return SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsetsGeometry.symmetric(horizontal: 4.0),
                  child: Center(
                    child: OutlinedButton(
                      onPressed: _loadMore,
                      child: Text(_lm.batch_edit_tracks_load_more)
                    ),
                  ),
                );
              }


              final track = _currentTracks[index];
              return Padding(
                key: Key("batch-track-${track.id}"),
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: EntityCard(
                  entity: track,
                  type: EntityCardType.track,
                  onTap: (){
                    _toggleTrackSelected(track.id);
                  },
                  badge: _useAdvancedQuery ? null : Container(
                    color: _cs.surface,
                    child: Icon(
                      _selectedTracks.contains(track.id) ? Icons.check_box : Icons.check_box_outline_blank,
                      color: _selectedTracks.contains(track.id) ? _cs.primary : _cs.secondary,
                    )
                  ),
                ),
              );
            },
          ) : Card(
            child: Center(
              child: Text(_lm.batch_edit_tracks_empty, textAlign: TextAlign.center),
            ),
          ),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Divider(),
        ),

        SectionHeader(
          title: _lm.batch_edit_actions_title,
          trailing: IconButton(
            onPressed: _addAction,
            icon: const Icon(Icons.add)
          ),
        ),

        SuperListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: max(_actions.length, 1),
          itemBuilder: (context, index) {

            if (_actions.isEmpty) {
              return Card(
                child: SizedBox(
                  height: 205,
                  child: Center(
                    child: Text(_lm.batch_edit_actions_empty, textAlign: TextAlign.center),
                  ),
                ),
              );
            }

            final action = _actions[index];

            return Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            action.getName(_lm),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _removeAction(action);
                          },
                          icon: const Icon(Icons.close)
                        )
                      ],
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: action.build(context),
                    )
                  ],
                ),
              ),
            );
          }
        ),

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Divider(),
        ),

        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed: (){ _run(true); },
              icon: const Icon(Icons.remove_red_eye),
              label: Text(_lm.batch_edit_dry_run),
              style: ElevatedButton.styleFrom(
                backgroundColor: _cs.primaryContainer,
                foregroundColor: _cs.onPrimaryContainer,
              ),
            ),
            ElevatedButton.icon(
              onPressed: (){ _run(false); },
              label: Text(_lm.batch_edit_run),
              icon: const Icon(Icons.play_arrow),
            )
          ],
        )
      ]
    );
  }

}