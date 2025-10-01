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
  String get search => 'Search';

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
  String get now_playing_nothing => 'Nothing is playing';

  @override
  String get now_playing_lyrics => 'Lyrics';

  @override
  String get now_plying_advanced_controls => 'Advanced Controls';

  @override
  String get now_playing_queue => 'Queue';

  @override
  String get playlists_private => 'Private';

  @override
  String get playlists_public => 'Public';

  @override
  String get track_actions_add_to_playlist => 'Add to Playlist';

  @override
  String get track_actions_add_to_queue => 'Add to Queue';

  @override
  String get track_actions_added_to_queue => 'Added to Queue';

  @override
  String get track_actions_goto_track => 'View Track';

  @override
  String get track_actions_goto_album => 'View Album';

  @override
  String get track_actions_goto_artist => 'View Artists';

  @override
  String get track_actions_download => 'Download';

  @override
  String get track_actions_play => 'Play';

  @override
  String get track_actions_pause => 'Pause';

  @override
  String get track_actions_edit => 'Edit';

  @override
  String get playlist_actions_play => 'Play Playlist';

  @override
  String get playlist_actions_pause => 'Pause Playlist';

  @override
  String get playlist_actions_resume => 'Resume Playlist';

  @override
  String get playlist_actions_edit => 'Edit Playlist';

  @override
  String get playlist_actions_enable_shuffling => 'Enable Shuffling';

  @override
  String get playlist_actions_disable_shuffling => 'Disable Shuffling';

  @override
  String get playlist_actions_add_collaborators => 'Add Collaborators';

  @override
  String get add_track_to_playlist_title => 'Add to Playlist';

  @override
  String get dialog_finish => 'Done';

  @override
  String get dialog_cancel => 'Cancel';

  @override
  String get dialog_create => 'Create';

  @override
  String get dialog_save => 'Save';

  @override
  String get dialog_delete => 'Delete';

  @override
  String get edit_album_title => 'Edit Album';

  @override
  String get edit_album_name => 'Album Name';

  @override
  String get edit_album_cover => 'Album Cover';

  @override
  String get edit_album_save_error =>
      'An error occurred while saving the album.';

  @override
  String get edit_image_upload => 'Upload Image';

  @override
  String get edit_image_remove => 'Remove Image';

  @override
  String get edit_image_enter_url => 'Enter Image URL';

  @override
  String get edit_image_reset => 'Reset to Default';

  @override
  String get edit_image_invalid_extension =>
      'Invalid image file extension. Allowed extensions are: .jpg, .jpeg, .png, .gif.';

  @override
  String get edit_image_too_large =>
      'Image file is too large. Maximum size is 5 MB.';

  @override
  String get edit_image_error => 'An error occurred while uploading the image.';
}
