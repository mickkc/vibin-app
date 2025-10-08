import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/dtos/metadata_sources.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/settings/setting_definitions.dart';
import 'package:vibin_app/settings/settings_manager.dart';
import 'package:vibin_app/widgets/future_content.dart';
import 'package:vibin_app/widgets/settings/settings_title.dart';

import '../../l10n/app_localizations.dart';

class PreferredMetadataPickers extends StatefulWidget {
  const PreferredMetadataPickers({super.key});

  @override
  State<PreferredMetadataPickers> createState() => _PreferredMetadataPickersState();
}

class _PreferredMetadataPickersState extends State<PreferredMetadataPickers> {

  final SettingsManager settingsManager = getIt<SettingsManager>();
  final ApiManager apiManager = getIt<ApiManager>();

  late String artistProvider = settingsManager.get(Settings.artistMetadataProvider);
  late String albumProvider = settingsManager.get(Settings.albumMetadataProvider);
  late String trackProvider = settingsManager.get(Settings.trackMetadataProvider);

  late String lyricsProvider = settingsManager.get(Settings.lyricsProvider);

  late final lm = AppLocalizations.of(context)!;

  late final Future<MetadataSources> providersFuture = apiManager.service.getMetadataProviders();

  Widget buildPicker(String title, String currentValue, List<String> options, Function(String) onChanged) {
    final actualSelected = options.contains(currentValue) ? currentValue : options.first;
    return ListTile(
      title: Text(title),
      trailing: DropdownButton<String>(
        value: actualSelected,
        items: options.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureContent(
      future: providersFuture,
      builder: (context, providers) {
        return Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SettingsTitle(
              title: lm.settings_app_metadata_providers_title,
              subtitle: lm.settings_app_metadata_providers_description
            ),

            buildPicker(
              lm.artists,
              artistProvider,
              providers.artist,
              (value) {
                settingsManager.set(Settings.artistMetadataProvider, value);
                setState(() {
                  artistProvider = value;
                });
              }
            ),

            buildPicker(
              lm.albums,
              albumProvider,
              providers.album,
              (value) {
                settingsManager.set(Settings.albumMetadataProvider, value);
                setState(() {
                  albumProvider = value;
                });
              }
            ),

            buildPicker(
              lm.tracks,
              trackProvider,
              providers.track,
              (value) {
                settingsManager.set(Settings.trackMetadataProvider, value);
                setState(() {
                  trackProvider = value;
                });
              }
            ),

            buildPicker(
              lm.lyrics_p,
              lyricsProvider,
              providers.lyrics,
              (value) {
                settingsManager.set(Settings.lyricsProvider, value);
                setState(() {
                  lyricsProvider = value;
                });
              }
            ),
          ],
        );
      },
    );
  }
}