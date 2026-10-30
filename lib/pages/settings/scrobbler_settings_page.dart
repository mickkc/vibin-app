import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/pages/column_page.dart';
import 'package:vibin_app/pages/settings/scrobbling/lastfm_settings_dialog.dart';
import 'package:vibin_app/utils/error_handler.dart';
import 'package:vibin_app/widgets/future_content.dart';
import 'package:vibin_app/widgets/settings/settings_title.dart';

import '../../dtos/scrobbling/scrobbler.dart';
import '../../widgets/themed_svg.dart';

class ScrobblerSettingsPage extends StatefulWidget {

  const ScrobblerSettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _ScrobblerSettingsPageState();
}

class _ScrobblerSettingsPageState extends State<ScrobblerSettingsPage> {

  final _apiManager = getIt<ApiManager>();
  List<String> enabledScrobblerIds = [];
  late Future<List<Scrobbler>> _scrobblersFuture;

  late final _lm = AppLocalizations.of(context)!;

  void _updateScrobblers() async {
    _scrobblersFuture = _apiManager.service.getAllScrobblers();
  }

  void _updateEnabledScrobblerIds() async {
    _apiManager.service.getEnabledScrobblers().then((s) {
      setState(() {
        enabledScrobblerIds = s.map((i) => i.id).toList();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _updateEnabledScrobblerIds();
    _updateScrobblers();
  }

  void showSettingsDialog(Scrobbler scrobbler) {
    switch (scrobbler.id) {
      case "last_fm":
        LastFmSettingsDialog.show(context, scrobbler, () => setState(() {
          _updateScrobblers();
        }));
        return;
    }
  }

  void setScrobblerEnabled(String scrobblerId, bool enabled) async {
    try {
      await _apiManager.service.setScrobblerEnabled(scrobblerId, enabled);
      setState(() {
        _updateEnabledScrobblerIds();
      });
    }
    catch (e, st) {
      if (!mounted) return;
      ErrorHandler.showErrorDialog(
        context,
        enabled ? _lm.settings_scrobbling_enabling_failed : _lm.settings_scrobbling_disabling_failed,
        error: e,
        stackTrace: st
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColumnPage(
      children: [
        SettingsTitle(
          title: _lm.settings_scrobbling_title,
          subtitle: _lm.settings_scrobbling_desc,
        ),
        FutureContent(
          future: _scrobblersFuture,
          builder: (context, scrobblers) {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 300),
              itemCount: scrobblers.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final scrobbler = scrobblers[index];

                return Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ThemedSvg(
                              assetPath: "assets/icons/services/${scrobbler.id}.svg"
                          ),
                        )
                      ),
                      Text(
                        scrobbler.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const Divider(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          IconButton(
                            onPressed: () => showSettingsDialog(scrobbler),
                            icon: const Icon(Icons.settings)
                          ),
                          Switch(
                            value: scrobbler.available && enabledScrobblerIds.contains(scrobbler.id),
                            onChanged: scrobbler.available
                              ? (e) => setScrobblerEnabled(scrobbler.id, e)
                              : null
                          )
                        ],
                      )
                    ],
                  ),
                );
              }
            );
          }
        )
      ]
    );
  }
}