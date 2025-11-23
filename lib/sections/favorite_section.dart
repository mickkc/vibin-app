import 'package:flutter/material.dart';
import 'package:vibin_app/dtos/favorites.dart';
import 'package:vibin_app/sections/section_header.dart';
import 'package:vibin_app/widgets/entity_card.dart';

import '../l10n/app_localizations.dart';
import '../widgets/dummy_entity_card.dart';
import '../widgets/future_content.dart';

class FavoriteSection extends StatelessWidget {
  final Future<Favorites> favoritesFuture;
  final EntityCardType type;
  final Function(int)? onItemTap;

  const FavoriteSection({
    super.key,
    required this.favoritesFuture,
    required this.type,
    this.onItemTap,
  });

  List<dynamic> getFavoriteList(Favorites favorites) {
    switch (type) {
      case EntityCardType.album:
        return favorites.albums;
      case EntityCardType.artist:
        return favorites.artists;
      case EntityCardType.track:
        return favorites.tracks;
      default:
        throw UnimplementedError('Unsupported EntityCardType: $type');
    }
  }

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

  String getSectionTitle(AppLocalizations lm) {

    switch (type) {
      case EntityCardType.album:
        return lm.user_favorites_albums;
      case EntityCardType.artist:
        return lm.user_favorites_artists;
      case EntityCardType.track:
        return lm.user_favorites_tracks;
      default:
        throw UnimplementedError('Unsupported EntityCardType: $type');
    }
  }

  static const double imageSize = 128;
  static const double paddingPerItem = 16;
  static const double spacingBetweenItems = 16;

  static const double sectionWidth = 3 * imageSize + 3 * paddingPerItem + 2 * spacingBetweenItems;

  @override
  Widget build(BuildContext context) {

    final lm = AppLocalizations.of(context)!;

    return Column(
      spacing: 16,
      children: [
        SectionHeader(title: getSectionTitle(lm)),
        FutureContent(
          future: favoritesFuture,
          height: 205,
          hasData: (f) => getFavoriteList(f).isNotEmpty,
          emptyWidget: _emptyWidget(context),
          builder: (context, favorites) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [0, 1, 2].map((index) {
                  final item = getFavoriteList(favorites)[index];

                  if (item == null) {
                    return DummyEntityCard(
                      title: (index + 1).toString(),
                      onTap: onItemTap != null ? () => onItemTap!(index) : null,
                    );
                  }

                  return EntityCard(
                    entity: item,
                    type: type,
                    badge: _badgeForIndex(index, context),
                    onTap: onItemTap != null ? () => onItemTap!(index) : null,
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}