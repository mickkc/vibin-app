import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/widgets/future_content.dart';

import 'batch_action_interface.dart';

class RegenerateFileMetadataAction implements BatchAction {

  String? provider;

  @override
  Widget build(BuildContext context) => _RegenerateFileMetadataActionWidget(action: this);

  @override
  Map<String, dynamic> dataToJson() => {
    "actionType": "REGENERATE_FILE_METADATA",
    "data": {
      "provider": provider
    }
  };

  @override
  String getName(AppLocalizations lm) => lm.batch_edit_actions_regenerate_file_metadata;
}

class _RegenerateFileMetadataActionWidget extends StatefulWidget {

  final RegenerateFileMetadataAction action;

  const _RegenerateFileMetadataActionWidget({ required this.action });

  @override
  State<StatefulWidget> createState() => _RegenerateFileMetadataActionWidgetState();
}

class _RegenerateFileMetadataActionWidgetState extends State<_RegenerateFileMetadataActionWidget> {

  final _apiManager = getIt<ApiManager>();
  late final _providersFuture = _apiManager.service.getMetadataProviders();

  late final _lm = AppLocalizations.of(context)!;

  late var provider = widget.action.provider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _lm.batch_edit_actions_regenerate_file_metadata_description,
            textAlign: TextAlign.center,
          ),
          Row(
            spacing: 8,
            children: [
              Text(
                "${_lm.settings_server_preparser_provider_title}:",
              ),
              FutureContent(
                future: _providersFuture,
                builder: (context, providers) {
                  return DropdownMenu(
                    initialSelection: provider,
                    dropdownMenuEntries: (providers.preParsers.cast<String?>() + [null])
                        .map((p) => DropdownMenuEntry(value: p, label: p ?? _lm.batch_edit_actions_regenerate_file_metadata_provider_default)).toList(),
                    onSelected: (p) {
                      widget.action.provider = p;
                      setState(() {
                        provider = p;
                      });
                    }
                  );
                }
              ),
            ],
          )
        ],
      ),
    );
  }
}