import 'package:flutter/material.dart';
import 'package:vibin_app/settings/settings_key.dart';
import 'package:vibin_app/widgets/settings/homepage_sections_list.dart';

class Settings {
  static final themeMode = EnumSettingsKey("themeMode", ThemeMode.system, ThemeMode.values);
  static final showOwnPlaylistsByDefault = BoolSettingsKey("showOwnPlaylistsByDefault", true);
  static final advancedTrackSearch = BoolSettingsKey("advancedTrackSearch", false);
  static final pageSize = IntSettingsKey("pageSize", 50);
  static final homepageSections = OrderedMapSettingsKey("homepageSections",
      HomepageSectionsList.sections.map((key) => Entry<String, String>(key, true.toString())).toList());
}