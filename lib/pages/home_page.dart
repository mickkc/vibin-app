import 'package:flutter/material.dart';
import 'package:vibin_app/auth/auth_state.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/pages/column_page.dart';
import 'package:vibin_app/sections/explore_section.dart';
import 'package:vibin_app/sections/last_listened_to_tracks_section.dart';
import 'package:vibin_app/sections/most_listened_to_artists_section.dart';
import 'package:vibin_app/sections/new_tracks_section.dart';
import 'package:vibin_app/sections/popular_items_section.dart';
import 'package:vibin_app/sections/recommended_start_section.dart';
import 'package:vibin_app/settings/setting_definitions.dart';
import 'package:vibin_app/settings/settings_manager.dart';

import '../sections/playlists_section.dart';
import '../sections/top_tracks_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePagState();
}

class _HomePagState extends State<HomePage> {

  final AuthState authState = getIt<AuthState>();
  final SettingsManager settingsManager = getIt<SettingsManager>();

  Widget? getSection(String key) {
    switch (key) {
      case "RECENTLY_LISTENED" when authState.hasAnyPermission([PermissionType.viewPlaylists, PermissionType.viewAlbums, PermissionType.viewArtists]):
        return LastListenedToSection();
      case "EXPLORE" when authState.hasPermission(PermissionType.viewTracks):
        return ExploreSection();
      case "TOP_ARTISTS" when authState.hasPermission(PermissionType.viewArtists):
        return MostListenedToArtistsSection();
      case "TOP_TRACKS" when authState.hasPermission(PermissionType.viewTracks):
        return TopTracksSection();
      case "NEW_RELEASES" when authState.hasPermission(PermissionType.viewTracks):
        return NewTracksSection();
      case "POPULAR" when authState.hasAnyPermission([PermissionType.viewPlaylists, PermissionType.viewAlbums, PermissionType.viewArtists]):
        return PopularItemsSection();
      case "PLAYLISTS" when authState.hasPermission(PermissionType.viewPlaylists):
        return PlaylistsSection();
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColumnPage(
      children: [
        RecommendedStartSection(),
        ...settingsManager.get(Settings.homepageSections).map((section) {
          if (section.value != true.toString()) return null;
          return getSection(section.key);
        }).nonNulls
      ],
    );
  }
}