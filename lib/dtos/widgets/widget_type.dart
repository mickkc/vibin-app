

import '../../l10n/app_localizations.dart';

enum WidgetType {
  user("USER"),
  activity("ACTIVITY"),
  simpleActivity("SIMPLE_ACTIVITY"),
  favoriteTracks("FAVORITE_TRACKS"),
  favoriteAlbums("FAVORITE_ALBUMS"),
  favoriteArtists("FAVORITE_ARTISTS"),
  joinedFavorites("JOINED_FAVORITES"),
  serverStats("SERVER_STATS");

  final String value;
  const WidgetType(this.value);

  static String translateWidgetTypeToName(WidgetType type, AppLocalizations lm) {
    switch (type) {
      case WidgetType.user:
        return lm.settings_widgets_type_user;
      case WidgetType.activity:
        return lm.settings_widgets_type_activity;
      case WidgetType.simpleActivity:
        return lm.settings_widgets_type_simple_activity;
      case WidgetType.favoriteTracks:
        return lm.settings_widgets_type_favorite_tracks;
      case WidgetType.favoriteAlbums:
        return lm.settings_widgets_type_favorite_albums;
      case WidgetType.favoriteArtists:
        return lm.settings_widgets_type_favorite_artists;
      case WidgetType.joinedFavorites:
        return lm.settings_widgets_type_joined_favorites;
      case WidgetType.serverStats:
        return lm.settings_widgets_type_server_stats;
    }
  }

  static WidgetType fromString(String value) {
    return WidgetType.values.firstWhere((e) => e.value == value.toUpperCase());
  }

  static String translateFromString(String value, AppLocalizations lm) {
    final type = fromString(value);
    return translateWidgetTypeToName(type, lm);
  }
}