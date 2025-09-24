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
  String get artists => 'Artists';

  @override
  String get album => 'Album';

  @override
  String get albums => 'Albums';

  @override
  String get track => 'Track';

  @override
  String get tracks => 'Tracks';

  @override
  String get playlist => 'Playlist';

  @override
  String get playlists => 'Playlists';

  @override
  String get tag => 'Tag';

  @override
  String get tags => 'Tags';

  @override
  String get autologin_failed_title => 'Auto Login Failed';

  @override
  String get autologin_failed_message =>
      'Auto login failed. Your session may have expired or the instance is unreachable.';

  @override
  String get autologin_retry => 'Retry';

  @override
  String get autologin_reconnect => 'Logout and Reconnect';

  @override
  String get autologin_quit => 'Quit';

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
  String get section_related_tracks => 'Related Tracks';

  @override
  String get section_view_all => 'View all';

  @override
  String get section_no_data => 'No data available';

  @override
  String get drawer_title => 'Vibin\'';

  @override
  String get drawer_home => 'Home';

  @override
  String get drawer_search => 'Search';

  @override
  String get drawer_profile => 'Profile';

  @override
  String get drawer_app_settings => 'App Settings';

  @override
  String get drawer_server_settings => 'Server Settings';

  @override
  String get drawer_logout => 'Logout';

  @override
  String get playlists_private => 'Private';

  @override
  String get playlists_public => 'Public';

  @override
  String get track_actions_add_to_playlist => 'Add to Playlist';

  @override
  String get track_actions_add_to_queue => 'Add to Queue';

  @override
  String get track_actions_view_track => 'View Track';

  @override
  String get track_actions_view_album => 'View Album';

  @override
  String get track_actions_view_artist => 'View Artists';

  @override
  String get track_actions_download => 'Download';
}
