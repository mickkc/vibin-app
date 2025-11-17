import 'package:flutter/material.dart';
import 'package:vibin_app/widgets/entity_card.dart';

import '../../../api/api_manager.dart';
import '../../../main.dart';
import '../../../sections/favorite_section.dart';

class FavoritesSection extends StatefulWidget {
  final int userId;

  const FavoritesSection({super.key, required this.userId});

  @override
  State<FavoritesSection> createState() => _FavoritesSectionState();
}

class _FavoritesSectionState extends State<FavoritesSection> {

  final _apiManager = getIt<ApiManager>();
  late final _favoritesFuture = _apiManager.service.getFavoritesForUser(widget.userId);

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: FavoriteSection.sectionWidth,
      child: Column(
        spacing: 16,
        children: [

          FavoriteSection(
            favoritesFuture: _favoritesFuture,
            type: EntityCardType.track,
          ),

          FavoriteSection(
            favoritesFuture: _favoritesFuture,
            type: EntityCardType.album,
          ),

          FavoriteSection(
            favoritesFuture: _favoritesFuture,
            type: EntityCardType.artist,
          ),
        ],
      ),
    );
  }
}