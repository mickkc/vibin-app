import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/dtos/sort_order.dart';
import 'package:vibin_app/dtos/track/track_sorting_criteria.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/settings/setting_definitions.dart';
import 'package:vibin_app/settings/settings_manager.dart';
import 'package:vibin_app/widgets/overview/paginated_overview.dart';
import 'package:vibin_app/widgets/overview/sorting_dialog.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/entity_card.dart';

class TrackPage extends StatefulWidget {

  const TrackPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _TrackPageState();
  }

}

class _TrackPageState extends State<TrackPage> {

  var _sortingCriteria = TrackSortingCriteria.TITLE;
  var _sortingOrder = SortOrder.ASC;

  late final _lm = AppLocalizations.of(context)!;

  (String, IconData) getLabel(TrackSortingCriteria criteria) {
    switch (criteria) {
      case TrackSortingCriteria.TITLE:
        return (_lm.sort_tracks_title, Icons.text_fields);
      case TrackSortingCriteria.RELEASE_YEAR:
        return (_lm.sort_tracks_release_year, Icons.calendar_month);
      case TrackSortingCriteria.AUDIO_QUALITY:
        return (_lm.sort_tracks_audio_quality, Icons.multitrack_audio);
      case TrackSortingCriteria.AUDIO_DURATION:
        return (_lm.sort_tracks_audio_duration, Icons.access_time);
      case TrackSortingCriteria.LISTEN_DURATION:
        return (_lm.sort_tracks_listen_duration, Icons.timer);
      case TrackSortingCriteria.DATE_ADDED:
        return (_lm.sort_tracks_date_added, Icons.add);
      case TrackSortingCriteria.DATE_MODIFIED:
        return (_lm.sort_tracks_date_modified, Icons.edit);
      case TrackSortingCriteria.LAST_LISTENED_TO:
        return (_lm.sort_tracks_last_listened_to, Icons.headphones);
      case TrackSortingCriteria.RANDOM:
        return (_lm.sort_tracks_random, Icons.shuffle);
    }
  }

  void _openSortDialog() {
    SortingDialog.show<TrackSortingCriteria>(
      context,
      TrackSortingCriteria.values,
      _sortingCriteria,
      getLabel,
      _sortingOrder,
      (c, so) {
        setState(() {
          _sortingCriteria = c;
          _sortingOrder = so;
        });
      }
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final parameters = GoRouterState.of(context).uri.queryParameters;
    _sortingCriteria = TrackSortingCriteria.values.firstWhere((sc) {
      return sc.name.toLowerCase() == parameters["sortingCriteria"]?.toLowerCase();
    }, orElse: () => TrackSortingCriteria.TITLE);
    _sortingOrder = SortOrder.values.firstWhere((so) {
      return so.name.toLowerCase() == parameters["sortingOrder"]?.toLowerCase();
    }, orElse: () => SortOrder.ASC);
  }

  @override
  Widget build(BuildContext context) {

    final settingsManager = getIt<SettingsManager>();
    final apiManager = getIt<ApiManager>();

    final parameters = GoRouterState.of(context).uri.queryParameters;

    return PaginatedOverview(
      key: ValueKey((_sortingCriteria, _sortingOrder)),
      fetchFunction: (page, pageSize, query) {
        final overrideAdvancedSearch = parameters['advanced'];
        return apiManager.service.searchTracks(
          query,
          overrideAdvancedSearch != null
            ? bool.parse(overrideAdvancedSearch)
            : settingsManager.get(Settings.advancedTrackSearch),
          page,
          pageSize,
          _sortingCriteria.name,
          _sortingOrder.name
        );
      },
      type: EntityCardType.track,
      title: AppLocalizations.of(context)!.tracks,
      icon: Icons.library_music,
      initialSearchQuery: parameters['search'],
      actions: [
        Tooltip(
          message: _lm.sort_by,
          child: ElevatedButton(
            onPressed: _openSortDialog,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8.0,
              children: [
                Icon(getLabel(_sortingCriteria).$2),
                Text(getLabel(_sortingCriteria).$1),
                const SizedBox(height: 20, child: VerticalDivider()),
                Icon(
                  _sortingOrder == SortOrder.ASC ? Icons.arrow_upward : Icons.arrow_downward,
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}