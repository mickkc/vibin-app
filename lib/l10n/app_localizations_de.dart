// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get app_name => 'Vibin\'';

  @override
  String get welcome_message => 'Willkommen bei Vibin\'!';

  @override
  String get artist => 'Künstler';

  @override
  String get artists => 'Künstler';

  @override
  String get album => 'Album';

  @override
  String get albums => 'Alben';

  @override
  String get track => 'Titel';

  @override
  String get tracks => 'Titel';

  @override
  String get playlist => 'Playlist';

  @override
  String get playlists => 'Playlists';

  @override
  String get tag => 'Tag';

  @override
  String get tags => 'Tags';

  @override
  String get search => 'Suchen';

  @override
  String get autologin_failed_title => 'Automatische Anmeldung fehlgeschlagen';

  @override
  String get autologin_failed_message =>
      'Die automatische Anmeldung ist fehlgeschlagen. Möglicherweise ist deine Sitzung abgelaufen oder die Instanz ist nicht erreichbar.';

  @override
  String get autologin_retry => 'Erneut versuchen';

  @override
  String get autologin_reconnect => 'Abmelden und neu verbinden';

  @override
  String get autologin_quit => 'Beenden';

  @override
  String get connect_title => 'Verbinden';

  @override
  String get connect_description => 'Verbinde dich mit deiner Vibin\'-Instanz.';

  @override
  String get connect_label_instance => 'Instanz-URL';

  @override
  String get connect_placeholder_instance => 'http://localhost:8080';

  @override
  String get connect_button_connect => 'Verbinden';

  @override
  String get login_title => 'Anmelden';

  @override
  String get login_description => 'Melde dich bei deiner Vibin\'-Instanz an.';

  @override
  String get login_placeholder_username => 'Benutzername';

  @override
  String get login_placeholder_password => 'Passwort';

  @override
  String get login_button_login => 'Anmelden';

  @override
  String get section_recently_listened => 'Wieder reinhören';

  @override
  String get section_random_tracks => 'Entdecken';

  @override
  String get section_top_artists => 'Top Künstler diesen Monat';

  @override
  String get section_related_tracks => 'Ähnliche Titel';

  @override
  String get section_view_all => 'Alle anzeigen';

  @override
  String get section_no_data => 'Keine Daten verfügbar';

  @override
  String get drawer_title => 'Vibin\'';

  @override
  String get drawer_home => 'Startseite';

  @override
  String get drawer_search => 'Suche';

  @override
  String get drawer_profile => 'Profil';

  @override
  String get drawer_app_settings => 'App-Einstellungen';

  @override
  String get drawer_server_settings => 'Server-Einstellungen';

  @override
  String get drawer_logout => 'Abmelden';

  @override
  String get now_playing_nothing => 'Nichts wird abgespielt';

  @override
  String get now_playing_lyrics => 'Liedtext';

  @override
  String get now_plying_advanced_controls => 'Erweiterte Steuerung';

  @override
  String get now_playing_queue => 'Warteschlange';

  @override
  String get playlists_private => 'Privat';

  @override
  String get playlists_public => 'Öffentlich';

  @override
  String get track_actions_add_to_playlist => 'Zu Playlist hinzufügen';

  @override
  String get track_actions_add_to_queue => 'Zur Warteschlange hinzufügen';

  @override
  String get track_actions_added_to_queue => 'Zur Warteschlange hinzugefügt';

  @override
  String get track_actions_goto_track => 'Titel anzeigen';

  @override
  String get track_actions_goto_album => 'Album anzeigen';

  @override
  String get track_actions_goto_artist => 'Künstler anzeigen';

  @override
  String get track_actions_download => 'Herunterladen';

  @override
  String get track_actions_play => 'Abspielen';

  @override
  String get track_actions_pause => 'Pause';

  @override
  String get track_actions_edit => 'Bearbeiten';

  @override
  String get playlist_actions_play => 'Playlist abspielen';

  @override
  String get playlist_actions_pause => 'Playlist pausieren';

  @override
  String get playlist_actions_resume => 'Playlist fortsetzen';

  @override
  String get playlist_actions_edit => 'Playlist bearbeiten';

  @override
  String get playlist_actions_enable_shuffling =>
      'Zufallswiedergabe aktivieren';

  @override
  String get playlist_actions_disable_shuffling =>
      'Zufallswiedergabe deaktivieren';

  @override
  String get playlist_actions_add_collaborators => 'Mitwirkende hinzufügen';

  @override
  String get add_track_to_playlist_title => 'Zu Playlist hinzufügen';

  @override
  String get dialog_finish => 'Fertig';

  @override
  String get dialog_cancel => 'Abbrechen';

  @override
  String get dialog_create => 'Erstellen';

  @override
  String get dialog_save => 'Speichern';

  @override
  String get dialog_delete => 'Löschen';

  @override
  String get edit_album_title => 'Album bearbeiten';

  @override
  String get edit_album_name => 'Albumname';

  @override
  String get edit_album_cover => 'Albumcover';

  @override
  String get edit_album_save_error =>
      'Beim Speichern des Albums ist ein Fehler aufgetreten.';

  @override
  String get edit_image_upload => 'Bild hochladen';

  @override
  String get edit_image_remove => 'Bild entfernen';

  @override
  String get edit_image_enter_url => 'Bild-URL eingeben';

  @override
  String get edit_image_reset => 'Zurücksetzen';

  @override
  String get edit_image_invalid_extension =>
      'Ungültige Dateierweiterung. Unterstützte Erweiterungen sind: .jpg, .jpeg, .png, .gif';

  @override
  String get edit_image_too_large =>
      'Die Bilddatei ist zu groß. Die maximale Dateigröße beträgt 5 MB.';

  @override
  String get edit_image_error =>
      'Beim Hochladen des Bildes ist ein Fehler aufgetreten.';
}
