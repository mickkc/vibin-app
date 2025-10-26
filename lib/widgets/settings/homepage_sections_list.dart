import 'package:flutter/material.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/settings/setting_definitions.dart';
import 'package:vibin_app/settings/settings_key.dart';
import 'package:vibin_app/settings/settings_manager.dart';
import 'package:vibin_app/widgets/settings/settings_title.dart';

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

  final _settingsManager = getIt<SettingsManager>();
  
  late List<Entry<String, String>> _selectedSections;
  late final _lm = AppLocalizations.of(context)!;

  String _getSectionName(String key) {

    switch (key) {
      case "RECENTLY_LISTENED":
        return _lm.section_recently_listened;
      case "EXPLORE":
        return _lm.section_random_tracks;
      case "TOP_ARTISTS":
        return _lm.section_top_artists;
      case "TOP_TRACKS":
        return _lm.section_top_tracks;
      case "NEW_RELEASES":
        return _lm.section_newest_tracks;
      case "POPULAR":
        return _lm.section_popular_items;
      case "PLAYLISTS":
        return _lm.section_playlists;
      default:
        return key;
    }
  }

  @override
  void initState() {
    _selectedSections = _settingsManager.get(Settings.homepageSections);
    for (final entry in HomepageSectionsList.sections) {
      if (!_selectedSections.any((s) => s.key == entry)) {
        _selectedSections.add(Entry<String, String>(entry, true.toString()));
      }
    }
    _settingsManager.set(Settings.homepageSections, _selectedSections);
    super.initState();
  }

  void _toggleSection(String sectionKey) {
    setState(() {
      final section = _selectedSections.firstWhere((s) => s.key == sectionKey);
      section.value = (section.value == false.toString()).toString();
    });
    _save();
  }

  void _save() {
    _settingsManager.set(Settings.homepageSections, _selectedSections);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsTitle(
          title: _lm.settings_app_homepage_sections_title,
          subtitle: _lm.settings_app_homepage_sections_description,
        ),
        ReorderableListView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            for (int index = 0; index < _selectedSections.length; index++)
              ListTile(
                key: Key('$index'),
                title: Text(_getSectionName(_selectedSections[index].key)),
                leading: Checkbox(
                  value: _selectedSections[index].value == true.toString(),
                  onChanged: (value) {
                    _toggleSection(_selectedSections[index].key);
                  },
                ),
              ),
          ],
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final key = _selectedSections.elementAt(oldIndex);
              final section = _selectedSections.firstWhere((s) => s.key == key.key);
              _selectedSections.remove(section);
              _selectedSections.insert(newIndex, section);
              _save();
            });
          },
        ),
      ],
    );
  }
}