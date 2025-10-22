import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/dtos/album/album_info_metadata.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/settings/setting_definitions.dart';
import 'package:vibin_app/widgets/network_image.dart';

import '../../l10n/app_localizations.dart';
import 'base_metadata_dialog.dart';

class SearchAlbumMetadataDialog extends StatelessWidget {
  final String? initialSearch;
  final Function(AlbumInfoMetadata) onSelect;

  const SearchAlbumMetadataDialog({
    super.key,
    this.initialSearch,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final apiManager = getIt<ApiManager>();
    final lm = AppLocalizations.of(context)!;
    return BaseMetadataDialog(
      onSelect: onSelect,
      initialSearch: initialSearch,
      fetchMethod: (q, p) => apiManager.service.searchAlbumMetadata(q, p),
      itemBuilder: (context, metadata, onTap) {

        final artistStr = (metadata.artistName != null ? metadata.artistName! : "");
        final descriptionStr = (metadata.description != null ? lm.edit_album_metadata_has_description : lm.edit_album_metadata_no_description);
        final yearStr = (metadata.year != null ? metadata.year!.toString() : "");

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
          subtitle: Text([artistStr, yearStr, descriptionStr].where((s) => s.isNotEmpty).join(", "))
        );
      },
      sourceSelector: (s) => s.album,
      defaultProviderSettingKey: Settings.albumMetadataProvider,
    );
  }
}