import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../dialogs/lyrics_dialog.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../settings/enums/homepage_section.dart';
import '../../settings/enums/track_info_field.dart';
import '../../settings/setting_definitions.dart';
import '../../settings/settings_manager.dart';
import '../../themes/color_scheme_list.dart';
import '../../widgets/settings/accent_color_picker.dart';
import '../../widgets/settings/bool_settings_field.dart';
import '../../widgets/settings/enum_settings_field.dart';
import '../../widgets/settings/homepage_sections_list.dart';
import '../../widgets/settings/int_settings_field.dart';
import '../../widgets/settings/settings_title.dart';

class AppearanceSettingsPage extends StatelessWidget {

  const AppearanceSettingsPage({ super.key });

  @override
  Widget build(BuildContext context) {

    late final lm = AppLocalizations.of(context)!;
    final settingsManager = getIt<SettingsManager>();

    return ListView(
      children: [
        SettingsTitle(
          title: lm.settings_app_appearance_title,
          icon: Icons.palette,
          heroTag: "settings-appearance",
        ),

        ValueListenableBuilder(
          valueListenable: themeNotifier,
          builder: (context, value, child) {

            return Column(
              children: [
                if (ColorSchemeList.get(value.colorSchemeKey).supportsBrightness)
                  EnumSettingsField(
                    settingKey: Settings.themeMode,
                    title: lm.settings_app_brightness_title,
                    icon: Icons.color_lens,
                    optionLabel: (option) {
                      return switch (option) {
                        ThemeMode.system => lm.settings_app_brightness_system,
                        ThemeMode.light => lm.settings_app_brightness_light,
                        ThemeMode.dark => lm.settings_app_brightness_dark,
                      };
                    },
                    onChanged: (mode) {
                      settingsManager.set(Settings.themeMode, mode);
                      themeNotifier.value = themeNotifier.value.setThemeMode(mode).validate(context);
                    }
                  ),

                EnumSettingsField(
                  key: ValueKey("app_color_scheme_field_${value.colorSchemeKey.name}"),
                  settingKey: Settings.colorScheme,
                  title: lm.settings_app_theme_title,
                  optionLabel: (key) => ColorSchemeList.get(key).getName(lm),
                  icon: Icons.format_paint,
                  onChanged: (key) {
                    settingsManager.set(Settings.colorScheme, key);
                    themeNotifier.value = themeNotifier.value.setColorSchemeKey(key).validate(context);
                  },
                  isOptionEnabled: (key) => ColorSchemeList.get(key).isSupported(),
                ),

                if (ColorSchemeList.get(value.colorSchemeKey).supportsAccentColor)
                  ListTile(
                    key: ValueKey("app_accent_color_picker_${value.accentColor.toARGB32()}"),
                    title: Text(lm.settings_app_accent_color_title),
                    subtitle: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AccentColorPicker(
                        accentColor: value.accentColor,
                        colorSchemeKey: value.colorSchemeKey,
                      ),
                    ),
                    leading: Icon(Icons.palette),
                  ),

                EnumSettingsField(
                  key: ValueKey("app_language_field_${value.locale?.toLanguageTag()}"),
                  settingKey: Settings.language,
                  title: lm.settings_app_language_title,
                  icon: Icons.translate,
                  optionLabel: (ln) {
                    switch (ln?.languageCode) {
                      case null:
                        return lm.settings_app_language_device;
                      case "en":
                        return "English";
                      case "de":
                        return "Deutsch";
                      case "nl":
                        return "Nederlands";
                      case "ro":
                        return "Română";
                      default:
                        return ln!.languageCode;
                    }
                  },
                  onChanged: (ln) {
                    themeNotifier.value = themeNotifier.value.setLanguage(ln);
                    context.pushReplacement("/settings/app", extra: DateTime.now().millisecondsSinceEpoch);
                  },
                )
              ],
            );
          }
        ),

        EnumSettingsField(
          settingKey: Settings.lyricsDesign,
          title: lm.settings_app_lyrics_design_title,
          optionLabel: (option) {
            return switch (option) {
              LyricsDesign.system => lm.settings_app_lyrics_design_system,
              LyricsDesign.primary => lm.settings_app_lyrics_design_primary,
              LyricsDesign.dynamic => lm.settings_app_lyrics_design_dynamic,
              LyricsDesign.dynamicDark => lm.settings_app_lyrics_design_dynamic_dark,
              LyricsDesign.dynamicLight => lm.settings_app_lyrics_design_dynamic_light,
            };
          },
          icon: Icons.lyrics,
          onChanged: (design) {
            LyricsDialog.lyricsDesignNotifier.value = design;
          },
        ),

        const Divider(),

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

        const Divider(),

        OrderedMapSettingsView(
          title: lm.settings_app_track_fields_title,
          subtitle: lm.settings_app_track_fields_description,
          settingsKey: Settings.trackInfoFields,
          nameFunc: (key, lm) {
            switch (key) {
              case TrackInfoField.duration:
                return lm.settings_app_track_field_duration;
              case TrackInfoField.listeningDuration:
                return lm.settings_app_track_field_listening_duration;
              case TrackInfoField.year:
                return lm.settings_app_track_field_year;
              case TrackInfoField.trackCountNumber:
                return lm.settings_app_track_field_track_count_number;
              case TrackInfoField.discCountNumber:
                return lm.settings_app_track_field_disc_count_number;
              case TrackInfoField.bitrate:
                return lm.settings_app_track_field_bitrate;
              case TrackInfoField.explicit:
                return lm.settings_app_track_field_explicit;
              case TrackInfoField.hasLyrics:
                return lm.settings_app_track_field_has_lyrics;
              case TrackInfoField.uploader:
                return lm.settins_app_track_field_uploader;
              default:
                return key;
            }
          }
        ),

        BoolSettingsField(
          settingsKey: Settings.showTrackComment,
          title: lm.settings_app_track_field_show_comment,
          icon: Icons.comment,
        ),

        BoolSettingsField(
          settingsKey: Settings.showTrackTags,
          title: lm.settings_app_track_field_show_tags,
          icon: Icons.sell,
        ),

        const Divider(),

        OrderedMapSettingsView(
          settingsKey: Settings.homepageSections,
          title: lm.settings_app_homepage_sections_title,
          subtitle: lm.settings_app_homepage_sections_description,
          nameFunc: (key, lm) {
            switch (key) {
              case HomepageSection.recentlyListened:
                return lm.section_recently_listened;
              case HomepageSection.explore:
                return lm.section_random_tracks;
              case HomepageSection.topArtists:
                return lm.section_top_artists;
              case HomepageSection.topTracks:
                return lm.section_top_tracks;
              case HomepageSection.newReleases:
                return lm.section_newest_tracks;
              case HomepageSection.popular:
                return lm.section_popular_items;
              case HomepageSection.playlists:
                return lm.section_playlists;
              case HomepageSection.stats:
                return lm.section_global_stats;
              default:
                return key;
            }
          }
        ),
      ],
    );
  }

}