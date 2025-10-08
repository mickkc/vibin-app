import 'package:flutter/material.dart';
import 'package:vibin_app/settings/setting_definitions.dart';
import 'package:vibin_app/settings/settings_manager.dart';
import 'package:vibin_app/widgets/settings/accent_color_picker.dart';
import 'package:vibin_app/widgets/settings/bool_settings_field.dart';
import 'package:vibin_app/widgets/settings/homepage_sections_list.dart';
import 'package:vibin_app/widgets/settings/int_settings_field.dart';
import 'package:vibin_app/widgets/settings/preferred_metadata_pickers.dart';

import '../../l10n/app_localizations.dart';
import '../../main.dart';

class AppSettingsPage extends StatefulWidget {

  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {

  final SettingsManager settingsManager = getIt<SettingsManager>();
  late final lm = AppLocalizations.of(context)!;

  late ThemeMode themeMode = settingsManager.get(Settings.themeMode);
  late bool showOwnPlaylistsByDefault = settingsManager.get(Settings.showOwnPlaylistsByDefault);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          ListTile(
            title: Text(lm.settings_app_theme_title),
            leading: Icon(Icons.color_lens),
            trailing: DropdownButton<ThemeMode>(
              value: themeMode,
              padding: EdgeInsets.all(4.0),
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(lm.settings_app_theme_system),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(lm.settings_app_theme_light),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(lm.settings_app_theme_dark),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  themeNotifier.value = themeNotifier.value.setThemeMode(value);
                  settingsManager.set(Settings.themeMode, value);
                  setState(() {
                    themeMode = value;
                  });
                }
              },
            ),
          ),

          ListTile(
            title: Text(lm.settings_app_accent_color_title),
            subtitle: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AccentColorPicker(),
            ),
            leading: Icon(Icons.palette),
          ),

          IntSettingsInputField(
            settingsKey: Settings.pageSize,
            label: lm.settings_app_page_size_title,
            description: lm.settings_app_page_size_description,
            icon: Icons.format_list_numbered,
            min: 10,
            max: 100,
          ),

          BoolSettingsField(
            settingsKey: Settings.advancedTrackSearch,
            title: lm.settings_app_advanced_track_search_title,
            description: lm.settings_app_advanced_track_search_description,
            icon: Icons.manage_search
          ),

          Divider(),

          BoolSettingsField(
            settingsKey: Settings.showOwnPlaylistsByDefault,
            title: lm.settings_app_show_own_playlists_by_default,
            description: lm.settings_app_show_own_playlists_by_default_description,
            icon: Icons.playlist_play
          ),

          BoolSettingsField(
            settingsKey: Settings.showSinglesInAlbumsByDefault,
            title: lm.settings_app_show_singles_in_albums_by_default,
            description: lm.settings_app_show_singles_in_albums_by_default_description,
            icon: Icons.library_music
          ),

          Divider(),

          HomepageSectionsList(),

          Divider(),

          PreferredMetadataPickers()
        ],
      ),
    );
  }
}