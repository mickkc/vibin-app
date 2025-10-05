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
  String get connect_error =>
      'Could not connect to the instance. Please check the URL and your internet connection.';

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
  String login_error(Object error) {
    return 'Login failed. Error message: $error';
  }

  @override
  String get login_invalid_credentials => 'Invalid username or password.';

  @override
  String get section_recently_listened => 'Recently Listened';

  @override
  String get section_random_tracks => 'Discover';

  @override
  String get section_top_artists => 'Top Artists This Month';

  @override
  String get section_top_tracks => 'Top Tracks This Month';

  @override
  String get section_related_tracks => 'Related Tracks';

  @override
  String get section_newest_tracks => 'Newest Tracks';

  @override
  String get section_popular_items => 'Popular';

  @override
  String get section_playlists => 'Your Playlists';

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
  String get playlists_show_all => 'Show all Playlists';

  @override
  String get playlists_show_owned => 'Show my Playlists';

  @override
  String get playlists_create_new => 'Create New Playlist';

  @override
  String get dialog_error => 'Error';

  @override
  String get dialog_warning => 'Warning';

  @override
  String get dialog_info => 'Info';

  @override
  String get dialog_finish => 'Done';

  @override
  String get dialog_cancel => 'Cancel';

  @override
  String get dialog_confirm => 'OK';

  @override
  String get dialog_create => 'Create';

  @override
  String get dialog_save => 'Save';

  @override
  String get dialog_delete => 'Delete';

  @override
  String get dialog_yes => 'Yes';

  @override
  String get dialog_no => 'No';

  @override
  String get edit_album_title => 'Edit Album';

  @override
  String get edit_album_name => 'Album Name';

  @override
  String get edit_album_cover => 'Album Cover';

  @override
  String get edit_album_name_validation_empty =>
      'The album name cannot be empty.';

  @override
  String get edit_album_name_validation_length =>
      'The album name cannot exceed 255 characters.';

  @override
  String get edit_album_description => 'Description';

  @override
  String get edit_album_year => 'Release Year';

  @override
  String get edit_album_year_validation_not_number =>
      'Release year must be a valid number.';

  @override
  String get edit_album_save_error =>
      'An error occurred while saving the album.';

  @override
  String get edit_playlist_title => 'Edit Playlist';

  @override
  String get edit_playlist_name => 'Name';

  @override
  String get edit_playlist_name_validation_empty =>
      'The playlist name cannot be empty.';

  @override
  String get edit_playlist_name_validation_length =>
      'The playlist name cannot exceed 255 characters.';

  @override
  String get edit_playlist_cover => 'Cover';

  @override
  String get edit_playlist_description => 'Description';

  @override
  String get edit_playlist_public => 'Public';

  @override
  String get edit_playlist_collaborators => 'Collaborators';

  @override
  String get edit_playlist_save_error =>
      'An error occurred while saving the playlist.';

  @override
  String get edit_playlist_vibedef => 'Vibe-def';

  @override
  String get delete_playlist_confirmation =>
      'Are you sure you want to delete this playlist?';

  @override
  String get delete_playlist_confirmation_warning =>
      'This action cannot be undone.';

  @override
  String get delete_playlist_error =>
      'An error occurred while deleting the playlist.';

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

  @override
  String get edit_track_title => 'Edit Track';

  @override
  String get edit_track_name => 'Title';

  @override
  String get edit_track_name_validation_empty =>
      'The track title cannot be empty.';

  @override
  String get edit_track_name_validation_length =>
      'The track title cannot exceed 255 characters.';

  @override
  String get edit_track_number => 'Track Number';

  @override
  String get edit_track_count => 'Total Tracks';

  @override
  String get edit_track_disc_number => 'Disc Number';

  @override
  String get edit_track_disc_count => 'Total Discs';

  @override
  String get edit_track_year => 'Year';

  @override
  String get edit_track_comment => 'Comment';

  @override
  String get edit_track_cover => 'Cover';

  @override
  String get edit_track_album => 'Album';

  @override
  String get edit_track_artists => 'Artists';

  @override
  String get edit_track_explicit => 'Explicit';

  @override
  String get edit_track_save_error =>
      'An error occurred while saving the track.';

  @override
  String get edit_track_search_metadata => 'Search Metadata';

  @override
  String get edit_tag_title => 'Edit Tag';

  @override
  String get create_tag_title => 'Create Tag';

  @override
  String get edit_tag_name => 'Name';

  @override
  String get edit_tag_description => 'Description';

  @override
  String get edit_tag_color => 'Color (Hex)';

  @override
  String get edit_tag_name_validation_empty => 'Tag name cannot be empty.';

  @override
  String get edit_tag_name_validation_already_exists =>
      'A tag with this name already exists.';

  @override
  String get edit_tag_name_validation_length =>
      'Tag name cannot exceed 255 characters.';

  @override
  String get edit_tag_color_not_hex => 'Color must be in hex format (#RRGGBB).';

  @override
  String get edit_tag_save_error => 'An error occurred while saving the tag.';

  @override
  String get edit_tag_delete_error =>
      'An error occurred while deleting the tag.';

  @override
  String get edit_tag_delete_confirmation =>
      'Are you sure you want to delete this tag?';

  @override
  String get edit_tag_delete_confirmation_warning =>
      'This action cannot be undone.';

  @override
  String get pick_artist_title => 'Select Artist';

  @override
  String get pick_artists_title => 'Select Artists';

  @override
  String get settings_app_theme_title => 'App Theme';

  @override
  String get settings_app_theme_system => 'System Default';

  @override
  String get settings_app_theme_light => 'Light';

  @override
  String get settings_app_theme_dark => 'Dark';

  @override
  String get settings_app_page_size_title => 'Page Size';

  @override
  String get settings_app_page_size_description =>
      'Number of items to load per page in overviews.';

  @override
  String get settings_app_advanced_track_search_title => 'Advanced Search';

  @override
  String get settings_app_advanced_track_search_description =>
      'When enabled, you can use advanced search operators in the track search bar (e.g., t:, a:, y:, ...).';

  @override
  String get settings_app_show_own_playlists_by_default =>
      'Show Own Playlists by Default';

  @override
  String get settings_app_show_own_playlists_by_default_description =>
      'When enabled, the playlist overview will show only your own playlists by default.';

  @override
  String get settings_app_homepage_sections_title => 'Homepage Sections';

  @override
  String get settings_app_homepage_sections_description =>
      'Select which sections to display on the homepage and in which order.';
}
