import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vibin_app/auth/auth_state.dart';
import 'package:vibin_app/dialogs/artist_picker.dart';
import 'package:vibin_app/dtos/artist/artist.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/dtos/settings/settings_map.dart';
import 'package:vibin_app/dtos/tags/tag.dart';
import 'package:vibin_app/widgets/future_content.dart';
import 'package:vibin_app/widgets/settings/server/server_boolean_settings_field.dart';
import 'package:vibin_app/widgets/settings/server/server_number_settings_field.dart';
import 'package:vibin_app/widgets/settings/server/server_multiple_selection_field.dart';
import 'package:vibin_app/widgets/settings/server/server_tag_list_field.dart';
import 'package:vibin_app/widgets/settings/settings_title.dart';

import '../../api/api_manager.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';

class AppUserSettingsView extends StatefulWidget {
  const AppUserSettingsView({super.key});

  @override
  State<AppUserSettingsView> createState() => _AppUserSettingsViewState();
}

class _AppUserSettingsViewState extends State<AppUserSettingsView> {

  final _apiManager = getIt<ApiManager>();
  final _authState = getIt<AuthState>();

  Future<List<Artist>>? _blockedArtistsFuture;
  Future<List<Tag>>? _blockedTagsFuture;
  late Future<SettingsMap> _settingsFuture;

  late final _lm = AppLocalizations.of(context)!;

  @override
  void initState() {
    _settingsFuture = _apiManager.service.getUserSettings().then((settings) {
      _blockedArtistsFuture = _apiManager.service.getArtistsByIds(
          (settings.settings["blocked_artists"] as List<dynamic>).cast<int>().join(",")
      );
      _blockedTagsFuture = _apiManager.service.getTagsByIds(
          (settings.settings["blocked_tags"] as List<dynamic>).cast<int>().join(",")
      );
      return settings;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureContent(
      future: _settingsFuture,
      builder: (context, settings) {
        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [

            SettingsTitle(
              title: _lm.settings_app_content_title,
              subtitle: _lm.settings_app_content_description,
            ),

            ServerBooleanSettingsField(
              settingKey: "show_activities_to_others",
              initialValue: settings.settings["show_activities_to_others"],
              title: _lm.settings_app_show_activity_on_profile_title,
              description: _lm.settings_app_show_activity_on_profile_description,
              icon: Icons.visibility,
            ),

            if (_blockedArtistsFuture != null)
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: FutureContent(
                  future: _blockedArtistsFuture!,
                  builder: (context, artists) {
                    return ServerMultipleSelectionField(
                      settingKey: "blocked_artists",
                      initialValues: artists,
                      displayString: (a) => a.name,
                      toServerFormat: (artists) => jsonEncode(artists.map((a) => a.id).toList()),
                      dialog: (selectedValues, onSelectedValuesChange) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return ArtistPickerDialog(
                              selected: selectedValues,
                              onChanged: onSelectedValuesChange,
                              allowEmpty: true,
                              allowMultiple: true,
                            );
                          }
                        );
                      },
                      title: _lm.settings_app_blocked_artists_title,
                      description: _lm.settings_app_blocked_artists_description,
                      icon: Icons.person_off
                    );
                  }
                ),
              ),

            if(_blockedTagsFuture != null)
              Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                child: FutureContent(
                  future: _blockedTagsFuture!,
                  builder: (context, tags) {
                    return ServerTagListField(
                      settingKey: "blocked_tags",
                      title: _lm.settings_app_blocked_tags_title,
                      description: _lm.settings_app_blocked_tags_description,
                      icon: Icons.label_off,
                      initialValues: tags,
                    );
                  }
                ),
              ),

            if (_authState.hasPermission(PermissionType.viewTracks)) ... [
              const Divider(),
              SettingsTitle(
                title: _lm.settings_app_related_scores_title,
                subtitle: _lm.settings_app_related_scores_description
              ),

              ServerNumberSettingsField(
                settingKey: "related_artist_score_multiplier",
                initialValue: settings.settings["related_artist_score_multiplier"],
                title: _lm.settings_app_related_scores_artists_title,
                description: _lm.settings_app_related_scores_artists_description,
                icon: Icons.person,
                parser: double.parse
              ),

              ServerNumberSettingsField(
                settingKey: "related_album_score_multiplier",
                initialValue: settings.settings["related_album_score_multiplier"],
                title: _lm.settings_app_related_scores_album_title,
                description: _lm.settings_app_related_scores_album_description,
                icon: Icons.album,
                parser: double.parse
              ),

              ServerNumberSettingsField(
                settingKey: "related_tags_score_multiplier",
                initialValue: settings.settings["related_tags_score_multiplier"],
                title: _lm.settings_app_related_scores_matching_tags_title,
                description: _lm.settings_app_related_scores_matching_tags_description,
                icon: Icons.sell,
                parser: double.parse
              ),

              ServerNumberSettingsField(
                settingKey: "related_tags_negative_score_multiplier",
                initialValue: settings.settings["related_tags_negative_score_multiplier"],
                title: _lm.settings_app_related_scores_not_matching_tags_title,
                description: _lm.settings_app_related_scores_not_matching_tags_description,
                icon: Icons.label_off,
                parser: double.parse
              )
            ]
          ],
        );
      },
    );
  }
}