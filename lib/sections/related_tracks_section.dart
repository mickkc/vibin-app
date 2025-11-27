import 'package:flutter/material.dart';
import 'package:vibin_app/auth/auth_state.dart';
import 'package:vibin_app/dialogs/related_tracks_management_dialog.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/dtos/track/related_track.dart';
import 'package:vibin_app/sections/section_header.dart';
import 'package:vibin_app/widgets/entity_card.dart';
import 'package:vibin_app/widgets/future_content.dart';

import '../api/api_manager.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';

class RelatedTracksSection extends StatefulWidget {
  final int trackId;

  const RelatedTracksSection({
    super.key,
    required this.trackId,
  });

  @override
  State<RelatedTracksSection> createState() => _RelatedTracksSectionState();
}

class _RelatedTracksSectionState extends State<RelatedTracksSection> {
  
  final _apiManager = getIt<ApiManager>();
  late Future<List<RelatedTrack>> _relatedTracksFuture;

  @override
  void initState() {
    super.initState();
    _relatedTracksFuture = _apiManager.service.getRelatedTracks(widget.trackId);
  }

  @override
  Widget build(BuildContext context) {


    final authState = getIt<AuthState>();

    final lm = AppLocalizations.of(context)!;

    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: lm.section_related_tracks,
          trailing: authState.hasAnyPermission([PermissionType.createTrackRelations, PermissionType.deleteTrackRelations])
          ? IconButton(
              onPressed: () async {
                await RelatedTracksManagementDialog.show(
                  context,
                  widget.trackId,
                  await _relatedTracksFuture,
                  (updatedRelatedTracks) {
                    setState(() {
                      _relatedTracksFuture = Future.value(updatedRelatedTracks);
                    });
                  }
                );
              },
              icon: const Icon(Icons.edit)
          )
          : null,
        ),
        FutureContent(
          future: _relatedTracksFuture,
          height: 210,
          builder: (context, relatedTracks) {

            if (relatedTracks.isEmpty) {
              return Center(
                child: Text(lm.section_related_no_data),
              );
            }

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: relatedTracks.length,
              itemBuilder: (context, index) {
                final track = relatedTracks[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: EntityCard(
                    entity: track.track,
                    overrideDescription: track.relationDescription,
                    coverSize: 128,
                    type: EntityCardType.track,
                  ),
                );
              }
            );
          }
        )
      ],
    );
  }
}