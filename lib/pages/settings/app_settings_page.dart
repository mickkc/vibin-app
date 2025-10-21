import 'package:flutter/material.dart';
import 'package:vibin_app/settings/setting_definitions.dart';
import 'package:vibin_app/settings/settings_manager.dart';
import 'package:vibin_app/widgets/settings/accent_color_picker.dart';
import 'package:vibin_app/widgets/settings/bool_settings_field.dart';
import 'package:vibin_app/widgets/settings/enum_settings_field.dart';
import 'package:vibin_app/widgets/settings/homepage_sections_list.dart';
import 'package:vibin_app/widgets/settings/int_settings_field.dart';
import 'package:vibin_app/widgets/settings/preferred_metadata_pickers.dart';
import 'package:vibin_app/widgets/settings/settings_title.dart';

import '../../dialogs/lyrics_dialog.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../themes/color_scheme_list.dart';

class AppSettingsPage extends StatefulWidget {

  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {

  final _settingsManager = getIt<SettingsManager>();
  late final _lm = AppLocalizations.of(context)!;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: [

          SettingsTitle(
            title: _lm.settings_app_appearance_title,
          ),

          EnumSettingsField(
            settingKey: Settings.themeMode,
            title: _lm.settings_app_brightness_title,
            icon: Icons.color_lens,
            optionLabel: (option) {
              return switch (option) {
                ThemeMode.system => _lm.settings_app_brightness_system,
                ThemeMode.light => _lm.settings_app_brightness_light,
                ThemeMode.dark => _lm.settings_app_brightness_dark,
              };
            },
            onChanged: (mode) {
              themeNotifier.value = themeNotifier.value.setThemeMode(mode);
            }
          ),

          EnumSettingsField(
            settingKey: Settings.colorScheme,
            title: _lm.settings_app_theme_title,
            optionLabel: (key) {
              return switch(key) {
                ColorSchemeKey.material3 => _lm.settings_app_theme_material3_title,
                ColorSchemeKey.gruvbox => _lm.settings_app_theme_gruvbox_title,
                ColorSchemeKey.catppuccinLatte => _lm.settings_app_theme_catppuccin_latte_title,
                ColorSchemeKey.catppuccinFrappe => _lm.settings_app_theme_catppuccin_frappe_title,
                ColorSchemeKey.catppuccinMacchiato => _lm.settings_app_theme_catppuccin_macchiato_title,
                ColorSchemeKey.catppuccinMocha => _lm.settings_app_theme_catppuccin_mocha_title
              };
            },
            icon: Icons.format_paint,
            onChanged: (key) {
              final firstAccentColor = ColorSchemeList.themes[key]!.getAccentColors(Theme.brightnessOf(context)).first;
              _settingsManager.set(Settings.accentColor, firstAccentColor);
              themeNotifier.value = themeNotifier.value.setColorSchemeKey(key).setAccentColor(firstAccentColor);
            }
          ),

          ListTile(
            title: Text(_lm.settings_app_accent_color_title),
            subtitle: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AccentColorPicker(),
            ),
            leading: Icon(Icons.palette),
          ),

          EnumSettingsField(
            settingKey: Settings.lyricsDesign,
            title: _lm.settings_app_lyrics_design_title,
            optionLabel: (option) {
              return switch (option) {
                LyricsDesign.system => _lm.settings_app_lyrics_design_system,
                LyricsDesign.primary => _lm.settings_app_lyrics_design_primary,
                LyricsDesign.dynamic => _lm.settings_app_lyrics_design_dynamic,
                LyricsDesign.dynamicDark => _lm.settings_app_lyrics_design_dynamic_dark,
                LyricsDesign.dynamicLight => _lm.settings_app_lyrics_design_dynamic_light,
              };
            },
            icon: Icons.lyrics,
            onChanged: (design) {
              LyricsDialog.lyricsDesignNotifier.value = design;
            },
          ),

          Divider(),

          SettingsTitle(
            title: _lm.settings_app_behavior_title,
          ),

          IntSettingsInputField(
            settingsKey: Settings.pageSize,
            label: _lm.settings_app_page_size_title,
            description: _lm.settings_app_page_size_description,
            icon: Icons.format_list_numbered,
            min: 10,
            max: 100,
          ),

          BoolSettingsField(
            settingsKey: Settings.advancedTrackSearch,
            title: _lm.settings_app_advanced_track_search_title,
            description: _lm.settings_app_advanced_track_search_description,
            icon: Icons.manage_search
          ),

          BoolSettingsField(
            settingsKey: Settings.showOwnPlaylistsByDefault,
            title: _lm.settings_app_show_own_playlists_by_default,
            description: _lm.settings_app_show_own_playlists_by_default_description,
            icon: Icons.playlist_play
          ),

          BoolSettingsField(
            settingsKey: Settings.showSinglesInAlbumsByDefault,
            title: _lm.settings_app_show_singles_in_albums_by_default,
            description: _lm.settings_app_show_singles_in_albums_by_default_description,
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