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
  String get album => 'Album';

  @override
  String get track => 'Titel';

  @override
  String get playlist => 'Playlist';

  @override
  String get tag => 'Tag';

  @override
  String get tags => 'Tags';

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
}
