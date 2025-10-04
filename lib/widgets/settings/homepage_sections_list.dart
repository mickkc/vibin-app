import 'package:flutter/material.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/settings/setting_definitions.dart';
import 'package:vibin_app/settings/settings_key.dart';
import 'package:vibin_app/settings/settings_manager.dart';

import '../../main.dart';

class HomepageSectionsList extends StatefulWidget {
  const HomepageSectionsList({super.key});

  @override
  State<HomepageSectionsList> createState() => _HomepageSectionsListState();

  static List<String> sections = [
    "RECENTLY_LISTENED",
    "EXPLORE",
    "TOP_ARTISTS",
    "TOP_TRACKS",
    "NEW_RELEASES",
    "POPULAR",
    "PLAYLISTS"
  ];
}

class _HomepageSectionsListState extends State<HomepageSectionsList> {

  final SettingsManager settingsManager = getIt<SettingsManager>();
  
  late List<Entry<String, String>> selectedSections;
  late final lm = AppLocalizations.of(context)!;

  String getSectionName(String key) {

    switch (key) {
      case "RECENTLY_LISTENED":
        return lm.section_recently_listened;
      case "EXPLORE":
        return lm.section_random_tracks;
      case "TOP_ARTISTS":
        return lm.section_top_artists;
      case "TOP_TRACKS":
        return lm.section_top_tracks;
      case "NEW_RELEASES":
        return lm.section_newest_tracks;
      case "POPULAR":
        return lm.section_popular_items;
      case "PLAYLISTS":
        return lm.section_playlists;
      default:
        return key;
    }
  }

  @override
  void initState() {
    selectedSections = settingsManager.get(Settings.homepageSections);
    for (final entry in HomepageSectionsList.sections) {
      if (!selectedSections.any((s) => s.key == entry)) {
        selectedSections.add(Entry<String, String>(entry, true.toString()));
      }
    }
    settingsManager.set(Settings.homepageSections, selectedSections);
    super.initState();
  }

  void toggleSection(String sectionKey) {
    setState(() {
      final section = selectedSections.firstWhere((s) => s.key == sectionKey);
      section.value = (section.value == false.toString()).toString();
    });
    save();
  }

  void save() {
    settingsManager.set(Settings.homepageSections, selectedSections);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
          child: Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                lm.settings_app_homepage_sections_title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                lm.settings_app_homepage_sections_description,
                style: Theme.of(context).textTheme.bodyMedium,
              )
            ],
          )
        ),
        ReorderableListView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            for (int index = 0; index < selectedSections.length; index++)
              ListTile(
                key: Key('$index'),
                title: Text(getSectionName(selectedSections[index].key)),
                leading: Checkbox(
                  value: selectedSections[index].value == true.toString(),
                  onChanged: (value) {
                    toggleSection(selectedSections[index].key);
                  },
                ),
              ),
          ],
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final key = selectedSections.elementAt(oldIndex);
              final section = selectedSections.firstWhere((s) => s.key == key.key);
              selectedSections.remove(section);
              selectedSections.insert(newIndex, section);
              save();
            });
          },
        ),
      ],
    );
  }
}