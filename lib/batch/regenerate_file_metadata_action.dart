import 'package:flutter/material.dart';
import 'package:vibin_app/l10n/app_localizations.dart';

import 'batch_action_interface.dart';

class RegenerateFileMetadataAction implements BatchAction {
  @override
  Widget build(BuildContext context) => _RegenerateFileMetadataActionWidget();

  @override
  Map<String, dynamic> dataToJson() => {
    "actionType": "REGENERATE_FILE_METADATA"
  };

  @override
  String getName(AppLocalizations lm) => lm.batch_edit_actions_regenerate_file_metadata;
}

class _RegenerateFileMetadataActionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        AppLocalizations.of(context)!.batch_edit_actions_regenerate_file_metadata_description,
        textAlign: TextAlign.center,
      ),
    );
  }
}