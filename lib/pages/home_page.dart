import 'package:flutter/material.dart';
import 'package:vibin_app/auth/AuthState.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/sections/explore_section.dart';
import 'package:vibin_app/sections/last_listened_to_tracks_section.dart';
import 'package:vibin_app/sections/most_listened_to_artists_section.dart';
import 'package:vibin_app/sections/new_tracks_section.dart';
import 'package:vibin_app/sections/popular_items_section.dart';
import 'package:vibin_app/sections/recommended_start_section.dart';

import '../sections/playlists_section.dart';
import '../sections/top_tracks_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePagState();
}

class _HomePagState extends State<HomePage> {

  final AuthState authState = getIt<AuthState>();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        spacing: 16,
        children: [

          if (authState.hasAnyPermission([PermissionType.viewPlaylists, PermissionType.viewAlbums, PermissionType.viewArtists]))
            RecommendedStartSection(),

          if (authState.hasAnyPermission([PermissionType.viewPlaylists, PermissionType.viewAlbums, PermissionType.viewArtists]))
            LastListenedToSection(),

          if (authState.hasPermission(PermissionType.viewPlaylists))
            PlaylistsSection(),

          if (authState.hasAnyPermission([PermissionType.viewPlaylists, PermissionType.viewAlbums, PermissionType.viewArtists]))
            PopularItemsSection(),

          if (authState.hasPermission(PermissionType.viewTracks))
            ExploreSection(),

          if (authState.hasPermission(PermissionType.viewTracks))
            NewTracksSection(),

          if (authState.hasPermission(PermissionType.viewTracks))
            TopTracksSection(),

          if (authState.hasPermission(PermissionType.viewArtists))
            MostListenedToArtistsSection(),
        ],
      ),
    );
  }
}