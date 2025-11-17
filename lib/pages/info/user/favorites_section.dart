import 'package:flutter/material.dart';
import 'package:vibin_app/sections/section_header.dart';
import 'package:vibin_app/widgets/dummy_entity_card.dart';
import 'package:vibin_app/widgets/entity_card.dart';
import 'package:vibin_app/widgets/future_content.dart';

import '../../../api/api_manager.dart';
import '../../../l10n/app_localizations.dart';
import '../../../main.dart';

class FavoritesSection extends StatefulWidget {
  final int userId;

  const FavoritesSection({super.key, required this.userId});

  @override
  State<FavoritesSection> createState() => _FavoritesSectionState();
}

class _FavoritesSectionState extends State<FavoritesSection> {

  final _apiManager = getIt<ApiManager>();
  late final _favoritesFuture = _apiManager.service.getFavoritesForUser(widget.userId);

  Widget _emptyWidget(BuildContext context) {
    final lm = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 16,
        children: [
          Icon(
            Icons.question_mark,
            size: 64,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          Text(
            lm.user_favorites_no_favorites,
          )
        ],
      ),
    );
  }

  Widget _badgeForIndex(int index, BuildContext context) {

    final badges = [ '🥇', '🥈', '🥉' ];
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8)
      ),
      padding: const EdgeInsets.all(4.0),
      child: Text(
        index < badges.length ? badges[index] : '${index + 1}',
        style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 24),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    final lm = AppLocalizations.of(context)!;

    return SizedBox(
      width: 3 * 128 + 3 * 16 + 2 * 16,
      child: Column(
        spacing: 16,
        children: [
          SectionHeader(title: lm.user_favorites_tracks),
          FutureContent(
            future: _favoritesFuture,
            height: 205,
            hasData: (f) => f.tracks.isNotEmpty,
            emptyWidget: _emptyWidget(context),
            builder: (context, favorites) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [0, 1, 2].map((index) {
                    final track = favorites.tracks[index];

                    if (track == null) {
                      return DummyEntityCard(title: (index + 1).toString());
                    }

                    return EntityCard(
                      entity: track,
                      type: EntityCardType.track,
                      badge: _badgeForIndex(index, context),
                    );
                  }).toList(),
                ),
              );
            },
          ),


          SectionHeader(title: lm.user_favorites_albums),
          FutureContent(
            future: _favoritesFuture,
            height: 205,
            hasData: (f) => f.albums.isNotEmpty,
            emptyWidget: _emptyWidget(context),
            builder: (context, favorites) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [0, 1, 2].map((index) {
                    final album = favorites.albums[index];

                    if (album == null) {
                      return DummyEntityCard(title: (index + 1).toString());
                    }

                    return EntityCard(
                      entity: album,
                      type: EntityCardType.album,
                      badge: _badgeForIndex(index, context),
                    );
                  }).toList(),
                ),
              );
            },
          ),

          SectionHeader(title: lm.user_favorites_artists),
          FutureContent(
            future: _favoritesFuture,
            height: 205,
            hasData: (f) => f.artists.isNotEmpty,
            emptyWidget: _emptyWidget(context),
            builder: (context, favorites) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [0, 1, 2].map((index) {
                    final artist = favorites.artists[index];

                    if (artist == null) {
                      return DummyEntityCard(title: (index + 1).toString());
                    }

                    return EntityCard(
                      entity: artist,
                      type: EntityCardType.artist,
                      badge: _badgeForIndex(index, context),
                    );
                  }).toList(),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}