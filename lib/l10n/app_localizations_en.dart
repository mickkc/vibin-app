// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_name => 'Vibin\'';

  @override
  String get welcome_message => 'Welcome to Vibin\'!';

  @override
  String get artist => 'Artist';

  @override
  String get album => 'Album';

  @override
  String get track => 'Track';

  @override
  String get playlist => 'Playlist';

  @override
  String get tag => 'Tag';

  @override
  String get tags => 'Tags';

  @override
  String get connect_title => 'Connect';

  @override
  String get connect_description => 'Connect to your Vibin\' instance.';

  @override
  String get connect_label_instance => 'Instance URL';

  @override
  String get connect_placeholder_instance => 'http://localhost:8080';

  @override
  String get connect_button_connect => 'Connect';

  @override
  String get login_title => 'Login';

  @override
  String get login_description => 'Log in to your Vibin\' instance.';

  @override
  String get login_placeholder_username => 'Username';

  @override
  String get login_placeholder_password => 'Password';

  @override
  String get login_button_login => 'Log In';

  @override
  String get section_recently_listened => 'Recently Listened';

  @override
  String get section_random_tracks => 'Discover';

  @override
  String get section_top_artists => 'Top Artists This Month';

  @override
  String get section_view_all => 'View all';

  @override
  String get section_no_data => 'No data available';
}
