import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/dtos/track/track_info_metadata.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/pages/edit/base_metadata_dialog.dart';
import 'package:vibin_app/widgets/network_image.dart';

class SearchTrackMetadataDialog extends StatelessWidget {
  final String? initialSearch;
  final Function(TrackInfoMetadata) onSelect;

  const SearchTrackMetadataDialog({
    super.key,
    this.initialSearch,
    required this.onSelect,
  });


  @override
  Widget build(BuildContext context) {
    final ApiManager apiManager = getIt<ApiManager>();
    return BaseMetadataDialog(
      onSelect: onSelect,
      initialSearch: initialSearch,
      fetchMethod: (q, p) => apiManager.service.searchTrackMetadata(q, p),
      itemBuilder: (context, metadata, onTap) {
        return ListTile(
          onTap: onTap,
          leading: metadata.coverImageUrl == null ? null : NetworkImageWidget(
            url: metadata.coverImageUrl!,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(4),
          ),
          title: Text(metadata.title),
          subtitle: Text(metadata.artistNames?.join(", ") ?? "")
        );
      },
      sourceSelector: (s) => s.track
    );
  }
}