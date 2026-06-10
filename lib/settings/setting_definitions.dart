import 'package:dart_discord_presence/dart_discord_presence.dart';
import 'package:flutter/material.dart';
import 'package:vibin_app/dialogs/lyrics_dialog.dart';
import 'package:vibin_app/dtos/stream_format.dart';
import 'package:vibin_app/settings/enums/metadata_image_size.dart';
import 'package:vibin_app/settings/settings_key.dart';
import 'package:vibin_app/widgets/settings/homepage_sections_list.dart';

import '../themes/color_scheme_list.dart';

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

  static final linuxEnableDbusMpris = BoolSettingsKey("linuxEnableDbusMpris", true);
  static final embedImagesAsBase64 = BoolSettingsKey("embedImagesAsBase64", false);
  static final metadataImageSize = EnumSettingsKey("metadataImageSize", MetadataImageSize.medium, MetadataImageSize.values);

  static final enableVolumeNormalization = BoolSettingsKey("enableVolumeNormalization", true);

  static final enableTranscoding = BoolSettingsKey("enableTranscoding", true);
  static final preferredStreamingFormat = EnumSettingsKey("preferredStreamingFormat", StreamFormat.aac, StreamFormat.values);
  static final preferredStreamingBitrate = IntSettingsKey("preferredStreamingBitrate", 320);

  static final enableDiscordRpc = BoolSettingsKey("rpcEnableDiscordRpc", false);
  static final stateTemplate = StringSettingsKey("rpcStateTemplate", "{artists}");
  static final detailTemplate = StringSettingsKey("rpcDetailTemplate", "{title}");
  static final largeAssetTemplate = StringSettingsKey("rpcLargeAssetTemplate", "{album}");
  static final smallAssetTemplate = StringSettingsKey("rpcSmallAssetTemplate", "Paused");
  static final displayType = EnumSettingsKey("rpcDisplayType", DiscordStatusDisplayType.name, DiscordStatusDisplayType.values);
}
