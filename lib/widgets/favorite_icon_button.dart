import 'package:flutter/material.dart';
import 'package:vibin_app/widgets/entity_card.dart';

import '../api/api_manager.dart';
import '../dialogs/add_favorite_dialog.dart';
import '../extensions.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';

class FavoriteIconButton extends StatefulWidget {
  final EntityCardType type;
  final int entityId;

  const FavoriteIconButton({
    super.key,
    required this.type,
    required this.entityId,
  });

  @override
  State<FavoriteIconButton> createState() => _FavoriteIconButtonState();
}

class _FavoriteIconButtonState extends State<FavoriteIconButton> {

  static String fromEntityCardType(EntityCardType type) {
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

    final lm = AppLocalizations.of(context)!;
    final apiManager = getIt<ApiManager>();

    return FutureBuilder(
      future: apiManager.service.checkIsFavorite(fromEntityCardType(widget.type), widget.entityId),
      builder: (context, snapshot) {
        final isFavorite = snapshot.data?.isFavorite ?? false;
        final place = snapshot.data?.place;

        return IconButton(
          onPressed: () async {
            if (isFavorite && place != null) {
              await apiManager.service.removeFavorite(fromEntityCardType(widget.type), place);
              if (context.mounted) showSnackBar(context, lm.actions_favorite_removed);
              setState(() {});
            } else {
              await AddFavoriteDialog.show(
                context,
                type: widget.type,
                entityId: widget.entityId,
                onStatusChanged: () => setState(() {})
              );
            }
          },
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            size: 32,
            color: isFavorite ? Theme.of(context).colorScheme.primary : null,
          ),
          tooltip: isFavorite ? lm.actions_remove_from_favorites : lm.actions_add_to_favorites,
        );
      },
    );
  }
}