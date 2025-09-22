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

  /// No description provided for @section_related_tracks.
  ///
  /// In en, this message translates to:
  /// **'Related Tracks'**
  String get section_related_tracks;

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
