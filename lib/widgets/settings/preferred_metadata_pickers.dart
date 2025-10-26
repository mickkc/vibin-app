import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
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

  final _settingsManager = getIt<SettingsManager>();
  final _apiManager = getIt<ApiManager>();

  late String _artistProvider = _settingsManager.get(Settings.artistMetadataProvider);
  late String _albumProvider = _settingsManager.get(Settings.albumMetadataProvider);
  late String _trackProvider = _settingsManager.get(Settings.trackMetadataProvider);

  late String _lyricsProvider = _settingsManager.get(Settings.lyricsProvider);

  late final _lm = AppLocalizations.of(context)!;

  late final _providersFuture = _apiManager.service.getMetadataProviders();

  Widget _buildPicker(String title, String currentValue, List<String> options, Function(String) onChanged) {
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
      future: _providersFuture,
      builder: (context, providers) {
        return Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SettingsTitle(
              title: _lm.settings_app_metadata_providers_title,
              subtitle: _lm.settings_app_metadata_providers_description
            ),

            _buildPicker(
              _lm.artists,
              _artistProvider,
              providers.artist,
              (value) {
                _settingsManager.set(Settings.artistMetadataProvider, value);
                setState(() {
                  _artistProvider = value;
                });
              }
            ),

            _buildPicker(
              _lm.albums,
              _albumProvider,
              providers.album,
              (value) {
                _settingsManager.set(Settings.albumMetadataProvider, value);
                setState(() {
                  _albumProvider = value;
                });
              }
            ),

            _buildPicker(
              _lm.tracks,
              _trackProvider,
              providers.track,
              (value) {
                _settingsManager.set(Settings.trackMetadataProvider, value);
                setState(() {
                  _trackProvider = value;
                });
              }
            ),

            _buildPicker(
              _lm.lyrics_p,
              _lyricsProvider,
              providers.lyrics,
              (value) {
                _settingsManager.set(Settings.lyricsProvider, value);
                setState(() {
                  _lyricsProvider = value;
                });
              }
            ),
          ],
        );
      },
    );
  }
}