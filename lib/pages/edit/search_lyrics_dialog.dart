import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/dtos/lyrics_metadata.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/pages/edit/base_metadata_dialog.dart';
import 'package:vibin_app/settings/setting_definitions.dart';
import 'package:vibin_app/utils/dialogs.dart';

import '../../l10n/app_localizations.dart';

class SearchLyricsDialog extends StatelessWidget {
  final String? initialSearch;
  final int? duration;
  final Function(LyricsMetadata) onSelect;

  const SearchLyricsDialog({
    super.key,
    this.initialSearch,
    required this.onSelect,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final apiManager = getIt<ApiManager>();
    final lm = AppLocalizations.of(context)!;

    return BaseMetadataDialog(
      onSelect: onSelect,
      fetchMethod: (q, p) => apiManager.service.searchLyricsMetadata(q, p),
      itemBuilder: (context, item, onTap) {

        final durationDiff = duration == null || item.duration == null ? null : (duration! - item.duration!).abs();
        final subtitle = "${item.artistName != null ? "${item.artistName}, " : ""}"
          "${item.albumName != null ? "${item.albumName}, " : ""}"
          "${durationDiff == null ? "" : "${durationDiff < 0 ? "-" : "+"}${durationDiff / 1000}s, "}"
          "${item.synced ? lm.edit_track_lyrics_synced : lm.edit_track_lyrics_unsynced}";

        return ListTile(
          title: Text(item.title),
          subtitle: Text(subtitle),
          onTap: onTap,
          trailing: IconButton(
            onPressed: () {
              Dialogs.showMessageDialog(context, lm.edit_track_lyrics, item.content);
            },
            icon: Icon(Icons.read_more),
          tooltip: lm.edit_track_lyrics_open,
        ),);
      },
      sourceSelector: (sources) => sources.lyrics,
      initialSearch: initialSearch,
      defaultProviderSettingKey: Settings.lyricsProvider,
    );
  }
}