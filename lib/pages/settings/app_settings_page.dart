import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/pages/settings/app_user_settings_view.dart';
import 'package:vibin_app/settings/setting_definitions.dart';
import 'package:vibin_app/settings/settings_manager.dart';
import 'package:vibin_app/widgets/settings/accent_color_picker.dart';
import 'package:vibin_app/widgets/settings/bool_settings_field.dart';
import 'package:vibin_app/widgets/settings/enum_settings_field.dart';
import 'package:vibin_app/widgets/settings/homepage_sections_list.dart';
import 'package:vibin_app/widgets/settings/int_settings_field.dart';
import 'package:vibin_app/widgets/settings/preferred_metadata_pickers.dart';
import 'package:vibin_app/widgets/settings/settings_title.dart';

import '../../auth/auth_state.dart';
import '../../dialogs/lyrics_dialog.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../settings/enums/metadata_image_size.dart';
import '../../themes/color_scheme_list.dart';

class AppSettingsPage extends StatefulWidget {

  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {

  final _settingsManager = getIt<SettingsManager>();
  final _authState = getIt<AuthState>();
  late final _lm = AppLocalizations.of(context)!;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: [

          SettingsTitle(
            title: _lm.settings_app_appearance_title,
          ),

          ValueListenableBuilder(
            valueListenable: themeNotifier,
            builder: (context, value, child) {

              return Column(
                children: [
                  if (ColorSchemeList.get(value.colorSchemeKey).supportsBrightness)
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
                        _settingsManager.set(Settings.themeMode, mode);
                        themeNotifier.value = themeNotifier.value.setThemeMode(mode).validate(context);
                      }
                    ),

                  EnumSettingsField(
                    key: ValueKey("app_color_scheme_field_${value.colorSchemeKey.name}"),
                    settingKey: Settings.colorScheme,
                    title: _lm.settings_app_theme_title,
                    optionLabel: (key) => ColorSchemeList.get(key).getName(_lm),
                    icon: Icons.format_paint,
                    onChanged: (key) {
                      _settingsManager.set(Settings.colorScheme, key);
                      themeNotifier.value = themeNotifier.value.setColorSchemeKey(key).validate(context);
                    },
                    isOptionEnabled: (key) => ColorSchemeList.get(key).isSupported(),
                  ),

                  if (ColorSchemeList.get(value.colorSchemeKey).supportsAccentColor)
                    ListTile(
                      key: ValueKey("app_accent_color_picker_${value.accentColor.toARGB32()}"),
                      title: Text(_lm.settings_app_accent_color_title),
                      subtitle: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AccentColorPicker(
                          accentColor: value.accentColor,
                          colorSchemeKey: value.colorSchemeKey,
                        ),
                      ),
                      leading: Icon(Icons.palette),
                    )
                ],
              );
            }
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

          const Divider(),

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

          const Divider(),

          HomepageSectionsList(),

          const Divider(),

          PreferredMetadataPickers(),


          if (_authState.hasPermission(PermissionType.changeOwnUserSettings)) ... [
            const Divider(),
            const AppUserSettingsView(),
          ],

          const Divider(),

          SettingsTitle(
            title: _lm.settings_app_advanced_title,
          ),

          if (_authState.hasPermission(PermissionType.manageSessions))
            ListTile(
              leading: const Icon(Icons.manage_accounts),
              title: Text(_lm.settings_app_manage_sessions_title),
              subtitle: Text(_lm.settings_app_manage_sessions_description),
              onTap: () {
                GoRouter.of(context).push("/sessions");
              },
            ),

          if (_authState.hasPermission(PermissionType.manageTasks))
            ListTile(
              leading: const Icon(Icons.refresh),
              title: Text(_lm.settings_app_manage_tasks_title),
              subtitle: Text(_lm.settings_app_manage_tasks_description),
              onTap: () {
                GoRouter.of(context).push("/tasks");
              },
            ),

          if (!kIsWeb && Platform.isLinux)
            BoolSettingsField(
              settingsKey: Settings.linuxEnableDbusMpris,
              title: _lm.settings_app_enable_linux_dbus_integration_title,
              description: _lm.settings_app_enable_linux_dbus_integration_description,
              icon: Icons.cable,
            ),

          if (_authState.hasPermission(PermissionType.streamTracks))
            BoolSettingsField(
              settingsKey: Settings.embedImagesAsBase64,
              title: _lm.settings_app_embed_images_as_base64_title,
              description: _lm.settings_app_embed_images_as_base64_description,
              icon: Icons.image,
            ),

          EnumSettingsField(
            settingKey: Settings.metadataImageSize,
            title: _lm.settings_app_metadata_image_size_title,
            description: _lm.settings_app_metadata_image_size_description,
            icon: Icons.image_search,
            optionLabel: (option) {
              return switch (option) {
                MetadataImageSize.small => _lm.settings_app_metadata_image_size_small,
                MetadataImageSize.medium => _lm.settings_app_metadata_image_size_medium,
                MetadataImageSize.large => _lm.settings_app_metadata_image_size_large,
              };
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(_lm.settings_app_about_title),
            subtitle: Text(_lm.settings_app_about_description),
            onTap: () => showAboutAppDialog(context),
          )
        ],
      ),
    );
  }
}