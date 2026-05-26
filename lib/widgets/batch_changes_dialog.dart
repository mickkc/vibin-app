import 'package:flutter/material.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:vibin_app/dtos/batch/batch_edit.dart';
import 'package:vibin_app/dtos/batch/batch_edit_result.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/utils/image_utils.dart';
import 'package:vibin_app/widgets/network_image.dart';

class BatchChangesDialog extends StatelessWidget {
  final BatchEditResult result;
  final BatchEdit edit;

  const BatchChangesDialog(this.result, this.edit, {super.key});

  static void show(BuildContext context, BatchEditResult result, BatchEdit edit) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: BatchChangesDialog(result, edit),
          ),
        );
      }
    );
  }

  String _localizeType(String type, AppLocalizations lm) {
    switch (type) {
      case "TAGS":
        return lm.tags;
      case "PLAYLIST":
        return lm.playlist;
      case "NAME":
        return lm.edit_track_title;
      case "COMMENT":
        return lm.edit_track_comment;
      case "LISTEN_DURATION":
        return lm.stats_total_listen_duration;
      case "FILE_METADATA":
        return lm.batch_edit_report_field_file_metadata;
      case "ALBUM":
        return lm.album;
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {

    final lm = AppLocalizations.of(context)!;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final tracks = result.changes.map((c) => c.track).toSet().toList();

    return Column(
      spacing: 0,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${lm.batch_edit_report_affected_tracks}: ${result.affectedTracks}",
          style: tt.bodyLarge
        ),
        Text(
          "${lm.batch_edit_report_affected_fields}: ${result.affectedFields}",
          style: tt.bodyMedium,
        ),
        Text(
          "${lm.batch_edit_report_written_to_database}: ${result.didWriteToDatabase ? lm.dialog_yes : lm.dialog_no}",
          style: tt.bodySmall,
        ),
        const Divider(),
        Expanded(
          child: SuperListView.builder(
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = tracks[index];
              final changes = result.changes.where((c) => c.track.id == track.id).toList();

              return Card(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: NetworkImageWidget(
                          url: ImageUtils.buildUrl(track.coverId, ImageType.track, 64),
                          width: 48,
                          height: 48,
                        ),
                        title: Text(track.title),
                        subtitle: Text(track.artists.map((a) => a.name).join(", ")),
                        contentPadding: EdgeInsets.zero,
                      ),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: changes.length,
                        itemBuilder: (context, changeIndex) {
                          final change = changes[changeIndex];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  _localizeType(change.type, lm),
                                  style: tt.bodyLarge,
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 8,
                                children: [
                                  Expanded(
                                    child: Container(
                                    color: cs.surfaceContainerLowest,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        change.before.isEmpty ? lm.batch_edit_report_field_empty : change.before,
                                        style: TextStyle(fontFamily: "monospace", color: change.before.isEmpty
                                            ?  cs.onSurface.withAlpha(100)
                                            : cs.onSurface),
                                      ),
                                    ),
                                  )
                                  ),
                                  const Icon(Icons.arrow_forward),
                                  Expanded(
                                    child: Container(
                                      color: cs.surfaceContainerLowest,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          change.after.isEmpty ? lm.batch_edit_report_field_empty : change.after,
                                          style: TextStyle(fontFamily: "monospace", color: change.after.isEmpty
                                              ?  cs.onSurface.withAlpha(100)
                                              : cs.onSurface),
                                        ),
                                      ),
                                    )
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(lm.dialog_close)
        )
      ],
    );
  }
}