import 'package:flutter/material.dart';
import 'package:vibin_app/widgets/entity_card.dart';

import '../api/api_manager.dart';
import '../auth/auth_state.dart';
import '../extensions.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../sections/favorite_section.dart';

class AddFavoriteDialog extends StatelessWidget {

  final EntityCardType type;
  final int entityId;
  final Function? onStatusChanged;

  const AddFavoriteDialog({
    super.key,
    required this.type,
    required this.entityId,
    this.onStatusChanged,
  });

  static Future<void> show(BuildContext context, {
    required EntityCardType type,
    required int entityId,
    Function? onStatusChanged,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AddFavoriteDialog(
        type: type,
        entityId: entityId,
        onStatusChanged: onStatusChanged,
      ),
    );
  }

  String getTypeString() {
    switch (type) {
      case EntityCardType.track:
        return "track";
      case EntityCardType.album:
        return "album";
      case EntityCardType.artist:
        return "artist";
      default:
        throw UnimplementedError('Unsupported EntityCardType: $type');
    }
  }

  @override
  Widget build(BuildContext context) {

    final authState = getIt<AuthState>();
    final apiManager = getIt<ApiManager>();

    final lm = AppLocalizations.of(context)!;

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: FavoriteSection.sectionWidth,
          height: 270,
          child: FavoriteSection(
            favoritesFuture: apiManager.service.getFavoritesForUser(authState.user!.id),
            type: type,
            onItemTap: (place) async {
              await apiManager.service.addFavorite(getTypeString(), place + 1, entityId);
              if (context.mounted) {
                showSnackBar(context, lm.actions_favorite_added);
                Navigator.of(context).pop();
              }
              if (onStatusChanged != null) {
                onStatusChanged!();
              }
            },
          ),
        ),
      ),
    );
  }
}