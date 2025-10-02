import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vibin_app/auth/AuthState.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/sections/explore_section.dart';
import 'package:vibin_app/sections/last_listened_to_tracks_section.dart';
import 'package:vibin_app/sections/most_listened_to_artists_section.dart';
import 'package:vibin_app/sections/recommended_start_section.dart';
import 'package:vibin_app/widgets/permission_widget.dart';

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
          PermissionWidget(
              requiredPermissions: [PermissionType.viewPlaylists, PermissionType.viewAlbums, PermissionType.viewArtists],
              child: RecommendedStartSection()),
          PermissionWidget(
              requiredPermissions: [PermissionType.viewPlaylists, PermissionType.viewAlbums, PermissionType.viewArtists],
              child: LastListenedToSection()),
          PermissionWidget(
              requiredPermissions: [PermissionType.viewTracks],
              child: ExploreSection()),
          PermissionWidget(
              requiredPermissions: [PermissionType.viewArtists],
              child: MostListenedToArtistsSection())
        ],
      ),
    );
  }
}