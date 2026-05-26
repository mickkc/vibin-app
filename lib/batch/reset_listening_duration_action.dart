import 'package:flutter/material.dart';
import 'package:vibin_app/l10n/app_localizations.dart';

import 'batch_action_interface.dart';

class ResetListeningDurationAction implements BatchAction {
  @override
  Widget build(BuildContext context) => _ResetListeningDurationActionWidget();

  @override
  Map<String, dynamic> dataToJson() => {
    "actionType": "REMOVE_LISTEN_DURATION"
  };

  @override
  String getName(AppLocalizations lm) => lm.batch_edit_actions_remove_listen_duration;
}

class _ResetListeningDurationActionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        AppLocalizations.of(context)!.batch_edit_actions_remove_listen_duration_description,
        textAlign: TextAlign.center,
      ),
    );
  }
}