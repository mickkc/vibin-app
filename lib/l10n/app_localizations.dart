import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'Vibin\''**
  String get app_name;

  /// No description provided for @welcome_message.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Vibin\'!'**
  String get welcome_message;

  /// No description provided for @artist.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get artist;

  /// No description provided for @artists.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get artists;

  /// No description provided for @album.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get album;

  /// No description provided for @albums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get albums;

  /// No description provided for @track.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get track;

  /// No description provided for @tracks.
  ///
  /// In en, this message translates to:
  /// **'Tracks'**
  String get tracks;

  /// No description provided for @playlist.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get playlist;

  /// No description provided for @playlists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get playlists;

  /// No description provided for @tag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get tag;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @autologin_failed_title.
  ///
  /// In en, this message translates to:
  /// **'Auto Login Failed'**
  String get autologin_failed_title;

  /// No description provided for @autologin_failed_message.
  ///
  /// In en, this message translates to:
  /// **'Auto login failed. Your session may have expired or the instance is unreachable.'**
  String get autologin_failed_message;

  /// No description provided for @autologin_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get autologin_retry;

  /// No description provided for @autologin_reconnect.
  ///
  /// In en, this message translates to:
  /// **'Logout and Reconnect'**
  String get autologin_reconnect;

  /// No description provided for @autologin_quit.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get autologin_quit;

  /// No description provided for @connect_title.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect_title;

  /// No description provided for @connect_description.
  ///
  /// In en, this message translates to:
  /// **'Connect to your Vibin\' instance.'**
  String get connect_description;

  /// No description provided for @connect_label_instance.
  ///
  /// In en, this message translates to:
  /// **'Instance URL'**
  String get connect_label_instance;

  /// No description provided for @connect_placeholder_instance.
  ///
  /// In en, this message translates to:
  /// **'http://localhost:8080'**
  String get connect_placeholder_instance;

  /// No description provided for @connect_button_connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect_button_connect;

  /// No description provided for @login_title.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login_title;

  /// No description provided for @login_description.
  ///
  /// In en, this message translates to:
  /// **'Log in to your Vibin\' instance.'**
  String get login_description;

  /// No description provided for @login_placeholder_username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get login_placeholder_username;

  /// No description provided for @login_placeholder_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get login_placeholder_password;

  /// No description provided for @login_button_login.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get login_button_login;

  /// No description provided for @section_recently_listened.
  ///
  /// In en, this message translates to:
  /// **'Recently Listened'**
  String get section_recently_listened;

  /// No description provided for @section_random_tracks.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get section_random_tracks;

  /// No description provided for @section_top_artists.
  ///
  /// In en, this message translates to:
  /// **'Top Artists This Month'**
  String get section_top_artists;

  /// No description provided for @section_top_tracks.
  ///
  /// In en, this message translates to:
  /// **'Top Tracks This Month'**
  String get section_top_tracks;

  /// No description provided for @section_related_tracks.
  ///
  /// In en, this message translates to:
  /// **'Related Tracks'**
  String get section_related_tracks;

  /// No description provided for @section_newest_tracks.
  ///
  /// In en, this message translates to:
  /// **'Newest Tracks'**
  String get section_newest_tracks;

  /// No description provided for @section_popular_items.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get section_popular_items;

  /// No description provided for @section_playlists.
  ///
  /// In en, this message translates to:
  /// **'Your Playlists'**
  String get section_playlists;

  /// No description provided for @section_view_all.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get section_view_all;

  /// No description provided for @section_no_data.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get section_no_data;

  /// No description provided for @drawer_title.
  ///
  /// In en, this message translates to:
  /// **'Vibin\''**
  String get drawer_title;

  /// No description provided for @drawer_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get drawer_home;

  /// No description provided for @drawer_search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get drawer_search;

  /// No description provided for @drawer_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get drawer_profile;

  /// No description provided for @drawer_app_settings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get drawer_app_settings;

  /// No description provided for @drawer_server_settings.
  ///
  /// In en, this message translates to:
  /// **'Server Settings'**
  String get drawer_server_settings;

  /// No description provided for @drawer_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get drawer_logout;

  /// No description provided for @now_playing_nothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing is playing'**
  String get now_playing_nothing;

  /// No description provided for @now_playing_lyrics.
  ///
  /// In en, this message translates to:
  /// **'Lyrics'**
  String get now_playing_lyrics;

  /// No description provided for @now_plying_advanced_controls.
  ///
  /// In en, this message translates to:
  /// **'Advanced Controls'**
  String get now_plying_advanced_controls;

  /// No description provided for @now_playing_queue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get now_playing_queue;

  /// No description provided for @playlists_private.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get playlists_private;

  /// No description provided for @playlists_public.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get playlists_public;

  /// No description provided for @track_actions_add_to_playlist.
  ///
  /// In en, this message translates to:
  /// **'Add to Playlist'**
  String get track_actions_add_to_playlist;

  /// No description provided for @track_actions_add_to_queue.
  ///
  /// In en, this message translates to:
  /// **'Add to Queue'**
  String get track_actions_add_to_queue;

  /// No description provided for @track_actions_added_to_queue.
  ///
  /// In en, this message translates to:
  /// **'Added to Queue'**
  String get track_actions_added_to_queue;

  /// No description provided for @track_actions_goto_track.
  ///
  /// In en, this message translates to:
  /// **'View Track'**
  String get track_actions_goto_track;

  /// No description provided for @track_actions_goto_album.
  ///
  /// In en, this message translates to:
  /// **'View Album'**
  String get track_actions_goto_album;

  /// No description provided for @track_actions_goto_artist.
  ///
  /// In en, this message translates to:
  /// **'View Artists'**
  String get track_actions_goto_artist;

  /// No description provided for @track_actions_download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get track_actions_download;

  /// No description provided for @track_actions_play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get track_actions_play;

  /// No description provided for @track_actions_pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get track_actions_pause;

  /// No description provided for @track_actions_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get track_actions_edit;

  /// No description provided for @playlist_actions_play.
  ///
  /// In en, this message translates to:
  /// **'Play Playlist'**
  String get playlist_actions_play;

  /// No description provided for @playlist_actions_pause.
  ///
  /// In en, this message translates to:
  /// **'Pause Playlist'**
  String get playlist_actions_pause;

  /// No description provided for @playlist_actions_resume.
  ///
  /// In en, this message translates to:
  /// **'Resume Playlist'**
  String get playlist_actions_resume;

  /// No description provided for @playlist_actions_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit Playlist'**
  String get playlist_actions_edit;

  /// No description provided for @playlist_actions_enable_shuffling.
  ///
  /// In en, this message translates to:
  /// **'Enable Shuffling'**
  String get playlist_actions_enable_shuffling;

  /// No description provided for @playlist_actions_disable_shuffling.
  ///
  /// In en, this message translates to:
  /// **'Disable Shuffling'**
  String get playlist_actions_disable_shuffling;

  /// No description provided for @playlist_actions_add_collaborators.
  ///
  /// In en, this message translates to:
  /// **'Add Collaborators'**
  String get playlist_actions_add_collaborators;

  /// No description provided for @add_track_to_playlist_title.
  ///
  /// In en, this message translates to:
  /// **'Add to Playlist'**
  String get add_track_to_playlist_title;

  /// No description provided for @playlists_show_all.
  ///
  /// In en, this message translates to:
  /// **'Show all Playlists'**
  String get playlists_show_all;

  /// No description provided for @playlists_show_owned.
  ///
  /// In en, this message translates to:
  /// **'Show my Playlists'**
  String get playlists_show_owned;

  /// No description provided for @playlists_create_new.
  ///
  /// In en, this message translates to:
  /// **'Create New Playlist'**
  String get playlists_create_new;

  /// No description provided for @dialog_finish.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get dialog_finish;

  /// No description provided for @dialog_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialog_cancel;

  /// No description provided for @dialog_create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get dialog_create;

  /// No description provided for @dialog_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get dialog_save;

  /// No description provided for @dialog_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get dialog_delete;

  /// No description provided for @dialog_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get dialog_yes;

  /// No description provided for @dialog_no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get dialog_no;

  /// No description provided for @edit_album_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Album'**
  String get edit_album_title;

  /// No description provided for @edit_album_name.
  ///
  /// In en, this message translates to:
  /// **'Album Name'**
  String get edit_album_name;

  /// No description provided for @edit_album_cover.
  ///
  /// In en, this message translates to:
  /// **'Album Cover'**
  String get edit_album_cover;

  /// No description provided for @edit_album_save_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while saving the album.'**
  String get edit_album_save_error;

  /// No description provided for @edit_playlist_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Playlist'**
  String get edit_playlist_title;

  /// No description provided for @edit_playlist_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get edit_playlist_name;

  /// No description provided for @edit_playlist_cover.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get edit_playlist_cover;

  /// No description provided for @edit_playlist_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get edit_playlist_description;

  /// No description provided for @edit_playlist_public.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get edit_playlist_public;

  /// No description provided for @edit_playlist_collaborators.
  ///
  /// In en, this message translates to:
  /// **'Collaborators'**
  String get edit_playlist_collaborators;

  /// No description provided for @edit_playlist_save_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while saving the playlist.'**
  String get edit_playlist_save_error;

  /// No description provided for @edit_playlist_vibedef.
  ///
  /// In en, this message translates to:
  /// **'Vibe-def'**
  String get edit_playlist_vibedef;

  /// No description provided for @delete_playlist_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this playlist?'**
  String get delete_playlist_confirmation;

  /// No description provided for @delete_playlist_confirmation_warning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get delete_playlist_confirmation_warning;

  /// No description provided for @delete_playlist_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while deleting the playlist.'**
  String get delete_playlist_error;

  /// No description provided for @edit_image_upload.
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get edit_image_upload;

  /// No description provided for @edit_image_remove.
  ///
  /// In en, this message translates to:
  /// **'Remove Image'**
  String get edit_image_remove;

  /// No description provided for @edit_image_enter_url.
  ///
  /// In en, this message translates to:
  /// **'Enter Image URL'**
  String get edit_image_enter_url;

  /// No description provided for @edit_image_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset to Default'**
  String get edit_image_reset;

  /// No description provided for @edit_image_invalid_extension.
  ///
  /// In en, this message translates to:
  /// **'Invalid image file extension. Allowed extensions are: .jpg, .jpeg, .png, .gif.'**
  String get edit_image_invalid_extension;

  /// No description provided for @edit_image_too_large.
  ///
  /// In en, this message translates to:
  /// **'Image file is too large. Maximum size is 5 MB.'**
  String get edit_image_too_large;

  /// No description provided for @edit_image_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while uploading the image.'**
  String get edit_image_error;

  /// No description provided for @edit_track_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Track'**
  String get edit_track_title;

  /// No description provided for @edit_track_name.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get edit_track_name;

  /// No description provided for @edit_track_number.
  ///
  /// In en, this message translates to:
  /// **'Track Number'**
  String get edit_track_number;

  /// No description provided for @edit_track_count.
  ///
  /// In en, this message translates to:
  /// **'Total Tracks'**
  String get edit_track_count;

  /// No description provided for @edit_track_disc_number.
  ///
  /// In en, this message translates to:
  /// **'Disc Number'**
  String get edit_track_disc_number;

  /// No description provided for @edit_track_disc_count.
  ///
  /// In en, this message translates to:
  /// **'Total Discs'**
  String get edit_track_disc_count;

  /// No description provided for @edit_track_year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get edit_track_year;

  /// No description provided for @edit_track_comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get edit_track_comment;

  /// No description provided for @edit_track_cover.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get edit_track_cover;

  /// No description provided for @edit_track_album.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get edit_track_album;

  /// No description provided for @edit_track_artists.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get edit_track_artists;

  /// No description provided for @edit_track_explicit.
  ///
  /// In en, this message translates to:
  /// **'Explicit'**
  String get edit_track_explicit;

  /// No description provided for @edit_track_save_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while saving the track.'**
  String get edit_track_save_error;

  /// No description provided for @edit_track_search_metadata.
  ///
  /// In en, this message translates to:
  /// **'Search Metadata'**
  String get edit_track_search_metadata;

  /// No description provided for @pick_artist_title.
  ///
  /// In en, this message translates to:
  /// **'Select Artist'**
  String get pick_artist_title;

  /// No description provided for @pick_artists_title.
  ///
  /// In en, this message translates to:
  /// **'Select Artists'**
  String get pick_artists_title;

  /// No description provided for @settings_app_theme_title.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get settings_app_theme_title;

  /// No description provided for @settings_app_theme_system.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get settings_app_theme_system;

  /// No description provided for @settings_app_theme_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settings_app_theme_light;

  /// No description provided for @settings_app_theme_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settings_app_theme_dark;

  /// No description provided for @settings_app_page_size_title.
  ///
  /// In en, this message translates to:
  /// **'Page Size'**
  String get settings_app_page_size_title;

  /// No description provided for @settings_app_page_size_description.
  ///
  /// In en, this message translates to:
  /// **'Number of items to load per page in overviews.'**
  String get settings_app_page_size_description;

  /// No description provided for @settings_app_advanced_track_search_title.
  ///
  /// In en, this message translates to:
  /// **'Advanced Search'**
  String get settings_app_advanced_track_search_title;

  /// No description provided for @settings_app_advanced_track_search_description.
  ///
  /// In en, this message translates to:
  /// **'When enabled, you can use advanced search operators in the track search bar (e.g., t:, a:, y:, ...).'**
  String get settings_app_advanced_track_search_description;

  /// No description provided for @settings_app_show_own_playlists_by_default.
  ///
  /// In en, this message translates to:
  /// **'Show Own Playlists by Default'**
  String get settings_app_show_own_playlists_by_default;

  /// No description provided for @settings_app_show_own_playlists_by_default_description.
  ///
  /// In en, this message translates to:
  /// **'When enabled, the playlist overview will show only your own playlists by default.'**
  String get settings_app_show_own_playlists_by_default_description;

  /// No description provided for @settings_app_homepage_sections_title.
  ///
  /// In en, this message translates to:
  /// **'Homepage Sections'**
  String get settings_app_homepage_sections_title;

  /// No description provided for @settings_app_homepage_sections_description.
  ///
  /// In en, this message translates to:
  /// **'Select which sections to display on the homepage and in which order.'**
  String get settings_app_homepage_sections_description;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
