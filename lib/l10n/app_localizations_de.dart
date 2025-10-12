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
  String get lyrics_s => 'Liedtext';

  @override
  String get lyrics_p => 'Liedtexte';

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
  String get connect_error =>
      'Die Verbindung zur Instanz konnte nicht hergestellt werden. Bitte überprüfe die URL und deine Internetverbindung.';

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
  String login_error(Object error) {
    return 'Die Anmeldung ist fehlgeschlagen. Fehlermeldung: $error';
  }

  @override
  String get login_invalid_credentials =>
      'Ungültiger Benutzername oder Passwort.';

  @override
  String get section_recently_listened => 'Wieder reinhören';

  @override
  String get section_random_tracks => 'Entdecken';

  @override
  String get section_top_artists => 'Top Künstler diesen Monat';

  @override
  String get section_top_tracks => 'Top Titel diesen Monat';

  @override
  String get section_related_tracks => 'Ähnliche Titel';

  @override
  String get section_newest_tracks => 'Neueste Titel';

  @override
  String get section_popular_items => 'Beliebt';

  @override
  String get section_playlists => 'Deine Playlists';

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
  String get now_playing_shuffle => 'Zufallswiedergabe';

  @override
  String get now_playing_repeat => 'Wiederholen';

  @override
  String get now_playing_play => 'Abspielen';

  @override
  String get now_playing_pause => 'Pausieren';

  @override
  String get now_playing_previous => 'Vorheriger Titel';

  @override
  String get now_playing_next => 'Nächster Titel';

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
  String get playlists_show_all => 'Alle Playlists anzeigen';

  @override
  String get playlists_show_owned => 'Eigene Playlists anzeigen';

  @override
  String get playlists_create_new => 'Neue Playlist erstellen';

  @override
  String get albums_show_singles => 'Singles anzeigen';

  @override
  String get albums_hide_singles => 'Singles ausblenden';

  @override
  String get artists_edit => 'Künstler bearbeiten';

  @override
  String get artists_discography => 'Diskografie';

  @override
  String get dialog_error => 'Fehler';

  @override
  String get dialog_warning => 'Warnung';

  @override
  String get dialog_info => 'Info';

  @override
  String get dialog_finish => 'Fertig';

  @override
  String get dialog_cancel => 'Abbrechen';

  @override
  String get dialog_confirm => 'Ok';

  @override
  String get dialog_create => 'Erstellen';

  @override
  String get dialog_save => 'Speichern';

  @override
  String get dialog_delete => 'Löschen';

  @override
  String get dialog_yes => 'Ja';

  @override
  String get dialog_no => 'Nein';

  @override
  String get edit_album_title => 'Album bearbeiten';

  @override
  String get edit_album_name => 'Albumname';

  @override
  String get edit_album_cover => 'Albumcover';

  @override
  String get edit_album_name_validation_empty =>
      'Der Albumname darf nicht leer sein.';

  @override
  String get edit_album_name_validation_length =>
      'Der Albumname darf maximal 255 Zeichen lang sein.';

  @override
  String get edit_album_description => 'Beschreibung';

  @override
  String get edit_album_year => 'Erscheinungsjahr';

  @override
  String get edit_album_year_validation_not_number =>
      'Das Erscheinungsjahr muss eine Zahl sein.';

  @override
  String get edit_album_save_error =>
      'Beim Speichern des Albums ist ein Fehler aufgetreten.';

  @override
  String get edit_album_search_metadata => 'Metadaten suchen';

  @override
  String get edit_album_metadata_no_description =>
      'Keine Beschreibung verfügbar.';

  @override
  String get edit_album_metadata_has_description => 'Beschreibung verfügbar.';

  @override
  String get edit_artist_title => 'Künstler bearbeiten';

  @override
  String get edit_artist_name => 'Name';

  @override
  String get edit_artist_name_validation_empty =>
      'Der Künstlername darf nicht leer sein.';

  @override
  String get edit_artist_name_validation_length =>
      'Der Künstlername darf maximal 255 Zeichen lang sein.';

  @override
  String get edit_artist_image => 'Bild';

  @override
  String get edit_artist_description => 'Beschreibung';

  @override
  String get edit_artist_load_error =>
      'Beim Laden des Künstlers ist ein Fehler aufgetreten.';

  @override
  String get edit_artist_save_error =>
      'Beim Speichern des Künstlers ist ein Fehler aufgetreten.';

  @override
  String get edit_artist_search_metadata => 'Metadaten suchen';

  @override
  String get edit_artist_metadata_no_description =>
      'Keine Beschreibung verfügbar.';

  @override
  String get edit_playlist_title => 'Playlist bearbeiten';

  @override
  String get edit_playlist_name => 'Name';

  @override
  String get edit_playlist_name_validation_empty =>
      'Der Playlist-Name darf nicht leer sein.';

  @override
  String get edit_playlist_name_validation_length =>
      'Der Playlist-Name darf maximal 255 Zeichen lang sein.';

  @override
  String get edit_playlist_cover => 'Cover';

  @override
  String get edit_playlist_description => 'Beschreibung';

  @override
  String get edit_playlist_public => 'Öffentlich';

  @override
  String get edit_playlist_collaborators => 'Mitwirkende';

  @override
  String get edit_playlist_save_error =>
      'Beim Speichern der Playlist ist ein Fehler aufgetreten.';

  @override
  String get edit_playlist_vibedef => 'Vibe-def';

  @override
  String get delete_playlist_confirmation =>
      'Möchtest du diese Playlist wirklich löschen?';

  @override
  String get delete_playlist_confirmation_warning =>
      'Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get delete_playlist_error =>
      'Beim Löschen der Playlist ist ein Fehler aufgetreten.';

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

  @override
  String get edit_track_title => 'Titel bearbeiten';

  @override
  String get edit_track_name => 'Name';

  @override
  String get edit_track_name_validation_empty =>
      'Der Titel-Name darf nicht leer sein.';

  @override
  String get edit_track_name_validation_length =>
      'Der Titel-Name darf maximal 255 Zeichen lang sein.';

  @override
  String get edit_track_number => 'Tracknummer';

  @override
  String get edit_track_count => 'Trackanzahl';

  @override
  String get edit_track_disc_number => 'Discnnummer';

  @override
  String get edit_track_disc_count => 'Discanzahl';

  @override
  String get edit_track_year => 'Jahr';

  @override
  String get edit_track_comment => 'Kommentar';

  @override
  String get edit_track_cover => 'Cover';

  @override
  String get edit_track_album => 'Album';

  @override
  String get edit_track_artists => 'Künstler';

  @override
  String get edit_track_explicit => 'Explizit';

  @override
  String get edit_track_save_error =>
      'Beim Speichern des Titels ist ein Fehler aufgetreten.';

  @override
  String get edit_track_search_metadata => 'Metadaten suchen';

  @override
  String get edit_track_lyrics => 'Liedtext';

  @override
  String get edit_track_lyrics_hint =>
      'Gib den Liedtext im .lrc-Format (synchronisiert) oder als reinen Text ein.';

  @override
  String get edit_track_search_lyrics => 'Liedtext suchen';

  @override
  String get edit_track_lyrics_synced => 'Synchronisiert';

  @override
  String get edit_track_lyrics_unsynced => 'Nicht synchronisiert';

  @override
  String get edit_track_lyrics_open => 'Öffnen';

  @override
  String get edit_track_lyrics_shift_title => 'Zeitverschiebung anpassen';

  @override
  String get edit_track_lyrics_shift_amount => 'Verschiebung (in Sekunden)';

  @override
  String get edit_track_lyrics_shift_amount_validation =>
      'Die Verschiebung muss eine Zahl sein (negativ oder positiv).';

  @override
  String get edit_track_lyrics_shift_amount_hint => 'z.B. -2,5 oder +3';

  @override
  String get edit_track_no_tags =>
      'Es sind keine Tags angewendet. Suche nach Tags und klicke auf einen Tag, um es hinzuzufügen.';

  @override
  String get edit_tag_title => 'Tag bearbeiten';

  @override
  String get create_tag_title => 'Tag erstellen';

  @override
  String get edit_tag_name => 'Name';

  @override
  String get edit_tag_description => 'Beschreibung';

  @override
  String get edit_tag_color => 'Farbe (Hex)';

  @override
  String get edit_tag_name_validation_empty =>
      'Der Tag-Name darf nicht leer sein.';

  @override
  String get edit_tag_name_validation_already_exists =>
      'Ein Tag mit diesem Namen existiert bereits.';

  @override
  String get edit_tag_name_validation_length =>
      'Der Tag-Name darf maximal 255 Zeichen lang sein.';

  @override
  String get edit_tag_color_not_hex =>
      'Die Farbe muss im Hex-Format angegeben werden (#RRGGBB).';

  @override
  String get edit_tag_save_error =>
      'Beim Speichern des Tags ist ein Fehler aufgetreten.';

  @override
  String get edit_tag_delete_error =>
      'Beim Löschen des Tags ist ein Fehler aufgetreten.';

  @override
  String get edit_tag_delete_confirmation =>
      'Möchtest du diesen Tag wirklich löschen?';

  @override
  String get edit_tag_delete_confirmation_warning =>
      'Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get pick_artist_title => 'Künstler auswählen';

  @override
  String get pick_artists_title => 'Künstler auswählen';

  @override
  String get settings_app_theme_title => 'App-Design';

  @override
  String get settings_app_theme_system => 'Systemstandard';

  @override
  String get settings_app_theme_light => 'Hell';

  @override
  String get settings_app_theme_dark => 'Dunkel';

  @override
  String get settings_app_accent_color_title => 'Akzentfarbe';

  @override
  String get settings_app_page_size_title => 'Seitengröße';

  @override
  String get settings_app_page_size_description =>
      'Die Anzahl der Elemente, die pro Seite in Übersichten geladen werden.';

  @override
  String get settings_app_advanced_track_search_title => 'Erweiterte Suche';

  @override
  String get settings_app_advanced_track_search_description =>
      'Ermöglicht die Verwendung von erweiterten Suchoperatoren in der Track-Suche (z.B. t:, a:, y:, ...).';

  @override
  String get settings_app_show_own_playlists_by_default =>
      'Eigene Playlists standardmäßig anzeigen';

  @override
  String get settings_app_show_own_playlists_by_default_description =>
      'Wenn aktiviert, werden in der Playlist-Übersicht standardmäßig nur deine eigenen Playlists angezeigt.';

  @override
  String get settings_app_show_singles_in_albums_by_default =>
      'Singles in Alben standardmäßig anzeigen';

  @override
  String get settings_app_show_singles_in_albums_by_default_description =>
      'Wenn aktiviert, werden in der Album-Übersicht standardmäßig auch Singles angezeigt.';

  @override
  String get settings_app_homepage_sections_title => 'Startseiten-Abschnitte';

  @override
  String get settings_app_homepage_sections_description =>
      'Wähle die Abschnitte aus, die auf der Startseite angezeigt werden sollen, und ordne sie per Drag & Drop neu an.';

  @override
  String get settings_app_metadata_providers_title => 'Metadaten-Anbieter';

  @override
  String get settings_app_metadata_providers_description =>
      'Wähle die Metadaten-Anbieter aus, die für die Suche nach Metadaten aus dem Internet verwendet werden sollen.';
}
