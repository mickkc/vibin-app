import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/dtos/artist/artist_metadata.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/settings/setting_definitions.dart';
import 'package:vibin_app/widgets/network_image.dart';

import '../../l10n/app_localizations.dart';
import 'base_metadata_dialog.dart';

class SearchArtistMetadataDialog extends StatelessWidget {
  final String? initialSearch;
  final Function(ArtistMetadata) onSelect;

  const SearchArtistMetadataDialog({
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
      fetchMethod: (q, p) => apiManager.service.searchArtistMetadata(q, p),
      itemBuilder: (context, metadata, onTap) {
        return ListTile(
          onTap: onTap,
          leading: metadata.pictureUrl == null ? null : NetworkImageWidget(
            url: metadata.pictureUrl!,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(25),
          ),
          title: Text(metadata.name),
          subtitle: Text(metadata.biography ?? lm.edit_artist_metadata_no_description)
        );
      },
      sourceSelector: (s) => s.artist,
      defaultProviderSettingKey: Settings.artistMetadataProvider,
    );
  }
}