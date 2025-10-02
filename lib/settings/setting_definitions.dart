import 'package:flutter/material.dart';
import 'package:vibin_app/settings/settings_key.dart';

class Settings {
  static final themeMode = EnumSettingsKey("themeMode", ThemeMode.system, ThemeMode.values);
  static final showOwnPlaylistsByDefault = BoolSettingsKey("showOwnPlaylistsByDefault", true);
  static final pageSize = IntSettingsKey("pageSize", 50);
}