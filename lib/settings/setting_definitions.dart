import 'package:flutter/material.dart';
import 'package:vibin_app/color_schemes/color_scheme_list.dart';
import 'package:vibin_app/dialogs/lyrics_dialog.dart';
import 'package:vibin_app/settings/settings_key.dart';
import 'package:vibin_app/widgets/settings/homepage_sections_list.dart';

class Settings {
  static final themeMode = EnumSettingsKey("themeMode", ThemeMode.system, ThemeMode.values);
  static final colorScheme = EnumSettingsKey("colorScheme", ColorSchemeKey.material3, ColorSchemeKey.values);
  static final accentColor = ColorSettingsKey("accentColor", Colors.green);
  static final lyricsDesign = EnumSettingsKey("lyricsDesign", LyricsDesign.dynamic, LyricsDesign.values);

  static final showOwnPlaylistsByDefault = BoolSettingsKey("showOwnPlaylistsByDefault", true);
  static final showSinglesInAlbumsByDefault = BoolSettingsKey("showSinglesInAlbumsByDefault", false);
  static final advancedTrackSearch = BoolSettingsKey("advancedTrackSearch", false);
  static final pageSize = IntSettingsKey("pageSize", 50);
  static final homepageSections = OrderedMapSettingsKey("homepageSections",
      HomepageSectionsList.sections.map((key) => Entry<String, String>(key, true.toString())).toList());

  static final artistMetadataProvider = StringSettingsKey("artistMetadataProvider", "Deezer");
  static final albumMetadataProvider = StringSettingsKey("albumMetadataProvider", "Deezer");
  static final trackMetadataProvider = StringSettingsKey("trackMetadataProvider", "iTunes" );
  static final lyricsProvider = StringSettingsKey("lyricsProvider", "LrcLib");
}
