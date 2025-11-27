import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:vibin_app/dialogs/add_related_track_dialog.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/dtos/track/related_track.dart';
import 'package:vibin_app/utils/error_handler.dart';
import 'package:vibin_app/widgets/network_image.dart';

import '../api/api_manager.dart';
import '../auth/auth_state.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';

class RelatedTracksManagementDialog extends StatefulWidget {

  final int trackId;
  final List<RelatedTrack> relatedTracks;
  final void Function(List<RelatedTrack>) onUpdated;

  const RelatedTracksManagementDialog({
    super.key,
    required this.trackId,
    required this.relatedTracks,
    required this.onUpdated,
  });

  static Future<void> show(BuildContext context, int trackId, List<RelatedTrack> relatedTracks, void Function(List<RelatedTrack>) onUpdated) {
    return showDialog(
      context: context,
      builder: (context) => RelatedTracksManagementDialog(
        trackId: trackId,
        relatedTracks: relatedTracks,
        onUpdated: onUpdated,
      )
    );
  }

  @override
  State<RelatedTracksManagementDialog> createState() => _RelatedTracksManagementDialogState();
}

class _RelatedTracksManagementDialogState extends State<RelatedTracksManagementDialog> {

  final _apiManager = getIt<ApiManager>();
  late List<RelatedTrack> _relatedTracks;

  final _authState = getIt<AuthState>();

  late final _lm = AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _relatedTracks = widget.relatedTracks;
  }

  Future<void> _deleteRelatedTrack(int relatedTrackId) async {
    try {
      final response = await _apiManager.service.removeRelatedTrack(widget.trackId, relatedTrackId);

      if (!response.success) {
        throw Exception("Failed to delete related track: success was false");
      }

      setState(() {
        _relatedTracks.removeWhere((rt) => rt.track.id == relatedTrackId);
      });

      widget.onUpdated(_relatedTracks);
    }
    catch (e, st) {
      log("Error deleting related track: $e", error: e, stackTrace: st, level: Level.error.value);
      if (mounted) {
        ErrorHandler.showErrorDialog(context, _lm.edit_related_tracks_remove_error, error: e, stackTrace: st);
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
      title: Text(_lm.edit_related_tracks_title),
      content: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SizedBox(
              width: width > 600 ? 600 : width * 0.9,
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: _relatedTracks.length,
                itemBuilder: (context, index) {
                  final relatedTrack = _relatedTracks[index];
                  return ListTile(
                    leading: NetworkImageWidget(
                      url: "/api/tracks/${relatedTrack.track.id}/cover?size=64",
                      width: 48,
                      height: 48,
                    ),
                    title: Text(relatedTrack.track.title),
                    subtitle: Text(relatedTrack.relationDescription),
                    trailing: _authState.hasPermission(PermissionType.deleteTrackRelations) ? IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async => await _deleteRelatedTrack(relatedTrack.track.id)
                    ) : null,
                  );
                }
              ),
            ),
          ),
          FilledButton(
            onPressed: () async {
              await AddRelatedTrackDialog.show(
                context,
                widget.trackId,
                _relatedTracks.map((t) => t.track.id).toList(),
                (rt) {
                  setState(() {
                    _relatedTracks.add(rt);
                  });
                  widget.onUpdated(_relatedTracks);
                }
              );
            },
            child: Text(_lm.edit_related_tracks_add),
          )
        ],
      ),
    );
  }
}